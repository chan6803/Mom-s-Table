require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ CORS 설정 (가장 먼저!)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.options('*', cors());

// ✅ JSON 파싱
app.use(express.json());

// ✅ API 키는 .env 파일에서 불러옵니다
const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// 헬스 체크
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// ─────────────────────────────────────────
// 1. 식단 추천 API
// ─────────────────────────────────────────
app.post('/api/recommend', async (req, res) => {
  const { mealType, likedMenus = [], dislikedMenus = [], topPicked = [] } = req.body;

  const label = mealType === 'breakfast' ? '아침' : mealType === 'lunch' ? '점심' : '저녁';
  const disStr = dislikedMenus.length > 0 ? `다음은 절대 제외: ${dislikedMenus.join(', ')}.` : '';
  const likeStr = likedMenus.length > 0 ? `가능하면 이런 스타일 포함: ${likedMenus.join(', ')}.` : '';
  const topStr = topPicked.length > 0 ? `자주 선택한 메뉴 참고: ${topPicked.join(', ')}.` : '';

  const prompt = `한국 가정식 1인분 ${label} 식단을 추천해줘.
${disStr} ${likeStr} ${topStr}
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
    const message = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1500,
      messages: [{ role: 'user', content: prompt }],
    });

    const text = message.content.map(b => b.text || '').join('').replace(/```json|```/g, '').trim();
    const meals = JSON.parse(text);
    res.json({ meals });
  } catch (err) {
    console.error('recommend error:', err.message);
    res.status(500).json({ error: '식단 추천 실패', detail: err.message });
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
    const response = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 700,
      system: systemPrompt,
      messages,
    });

    const reply = response.content.map(b => b.text || '').join('').trim();
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
    const response = await client.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 700,
      messages: [{ role: 'user', content: prompt }],
    });

    const reply = response.content.map(b => b.text || '').join('').trim();
    res.json({ reply });
  } catch (err) {
    console.error('personalized error:', err.message);
    res.status(500).json({ error: '맞춤 추천 실패', detail: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ 서버 실행 중: https://meal-rose.vercel.app:${3000}`);
});