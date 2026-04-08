class MealItem {
  final String name;
  final String type;
  final int kcal;
  final String dotColor;
  final List<String> ingredients;
  final List<String> steps;

  MealItem({
    required this.name,
    required this.type,
    required this.kcal,
    required this.dotColor,
    required this.ingredients,
    required this.steps,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      kcal: (json['kcal'] ?? 0) is int ? json['kcal'] : int.tryParse(json['kcal'].toString()) ?? 0,
      dotColor: json['dot'] ?? 'dot-side',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'kcal': kcal,
    'dot': dotColor,
    'ingredients': ingredients,
    'steps': steps,
  };
}

class DayMeal {
  List<MealItem> breakfast;
  List<MealItem> lunch;
  List<MealItem> dinner;

  DayMeal({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}
