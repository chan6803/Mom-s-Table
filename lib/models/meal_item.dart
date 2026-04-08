class MealItem {
  final String name;
  final String type;
  final int kcal;
  final String dotType;
  final List<String> ingredients;
  final List<String> steps;

  MealItem({
    required this.name,
    required this.type,
    required this.kcal,
    required this.dotType,
    required this.ingredients,
    required this.steps,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      kcal: (json['kcal'] as num?)?.toInt() ?? 0,
      dotType: json['dot'] ?? 'dot-side',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'kcal': kcal,
    'dot': dotType,
    'ingredients': ingredients,
    'steps': steps,
  };

  Color get dotColor {
    switch (dotType) {
      case 'dot-main': return const Color(0xFF1D9E75);
      case 'dot-soup': return const Color(0xFFD85A30);
      case 'dot-noodle': return const Color(0xFFBA7517);
      default: return const Color(0xFF378ADD);
    }
  }
}

import 'package:flutter/material.dart';

class DailyMeal {
  List<MealItem> breakfast;
  List<MealItem> lunch;
  List<MealItem> dinner;

  DailyMeal({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  int get totalKcal =>
      [...breakfast, ...lunch, ...dinner].fold(0, (s, i) => s + i.kcal);
}
