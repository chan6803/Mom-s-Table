# 🍚 오늘 뭐 먹지? — 한국 AI 식단 추천 앱

Flutter + Node.js 백엔드로 구성된 한국 가정식 AI 식단 추천 앱입니다.

---

## 📁 프로젝트 구조

```
meal_app/
├── flutter_app/          # Flutter 모바일 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/       # 데이터 모델
│   │   ├── screens/      # 화면 (홈, 취향, 장보기, AI채팅)
│   │   ├── widgets/      # 재사용 위젯
│   │   ├── services/     # API 호출, 기본 데이터
│   │   └── providers/    # 상태 관리 (Provider)
│   └── pubspec.yaml
└── backend/              # Node.js 백엔드
    ├── server.js         # Express 서버 (API 키 보안 처리)
    ├── package.json
    └── .env.example      # 환경 변수 템플릿
```

---

## 🚀 빠른 시작

### 1단계 — 백엔드 서버 설정

```bash
cd backend

# 패키지 설치
npm install

# 환경 변수 설정
cp .env.example .env
# .env 파일을 열고 ANTHROPIC_API_KEY에 실제 키 입력

# 서버 실행
npm start
# → http://localhost:3000 에서 실행됩니다
```

**API 키 발급**: https://console.anthropic.com

---

### 2단계 — Flutter 앱 실행

**사전 요구사항**
- Flutter SDK 3.0 이상: https://flutter.dev/docs/get-started/install
- Android Studio 또는 Xcode (시뮬레이터용)

```bash
cd flutter_app

# 패키지 설치
flutter pub get

# 안드로이드 에뮬레이터 또는 iOS 시뮬레이터에서 실행
flutter run
```

---

## 📱 앱 기능

| 탭 | 기능 |
|---|---|
| 🏠 식단 | 오늘의 아침/점심/저녁 식단 표시, 새로 추천 버튼 |
| ⭐ 취향 | 👍/👎로 선호·기피 메뉴 관리, AI 맞춤 추천 |
| 🛒 장보기 | 쿠팡·홈플러스 등 6개 쇼핑몰 연결, 재료 검색 |
| 💬 AI 추천 | 자유 채팅으로 맞춤 식단 문의 |

---

## 🌐 백엔드 API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | /health | 서버 상태 확인 |
| POST | /api/recommend | 식단 AI 추천 |
| POST | /api/chat | AI 채팅 |
| POST | /api/personalized | 취향 기반 맞춤 추천 |

---

## ☁️ 서버 배포 (선택 사항)

로컬 개발 후 실제 서비스로 출시할 때는 아래 중 하나를 사용하세요.

### Railway (가장 간단)
```bash
npm install -g @railway/cli
railway login
railway init
railway up
# 환경변수 ANTHROPIC_API_KEY를 Railway 대시보드에서 설정
```

### Heroku
```bash
heroku create my-meal-app-backend
heroku config:set ANTHROPIC_API_KEY=sk-ant-xxx
git push heroku main
```

### AWS / GCP / Azure
EC2, Cloud Run 등 원하는 서비스에 Docker로 배포 가능합니다.

배포 후 `flutter_app/lib/services/api_service.dart` 의 `baseUrl`을 실제 서버 URL로 변경하세요.

```dart
static const String baseUrl = 'https://your-server.com'; // ← 변경
```

---

## 🏗️ 앱 빌드 & 출시

### Android APK 빌드
```bash
cd flutter_app
flutter build apk --release
# 결과물: build/app/outputs/flutter-apk/app-release.apk
```

### iOS 빌드 (Mac 필요)
```bash
flutter build ios --release
# Xcode에서 Archive → App Store 업로드
```

---

## 🔒 보안 주의사항

- **API 키는 절대 Flutter 앱 코드에 넣지 마세요** — 앱을 역컴파일하면 노출됩니다
- API 키는 항상 백엔드 서버의 `.env` 파일에서만 관리하세요
- `.env` 파일은 절대 Git에 커밋하지 마세요 (`.gitignore`에 추가)
- 프로덕션 배포 시 Rate Limiting 미들웨어 추가를 권장합니다

---

## 🛠️ 기술 스택

- **앱**: Flutter 3.x, Dart, Provider (상태관리), SharedPreferences
- **백엔드**: Node.js, Express, @anthropic-ai/sdk
- **AI**: Claude claude-sonnet-4-20250514 (Anthropic)
- **외부 연동**: url_launcher (쿠팡, 홈플러스 등 쇼핑몰)
