import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/preferences_model.dart';

class ApiService {
  // ✅ Railway 배포 서버 URL
  static const String baseUrl = 'https://mom-s-table-production.up.railway.app';

  // Railway 서버 워밍업 (잠자기 상태 깨우기)
  // 앱 시작 시 한 번 호출하면 서버를 미리 깨워둘 수 있어요
  static Future<void> wakeUpServer() async {
    try {
      await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      // 실패해도 무시 (백그라운드 워밍업이므로)
    }
  }

  // 하루 3끼 한번에 추천 (중복 방지용 핵심 함수)
  static Future<Map<String, List<MealItem>>> recommendDay({
    required UserPreferences prefs,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/recommend-day'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'likedMenus': prefs.likedMenus,
              'dislikedMenus': prefs.dislikedMenus,
              'topPicked': prefs.topPicked.map((e) => e.key).toList(),
            }),
          )
          .timeout(const Duration(seconds: 90)); // 3끼 한번에라 시간 넉넉히

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'breakfast': (data['breakfast'] as List)
              .map((e) => MealItem.fromJson(e)).toList(),
          'lunch': (data['lunch'] as List)
              .map((e) => MealItem.fromJson(e)).toList(),
          'dinner': (data['dinner'] as List)
              .map((e) => MealItem.fromJson(e)).toList(),
        };
      }
      throw Exception('하루 식단 추천 실패 (서버 오류 ${response.statusCode})');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        throw Exception('서버 응답 시간 초과. 잠시 후 다시 눌러보세요.');
      }
      if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
        throw Exception('인터넷 연결을 확인해 주세요.');
      }
      rethrow;
    }
  }

  // 식단 추천 (AI)
  static Future<List<MealItem>> recommendMeal({
    required String mealType,
    required UserPreferences prefs,
    List<String> excludeMenus = const [],
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
              'excludeMenus': excludeMenus,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List items = data['meals'];
        return items.map((e) => MealItem.fromJson(e)).toList();
      }
      throw Exception('식단 추천 실패 (서버 오류 ${response.statusCode})');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        throw Exception('서버 응답 시간 초과\n서버가 막 켜지는 중일 수 있어요. 15~30초 후 다시 눌러보세요.');
      }
      if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
        throw Exception('인터넷 연결을 확인해 주세요.');
      }
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
      throw Exception('채팅 실패 (서버 오류 ${response.statusCode})');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        throw Exception('서버 응답 시간 초과\n잠시 후 다시 시도해 주세요.');
      }
      if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
        throw Exception('인터넷 연결을 확인해 주세요.');
      }
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
      throw Exception('맞춤 추천 실패 (서버 오류 ${response.statusCode})');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        throw Exception('서버 응답 시간 초과\n서버가 막 켜지는 중일 수 있어요. 잠시 후 다시 눌러보세요.');
      }
      if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
        throw Exception('인터넷 연결을 확인해 주세요.');
      }
      rethrow;
    }
  }
}
