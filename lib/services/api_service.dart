import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/preferences_model.dart';

class ApiService {
  // ✅ Railway 배포 서버 URL (https:// 반드시 포함!)
  static const String baseUrl = 'https://mom-s-table-production.up.railway.app';

  // 식단 추천 (AI)
  static Future<List<MealItem>> recommendMeal({
    required String mealType,
    required UserPreferences prefs,
  }) async {
    try {
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
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List items = data['meals'];
        return items.map((e) => MealItem.fromJson(e)).toList();
      }
      throw Exception('식단 추천 실패: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // AI 채팅
  static Future<String> chat({
    required String message,
    required List<Map<String, String>> history,
    required UserPreferences prefs,
  }) async {
    try {
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
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? '';
      }
      throw Exception('채팅 실패: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // 맞춤 식단 추천
  static Future<String> personalizedRecommend(UserPreferences prefs) async {
    try {
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
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? '';
      }
      throw Exception('맞춤 추천 실패: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
