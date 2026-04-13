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

  DayMeal get dayMeal => _dayMeal;
  UserPreferences get prefs => _prefs;
  bool get loadingBreakfast => _loadingBreakfast;
  bool get loadingLunch => _loadingLunch;
  bool get loadingDinner => _loadingDinner;

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
      case 'breakfast': return _dayMeal.breakfast;
      case 'lunch': return _dayMeal.lunch;
      case 'dinner': return _dayMeal.dinner;
      default: return [];
    }
  }

  bool isLoading(String type) {
    switch (type) {
      case 'breakfast': return _loadingBreakfast;
      case 'lunch': return _loadingLunch;
      case 'dinner': return _loadingDinner;
      default: return false;
    }
  }

  void _setLoading(String type, bool val) {
    switch (type) {
      case 'breakfast': _loadingBreakfast = val; break;
      case 'lunch': _loadingLunch = val; break;
      case 'dinner': _loadingDinner = val; break;
    }
    notifyListeners();
  }

  Future<void> refreshMeal(String type) async {
    _setLoading(type, true);
    try {
      final items = await ApiService.recommendMeal(mealType: type, prefs: _prefs);
      switch (type) {
        case 'breakfast': _dayMeal.breakfast = items; break;
        case 'lunch': _dayMeal.lunch = items; break;
        case 'dinner': _dayMeal.dinner = items; break;
      }
    } catch (e) {
      // 실패 시 기본 데이터 유지
      debugPrint('식단 추천 오류: $e');
    }
    _setLoading(type, false);
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
    final all = [..._dayMeal.breakfast, ..._dayMeal.lunch, ..._dayMeal.dinner];
    return all.fold(0, (s, i) => s + i.kcal);
  }
}
