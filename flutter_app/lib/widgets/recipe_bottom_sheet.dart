import 'package:flutter/material.dart';
import '../models/meal_model.dart';

class RecipeBottomSheet extends StatelessWidget {
  final MealItem item;
  const RecipeBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 3,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(child: Text(item.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0EA),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Color(0xFF888780)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: Colors.black.withOpacity(0.08)),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  // Kcal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${item.kcal}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Text('kcal',
                        style: TextStyle(fontSize: 12, color: Color(0xFF888780))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Ingredients
                  const Text('재료',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5, runSpacing: 5,
                    children: item.ingredients.map((ing) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
                      ),
                      child: Text(ing, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Steps
                  const Text('조리 방법',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
                  const SizedBox(height: 8),
                  ...item.steps.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F1FB), shape: BoxShape.circle),
                          child: Center(
                            child: Text('${e.key + 1}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF0C447C),
                                fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: Text(e.value,
                          style: const TextStyle(fontSize: 13, height: 1.55))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
