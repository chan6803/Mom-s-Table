import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/preferences_model.dart';

class ApiService {
  // ✅ 배포 시 실제 서버 URL로 변경하세요
  static const String baseUrl = 'https://meal-rose.vercel.app:3000';

  // 식단 추천 (AI)
  static Future<List<MealItem>> recommendMeal({
    required String mealType,
    required UserPreferences prefs,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mealType': mealType,
        'likedMenus': prefs.likedMenus,
        'dislikedMenus': prefs.dislikedMenus,
        'topPicked': prefs.topPicked.map((e) => e.key).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'history': history,
        'likedMenus': prefs.likedMenus,
        'dislikedMenus': prefs.dislikedMenus,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? '';
    }
    throw Exception('채팅 실패: ${response.statusCode}');
  }

  // 맞춤 식단 추천
  static Future<String> personalizedRecommend(UserPreferences prefs) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/personalized'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'likedMenus': prefs.likedMenus,
        'dislikedMenus': prefs.dislikedMenus,
        'topPicked': prefs.topPicked.map((e) => e.key).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? '';
    }
    throw Exception('맞춤 추천 실패: ${response.statusCode}');
  }
}
