import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../models/meal_model.dart';
import '../widgets/recipe_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: const [
        _MealSection(type: 'breakfast', label: '☀️ 아침', icon: '🌅', iconBg: Color(0xFFFAEEDA)),
        SizedBox(height: 4),
        _MealSection(type: 'lunch', label: '🌤️ 점심', icon: '🌤️', iconBg: Color(0xFFE1F5EE)),
        SizedBox(height: 4),
        _MealSection(type: 'dinner', label: '🌙 저녁', icon: '🌙', iconBg: Color(0xFFEEEDFE)),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  final String type;
  final String label;
  final String icon;
  final Color iconBg;

  const _MealSection({
    required this.type,
    required this.label,
    required this.icon,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, _) {
        final items = provider.getMeal(type);
        final loading = provider.isLoading(type);
        final totalKcal = items.fold(0, (s, i) => s + i.kcal);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6, top: 4),
              child: Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 11, 13, 9),
                    child: Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_mealLabel(type)} 식사',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text('약 $totalKcal kcal',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
                            ],
                          ),
                        ),
                        loading
                          ? const SizedBox(width: 60, child: Center(
                              child: SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))))
                          : GestureDetector(
                              onTap: () => provider.refreshMeal(type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F1FB),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('새로 추천',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF185FA5))),
                              ),
                            ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: Colors.black.withOpacity(0.08)),
                  // Menu items
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      children: items.map((item) =>
                        _MenuRow(item: item, mealType: type)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _mealLabel(String type) {
    switch (type) {
      case 'breakfast': return '아침';
      case 'lunch': return '점심';
      case 'dinner': return '저녁';
      default: return '';
    }
  }
}

class _MenuRow extends StatelessWidget {
  final MealItem item;
  final String mealType;

  const _MenuRow({required this.item, required this.mealType});

  Color _dotColor() {
    switch (item.dotColor) {
      case 'main': return const Color(0xFF1D9E75);
      case 'soup': return const Color(0xFFD85A30);
      case 'noodle': return const Color(0xFFBA7517);
      default: return const Color(0xFF378ADD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, _) {
        final liked = provider.prefs.likedMenus.contains(item.name);
        final disliked = provider.prefs.dislikedMenus.contains(item.name);

        return GestureDetector(
          onTap: () {
            provider.recordPick(item.name);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => RecipeBottomSheet(item: item),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(color: _dotColor(), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.name,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                ),
                Text(item.type,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF888780))),
                const SizedBox(width: 4),
                Text('${item.kcal}kcal',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => provider.toggleLike(item.name),
                  child: Opacity(opacity: liked ? 1.0 : 0.3,
                    child: const Text('👍', style: TextStyle(fontSize: 13))),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => provider.toggleDislike(item.name),
                  child: Opacity(opacity: disliked ? 1.0 : 0.3,
                    child: const Text('👎', style: TextStyle(fontSize: 13))),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 14, color: Color(0xFFB4B2A9)),
              ],
            ),
          ),
        );
      },
    );
  }
}
