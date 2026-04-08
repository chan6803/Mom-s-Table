import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/preference_service.dart';
import 'services/meal_service.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenceService()),
        ChangeNotifierProxyProvider<PreferenceService, MealService>(
          create: (ctx) => MealService(ctx.read<PreferenceService>()),
          update: (ctx, pref, meal) => meal!..updatePrefs(pref),
        ),
      ],
      child: const KoreanMealApp(),
    ),
  );
}

class KoreanMealApp extends StatelessWidget {
  const KoreanMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘 뭐 먹지?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185FA5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Pretendard',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE8E8E8), width: 0.5),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
