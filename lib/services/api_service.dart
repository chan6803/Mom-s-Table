import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/preferences_model.dart';

class ApiService {
  // ══════════════════════════════════════════════════════
  // ✅ 상황에 맞게 아래 baseUrl 하나만 선택해서 주석 해제하세요
  // ══════════════════════════════════════════════════════

  // [1] 로컬 PC - Chrome 브라우저 테스트용
  // static const String baseUrl = 'http://localhost:3000';

  // [2] 로컬 PC - 안드로이드 에뮬레이터 테스트용
  static const String baseUrl = 'mom-s-table-production.up.railway.app';

  // [3] 실제 기기 테스트용 (내 PC와 같은 WiFi 연결 시, PC의 IP 주소 입력)
  // static const String baseUrl = 'http://192.168.0.XXX:3000';

  // [4] Railway 배포 후 (Railway에서 발급된 URL로 변경)
  // static const String baseUrl = 'https://momstable-backend-xxxx.railway.app';

  // ══════════════════════════════════════════════════════

  // 식단 추천 (AI)
  static Future<List<MealItem>> recommendMeal({
    required String mealType,
    required UserPreferences prefs,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mealType': mealType,
            'likedMenus': prefs.likedMenus,
            'dislikedMenus': prefs.dislikedMenus,
            'topPicked': prefs.topPicked.map((e) => e.key).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List items = data['meals'];
      return items.map((e) => MealItem.fromJson(e)).toList();
    }
    throw Exception('식단 추천 실패: ${response.statusCode}');
  }

  // AI 채팅
  static Future<String> chat({
    required String message,
    required List<Map<String, String>> history,
    required UserPreferences prefs,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'history': history,
            'likedMenus': prefs.likedMenus,
            'dislikedMenus': prefs.dislikedMenus,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['reply'] ?? '';
    }
    throw Exception('채팅 실패: ${response.statusCode}');
  }

  // 맞춤 식단 추천
  static Future<String> personalizedRecommend(UserPreferences prefs) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/personalized'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'likedMenus': prefs.likedMenus,
            'dislikedMenus': prefs.dislikedMenus,
            'topPicked': prefs.topPicked.map((e) => e.key).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['reply'] ?? '';
    }
    throw Exception('맞춤 추천 실패: ${response.statusCode}');
  }
}
