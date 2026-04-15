import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱 시작 시 Railway 서버를 백그라운드에서 미리 깨워둬요
  // (절전 상태인 서버가 첫 AI 요청 전에 준비될 수 있도록)
  ApiService.wakeUpServer();

  runApp(
    ChangeNotifierProvider(
      create: (_) => MealProvider(),
      child: const KoreanMealApp(),
    ),
  );
}

class KoreanMealApp extends StatelessWidget {
  const KoreanMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '엄마의 밥상',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185FA5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      ),
      home: const MainScreen(),
    );
  }
}
