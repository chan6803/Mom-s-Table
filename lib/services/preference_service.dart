import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService extends ChangeNotifier {
  List<String> _likes = [];
  List<String> _dislikes = [];
  Map<String, int> _pickCount = {};

  List<String> get likes => List.unmodifiable(_likes);
  List<String> get dislikes => List.unmodifiable(_dislikes);
  Map<String, int> get pickCount => Map.unmodifiable(_pickCount);

  List<MapEntry<String, int>> get topPicked {
    final sorted = _pickCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  PreferenceService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _likes = prefs.getStringList('kmp_likes') ?? [];
    _dislikes = prefs.getStringList('kmp_dis') ?? [];
    final raw = prefs.getString('kmp_cnt');
    if (raw != null) {
      _pickCount = Map<String, int>.from(jsonDecode(raw));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('kmp_likes', _likes);
    await prefs.setStringList('kmp_dis', _dislikes);
    await prefs.setString('kmp_cnt', jsonEncode(_pickCount));
  }

  void toggleLike(String name) {
    if (_likes.contains(name)) {
      _likes.remove(name);
    } else {
      _likes.add(name);
      _dislikes.remove(name);
    }
    _save();
    notifyListeners();
  }

  void toggleDislike(String name) {
    if (_dislikes.contains(name)) {
      _dislikes.remove(name);
    } else {
      _dislikes.add(name);
      _likes.remove(name);
    }
    _save();
    notifyListeners();
  }

  void removeFromLikes(String name) {
    _likes.remove(name);
    _save();
    notifyListeners();
  }

  void removeFromDislikes(String name) {
    _dislikes.remove(name);
    _save();
    notifyListeners();
  }

  void recordPick(String name) {
    _pickCount[name] = (_pickCount[name] ?? 0) + 1;
    _save();
    notifyListeners();
  }

  bool isLiked(String name) => _likes.contains(name);
  bool isDisliked(String name) => _dislikes.contains(name);
}
