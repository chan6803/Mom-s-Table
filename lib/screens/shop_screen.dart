import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/meal_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const _stores = [
    {'name': '쿠팡', 'icon': '🛒', 'desc': '로켓배송 · 새벽배송', 'url': 'https://www.coupang.com/np/search?q='},
    {'name': '홈플러스', 'icon': '🏪', 'desc': '온라인 마트', 'url': 'https://www.homeplus.co.kr/search?q='},
    {'name': '이마트몰', 'icon': '🏬', 'desc': 'SSG 통합 쇼핑', 'url': 'https://www.emart.com/search/get?keyword='},
    {'name': '마켓컬리', 'icon': '🥬', 'desc': '새벽배송 신선식품', 'url': 'https://www.kurly.com/search?sword='},
    {'name': '롯데온', 'icon': '🏪', 'desc': '롯데마트몰', 'url': 'https://www.lotteon.com/p/search?keyword='},
    {'name': 'G마켓', 'icon': '🛍️', 'desc': '슈퍼딜 · 할인', 'url': 'https://browse.gmarket.co.kr/search?keyword='},
  ];

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // 브라우저를 열 수 없는 경우 무시
    }
  }

  Set<String> _extractIngredients(MealProvider provider) {
    final result = <String>{};
    final all = [
      ...provider.dayMeal.breakfast,
      ...provider.dayMeal.lunch,
      ...provider.dayMeal.dinner,
    ];
    for (final item in all) {
      for (final ing in item.ingredients) {
        final name = ing.split(' ').first.replaceAll(RegExp(r'[0-9.TtgGmlML\/]'), '').trim();
        if (name.length > 1) result.add(name);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, _) {
        final ingredients = _extractIngredients(provider).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('오늘 식단의 재료를 바로 장보세요.\n쇼핑몰을 선택하거나 재료를 직접 검색할 수 있어요.',
              style: TextStyle(fontSize: 13, color: Color(0xFF888780), height: 1.6)),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Text('쇼핑몰 바로가기',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
            ),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _stores.map((s) => InkWell(
                onTap: () => _launch('${s['url']}식재료'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Text(s['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['name']!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(s['desc']!,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF888780))),
                        ],
                      )),
                    ],
                  ),
                ),
              )).toList(),
            ),

            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Text('오늘 필요한 재료 검색',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888780))),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('오늘 식단 재료 목록',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  ...ingredients.map((ing) => _IngredientRow(
                    name: ing, onLaunch: _launch)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final Future<void> Function(String) onLaunch;
  const _IngredientRow({required this.name, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final q = Uri.encodeComponent(name);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.5))),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
          InkWell(
            onTap: () => onLaunch('https://www.coupang.com/np/search?q=$q'),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: const Text('쿠팡',
                style: TextStyle(fontSize: 11, color: Color(0xFF185FA5),
                  decoration: TextDecoration.underline)),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => onLaunch('https://www.homeplus.co.kr/search?q=$q'),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: const Text('홈플러스',
                style: TextStyle(fontSize: 11, color: Color(0xFF185FA5),
                  decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }
}
