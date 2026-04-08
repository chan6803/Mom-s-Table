class UserPreferences {
  List<String> likedMenus;
  List<String> dislikedMenus;
  Map<String, int> pickCount;

  UserPreferences({
    List<String>? likedMenus,
    List<String>? dislikedMenus,
    Map<String, int>? pickCount,
  })  : likedMenus = likedMenus ?? [],
        dislikedMenus = dislikedMenus ?? [],
        pickCount = pickCount ?? {};

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      likedMenus: List<String>.from(json['likedMenus'] ?? []),
      dislikedMenus: List<String>.from(json['dislikedMenus'] ?? []),
      pickCount: Map<String, int>.from(json['pickCount'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'likedMenus': likedMenus,
    'dislikedMenus': dislikedMenus,
    'pickCount': pickCount,
  };

  List<MapEntry<String, int>> get topPicked {
    final sorted = pickCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}
