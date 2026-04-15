import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';
import '../models/preferences_model.dart';
import '../services/api_service.dart';
import '../services/default_meal_data.dart';

class MealProvider extends ChangeNotifier {
  late DayMeal _dayMeal;
  UserPreferences _prefs = UserPreferences();
  bool _loadingBreakfast = false;
  bool _loadingLunch = false;
  bool _loadingDinner = false;
  String? _lastError;

  DayMeal get dayMeal => _dayMeal;
  UserPreferences get prefs => _prefs;
  bool get loadingBreakfast => _loadingBreakfast;
  bool get loadingLunch => _loadingLunch;
  bool get loadingDinner => _loadingDinner;
  String? get lastError => _lastError;

  MealProvider() {
    _dayMeal = DefaultMealData.defaultDay();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('user_prefs');
    if (raw != null) {
      _prefs = UserPreferences.fromJson(jsonDecode(raw));
      notifyListeners();
    }
  }

  Future<void> _savePrefs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('user_prefs', jsonEncode(_prefs.toJson()));
  }

  List<MealItem> getMeal(String type) {
    switch (type) {
      case 'breakfast':
        return _dayMeal.breakfast;
      case 'lunch':
        return _dayMeal.lunch;
      case 'dinner':
        return _dayMeal.dinner;
      default:
        return [];
    }
  }

  bool isLoading(String type) {
    switch (type) {
      case 'breakfast':
        return _loadingBreakfast;
      case 'lunch':
        return _loadingLunch;
      case 'dinner':
        return _loadingDinner;
      default:
        return false;
    }
  }

  void _setLoading(String type, bool val) {
    switch (type) {
      case 'breakfast':
        _loadingBreakfast = val;
        break;
      case 'lunch':
        _loadingLunch = val;
        break;
      case 'dinner':
        _loadingDinner = val;
        break;
    }
    notifyListeners();
  }

  // 아침→점심→저녁 순서로 순차 호출, 앞 끼니 메뉴를 다음 끼니에서 제외
  // 서버의 기존 /api/recommend 엔드포인트를 그대로 활용 (안정적)
  Future<bool> refreshMeal(String type) async {
    _lastError = null;
    bool success = false;

    try {
      // ── Step 1: 아침 추천 ──────────────────────────
      _loadingBreakfast = true;
      notifyListeners();

      final breakfastItems = await ApiService.recommendMeal(
        mealType: 'breakfast',
        prefs: _prefs,
        excludeMenus: [],
      );
      _dayMeal.breakfast = breakfastItems;
      _loadingBreakfast = false;
      notifyListeners();

      // ── Step 2: 점심 추천 (아침 메뉴 제외) ───────────
      _loadingLunch = true;
      notifyListeners();

      final excludeForLunch = breakfastItems.map((m) => m.name).toList();
      final lunchItems = await ApiService.recommendMeal(
        mealType: 'lunch',
        prefs: _prefs,
        excludeMenus: excludeForLunch,
      );
      _dayMeal.lunch = lunchItems;
      _loadingLunch = false;
      notifyListeners();

      // ── Step 3: 저녁 추천 (아침+점심 메뉴 제외) ──────
      _loadingDinner = true;
      notifyListeners();

      final excludeForDinner = [
        ...breakfastItems.map((m) => m.name),
        ...lunchItems.map((m) => m.name),
      ];
      final dinnerItems = await ApiService.recommendMeal(
        mealType: 'dinner',
        prefs: _prefs,
        excludeMenus: excludeForDinner,
      );
      _dayMeal.dinner = dinnerItems;
      _loadingDinner = false;
      notifyListeners();

      success = true;
    } catch (e) {
      debugPrint('식단 추천 오류: $e');
      _lastError = e.toString();
      _loadingBreakfast = false;
      _loadingLunch = false;
      _loadingDinner = false;
      notifyListeners();
    }

    return success;
  }

  void recordPick(String name) {
    _prefs.pickCount[name] = (_prefs.pickCount[name] ?? 0) + 1;
    _savePrefs();
    notifyListeners();
  }

  void toggleLike(String name) {
    if (_prefs.likedMenus.contains(name)) {
      _prefs.likedMenus.remove(name);
    } else {
      _prefs.likedMenus.add(name);
      _prefs.dislikedMenus.remove(name);
    }
    _savePrefs();
    notifyListeners();
  }

  void toggleDislike(String name) {
    if (_prefs.dislikedMenus.contains(name)) {
      _prefs.dislikedMenus.remove(name);
    } else {
      _prefs.dislikedMenus.add(name);
      _prefs.likedMenus.remove(name);
    }
    _savePrefs();
    notifyListeners();
  }

  void removeLike(String name) {
    _prefs.likedMenus.remove(name);
    _savePrefs();
    notifyListeners();
  }

  void removeDislike(String name) {
    _prefs.dislikedMenus.remove(name);
    _savePrefs();
    notifyListeners();
  }

  int get totalKcal {
    final all = [
      ..._dayMeal.breakfast,
      ..._dayMeal.lunch,
      ..._dayMeal.dinner,
    ];
    return all.fold(0, (s, i) => s + i.kcal);
  }
}
