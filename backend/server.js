require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// ── AI 제공자 선택 ──────────────────────────────────────
// .env 파일에서 AI_PROVIDER=deepseek 또는 AI_PROVIDER=anthropic 으로 선택
const AI_PROVIDER = process.env.AI_PROVIDER || 'anthropic';

let callAI;

if (AI_PROVIDER === 'deepseek') {
  // DeepSeek API (OpenAI 호환 형식)
  const fetch = require('node-fetch');
  callAI = async ({ system, messages, maxTokens = 1000 }) => {
    const allMessages = system
      ? [{ role: 'system', content: system }, ...messages]
      : messages;

    const res = await fetch('https://api.deepseek.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: allMessages,
        max_tokens: maxTokens,
      }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(JSON.stringify(data));
    return data.choices[0].message.content.trim();
  };
} else {
  // Anthropic (Claude) API
  const Anthropic = require('@anthropic-ai/sdk');
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  callAI = async ({ system, messages, maxTokens = 1000 }) => {
    const response = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: maxTokens,
      ...(system ? { system } : {}),
      messages,
    });
    return response.content.map(b => b.text || '').join('').trim();
  };
}

app.use(cors());
app.use(express.json());

// 헬스 체크
app.get('/health', (req, res) => {
  const hasKey = AI_PROVIDER === 'anthropic'
    ? !!process.env.ANTHROPIC_API_KEY
    : !!process.env.DEEPSEEK_API_KEY;
  res.json({
    status: 'ok',
    provider: AI_PROVIDER,
    apiKeySet: hasKey,
  });
});

// ✅ 이 줄 추가 — 브라우저로 루트 접속 시 상태 페이지 표시
app.get('/', (req, res) => {
  res.send(`
    <h2>🍚 엄마의 밥상 API 서버</h2>
    <p>✅ 서버 정상 실행 중</p>
    <p>AI 제공자: <b>${AI_PROVIDER}</b></p>
    <p>사용 가능한 API:</p>
    <ul>
      <li>GET /health</li>
      <li>POST /api/recommend</li>
      <li>POST /api/chat</li>
      <li>POST /api/personalized</li>
    </ul>
  `);
});

// ─────────────────────────────────────────
// 1. 식단 추천 API
// ─────────────────────────────────────────
app.post('/api/recommend', async (req, res) => {
  const { mealType, likedMenus = [], dislikedMenus = [], topPicked = [], excludeMenus = [] } = req.body;

  const label = mealType === 'breakfast' ? '아침' : mealType === 'lunch' ? '점심' : '저녁';
  const disStr = dislikedMenus.length > 0 ? `다음은 절대 제외: ${dislikedMenus.join(', ')}.` : '';
  const likeStr = likedMenus.length > 0 ? `가능하면 이런 스타일 포함: ${likedMenus.join(', ')}.` : '';
  const topStr = topPicked.length > 0 ? `자주 선택한 메뉴 참고: ${topPicked.join(', ')}.` : '';
  const exclStr = excludeMenus.length > 0
    ? `[중복 금지] 오늘 다른 끼니에 이미 나온 메뉴이므로 절대 포함하지 마: ${excludeMenus.join(', ')}.`
    : '';

  const prompt = `한국 가정식 1인분 ${label} 식단을 추천해줘.
${disStr} ${likeStr} ${topStr} ${exclStr}
아침·점심·저녁이 겹치지 않도록 ${label}에 어울리는 메뉴로만 구성해줘.
밥 또는 분식 1가지 + 국 또는 찌개 1가지 + 반찬 3가지 이상으로 구성해줘.
반드시 아래 JSON 배열 형식만 출력해. 다른 말은 절대 쓰지 마.
[
  {
    "name": "메뉴명",
    "type": "주식|국|찌개|반찬|분식 중 하나",
    "kcal": 숫자,
    "dot": "dot-main|dot-soup|dot-side|dot-noodle 중 하나",
    "ingredients": ["재료1 양", "재료2 양"],
    "steps": ["1단계", "2단계", "3단계"]
  }
]`;

  try {
    const text = await callAI({
      messages: [{ role: 'user', content: prompt }],
      maxTokens: 1500,
    });
    const cleaned = text.replace(/```json|```/g, '').trim();
    const meals = JSON.parse(cleaned);
    res.json({ meals });
  } catch (err) {
    console.error('recommend error:', err.message);
    const isAuthError = err.message && (err.message.includes('401') || err.message.includes('Authentication') || err.message.includes('API key'));
    res.status(500).json({
      error: isAuthError ? 'API 키 오류 - Railway Variables를 확인하세요' : '식단 추천 실패',
      detail: err.message
    });
  }
});


// ─────────────────────────────────────────
// 1-b. 하루 3끼 한번에 추천 API (중복 방지 핵심)
// ─────────────────────────────────────────
app.post('/api/recommend-day', async (req, res) => {
  const { likedMenus = [], dislikedMenus = [], topPicked = [] } = req.body;

  const disStr = dislikedMenus.length > 0
    ? '절대 제외 메뉴: ' + dislikedMenus.join(', ') + '.'
    : '';
  const likeStr = likedMenus.length > 0
    ? '선호 스타일: ' + likedMenus.join(', ') + '.'
    : '';
  const topStr = topPicked.length > 0
    ? '자주 먹는 메뉴 참고: ' + topPicked.join(', ') + '.'
    : '';

  const schema = '{"name":"메뉴명","type":"주식또는국또는찌개또는반찬","kcal":숫자,"dot":"dot-main또는dot-soup또는dot-side또는dot-noodle","ingredients":["재료1 양"],"steps":["조리법"]}';

  const prompt = '당신은 한국 가정식 전문 영양사입니다.\n'
    + '오늘 하루 아침/점심/저녁 3끼를 동시에 계획해서 추천해주세요.\n'
    + disStr + ' ' + likeStr + ' ' + topStr + '\n\n'
    + '규칙:\n'
    + '1. 아침/점심/저녁에 동일한 메뉴명이 절대 겹치면 안 됩니다\n'
    + '2. 아침은 가볍게(죽,계란,토스트도 가능), 점심은 든든하게, 저녁은 균형있게\n'
    + '3. 각 끼니: 주식 1개 + 국/찌개 1개 + 반찬 2개 이상 (총 4~5개)\n'
    + '4. 반드시 아래 JSON만 출력하고 설명은 절대 쓰지 마세요\n\n'
    + '출력 형식 (이 구조 그대로):\n'
    + '{"breakfast":[' + schema + ',' + schema + ',' + schema + ',' + schema + '],'
    + '"lunch":[' + schema + ',' + schema + ',' + schema + ',' + schema + '],'
    + '"dinner":[' + schema + ',' + schema + ',' + schema + ',' + schema + ']}';

  try {
    const text = await callAI({
      messages: [{ role: 'user', content: prompt }],
      maxTokens: 2500,
    });
    const cleaned = text.replace(/```json|```/g, '').trim();
    const jsonStart = cleaned.indexOf('{');
    const jsonEnd = cleaned.lastIndexOf('}');
    if (jsonStart === -1 || jsonEnd === -1) {
      throw new Error('AI가 JSON을 반환하지 않았습니다: ' + cleaned.slice(0, 100));
    }
    const day = JSON.parse(cleaned.slice(jsonStart, jsonEnd + 1));
    res.json({
      breakfast: day.breakfast || [],
      lunch: day.lunch || [],
      dinner: day.dinner || [],
    });
  } catch (err) {
    console.error('recommend-day error:', err.message);
    res.status(500).json({ error: '하루 식단 추천 실패', detail: err.message });
  }
});
// ─────────────────────────────────────────
// 2. AI 채팅 API
// ─────────────────────────────────────────
app.post('/api/chat', async (req, res) => {
  const { message, history = [], likedMenus = [], dislikedMenus = [] } = req.body;

  const disStr = dislikedMenus.length > 0 ? `[기피 메뉴: ${dislikedMenus.join(', ')}]` : '';
  const likeStr = likedMenus.length > 0 ? `[선호 메뉴: ${likedMenus.join(', ')}]` : '';

  const systemPrompt = `당신은 한국 가정식 전문 식단 추천 AI입니다.
사용자 취향 정보: ${likeStr} ${disStr}
이 취향을 반영해서 친근하게 답변해 주세요.
메뉴 추천 시 칼로리와 간단한 레시피를 포함하세요.
한국어로 350자 이내로 답변하세요.`;

  const messages = [
    ...history.map(h => ({ role: h.role, content: h.content })),
    { role: 'user', content: message },
  ];

  try {
    const reply = await callAI({ system: systemPrompt, messages, maxTokens: 700 });
    res.json({ reply });
  } catch (err) {
    console.error('chat error:', err.message);
    res.status(500).json({ error: '채팅 실패', detail: err.message });
  }
});

// ─────────────────────────────────────────
// 3. 맞춤 식단 추천 API
// ─────────────────────────────────────────
app.post('/api/personalized', async (req, res) => {
  const { likedMenus = [], dislikedMenus = [], topPicked = [] } = req.body;

  const disStr = dislikedMenus.length > 0 ? `절대 제외: ${dislikedMenus.join(', ')}.` : '';
  const likeStr = likedMenus.length > 0 ? `선호 메뉴: ${likedMenus.join(', ')}.` : '';
  const topStr = topPicked.length > 0 ? `자주 선택한 메뉴: ${topPicked.join(', ')}.` : '';

  const prompt = `당신은 한국 가정식 전문 식단 AI입니다.
사용자 취향 정보: ${likeStr} ${disStr} ${topStr}
이를 반영해서 오늘 하루 아침·점심·저녁 맞춤 식단을 친근하게 추천해 주세요.
각 식사별 주요 메뉴를 나열하고 한 줄 추천 이유를 달아주세요.
한국어로 300자 내외로 답변하세요.`;

  try {
    const reply = await callAI({
      messages: [{ role: 'user', content: prompt }],
      maxTokens: 700,
    });
    res.json({ reply });
  } catch (err) {
    console.error('personalized error:', err.message);
    res.status(500).json({ error: '맞춤 추천 실패', detail: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ 서버 실행 중: http://localhost:${PORT} (AI: ${AI_PROVIDER})`);
});
