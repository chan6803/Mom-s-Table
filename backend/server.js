require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios'); // Ollama와 통신하기 위해 axios 사용

const app = express();
const PORT = process.env.PORT || 3000;

// CORS 설정
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.options('*', cors());
app.use(express.json());

// Ollama API 설정 (여러분의 컴퓨터에서 실행 중인 Ollama 주소)
const OLLAMA_URL = 'http://localhost:11434/api/generate';
const MODEL_NAME = 'exaone3.5:latest'; // 또는 7.8b

// 헬스 체크
app.get('/health', (req, res) => res.json({ status: 'ok', model: MODEL_NAME }));

// AI 호출을 위한 공통 함수
async function askOllama(prompt) {
  try {
    const response = await axios.post(OLLAMA_URL, {
      model: MODEL_NAME,
      prompt: prompt,
      stream: false,
      options: {
        temperature: 0.7,
        top_p: 0.9
      }
    });
    return response.data.response;
  } catch (err) {
    console.error('Ollama error:', err.message);
    throw new Error('로컬 AI 호출에 실패했습니다.');
  }
}

// ─────────────────────────────────────────
// 1. 식단 추천 API
// ─────────────────────────────────────────
app.post('/api/recommend', async (req, res) => {
  const { mealType, likedMenus = [], dislikedMenus = [], topPicked = [] } = req.body;

  const label = mealType === 'breakfast' ? '아침' : mealType === 'lunch' ? '점심' : '저녁';
  const disStr = dislikedMenus.length > 0 ? `다음은 절대 제외: ${dislikedMenus.join(', ')}.` : '';
  const likeStr = likedMenus.length > 0 ? `가능하면 이런 스타일 포함: ${likedMenus.join(', ')}.` : '';
  const topStr = topPicked.length > 0 ? `자주 선택한 메뉴 참고: ${topPicked.join(', ')}.` : '';

  const prompt = `당신은 한국 요리 전문가입니다. 다음 조건에 맞는 ${label} 식단을 JSON 배열 형식으로만 추천해주세요. 다른 어떤 설명도 하지 마세요.
조건: ${disStr} ${likeStr} ${topStr}
메뉴 구성: 밥 또는 분식 1개 + 국 또는 찌개 1개 + 반찬 3개 이상.

출력 형식 예시:
[
  {
    "name": "된장찌개",
    "type": "찌개",
    "kcal": 250,
    "dot": "dot-soup",
    "ingredients": ["된장 2큰술", "두부 100g", "애호박 50g"],
    "steps": ["1. 물을 끓인다", "2. 된장을 푼다", "3. 재료를 넣고 끓인다"]
  }
]

지금 바로 JSON 배열만 출력하세요:`;

  try {
    const text = await askOllama(prompt);
    // JSON 부분만 추출하기 위한 정규식
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      throw new Error('JSON 형식을 찾을 수 없습니다.');
    }
    const meals = JSON.parse(jsonMatch[0]);
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
  const { message, likedMenus = [], dislikedMenus = [] } = req.body;

  const disStr = dislikedMenus.length > 0 ? `[기피 메뉴: ${dislikedMenus.join(', ')}]` : '';
  const likeStr = likedMenus.length > 0 ? `[선호 메뉴: ${likedMenus.join(', ')}]` : '';

  const prompt = `당신은 한국 가정식 전문 식단 추천 AI입니다.
사용자 취향 정보: ${likeStr} ${disStr}
이 취향을 반영해서 친근하게 답변해 주세요.
메뉴 추천 시 칼로리와 간단한 레시피를 포함하세요.
한국어로 350자 이내로 답변하세요.

사용자 질문: ${message}`;

  try {
    const reply = await askOllama(prompt);
    res.json({ reply: reply.trim() });
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
    const reply = await askOllama(prompt);
    res.json({ reply: reply.trim() });
  } catch (err) {
    console.error('personalized error:', err.message);
    res.status(500).json({ error: '맞춤 추천 실패', detail: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ 서버 실행 중: http://localhost:${PORT}`);
  console.log(`🤖 사용 모델: Ollama (${MODEL_NAME})`);
});