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

  // 클릭한 끼니 하나만 새로 추천
  // 다른 끼니 메뉴는 excludeMenus로 전달해 중복 방지
  // 서버 실패 시 로컬 랜덤 데이터로 즉시 대체
  Future<bool> refreshMeal(String type) async {
    _lastError = null;
    _setLoading(type, true);

    try {
      // 다른 끼니에 이미 나온 메뉴는 제외 목록에 추가
      final excludeMenus = <String>[];
      if (type != 'breakfast') {
        excludeMenus.addAll(_dayMeal.breakfast.map((m) => m.name));
      }
      if (type != 'lunch') {
        excludeMenus.addAll(_dayMeal.lunch.map((m) => m.name));
      }
      if (type != 'dinner') {
        excludeMenus.addAll(_dayMeal.dinner.map((m) => m.name));
      }

      final items = await ApiService.recommendMeal(
        mealType: type,
        prefs: _prefs,
        excludeMenus: excludeMenus,
      );
      _setMealItems(type, items);
      _setLoading(type, false);
      return true;
    } catch (e) {
      debugPrint('식단 추천 오류: $e');
      _lastError = e.toString();
      // 서버 실패 시 로컬 랜덤 데이터로 대체 (화면은 항상 새 메뉴 표시)
      _setMealItems(type, DefaultMealData.randomMeal(type));
      _setLoading(type, false);
      return false;
    }
  }

  void _setMealItems(String type, List<MealItem> items) {
    switch (type) {
      case 'breakfast':
        _dayMeal.breakfast = items;
        break;
      case 'lunch':
        _dayMeal.lunch = items;
        break;
      case 'dinner':
        _dayMeal.dinner = items;
        break;
    }
    notifyListeners();
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
