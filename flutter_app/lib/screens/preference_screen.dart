import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../services/api_service.dart';

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});
  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  bool _loading = false;

  Future<void> _aiPersonalized(BuildContext context) async {
    final provider = context.read<MealProvider>();
    setState(() => _loading = true);
    try {
      final reply = await ApiService.personalizedRecommend(provider.prefs);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('✨ 맞춤 식단 추천', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          content: SingleChildScrollView(
            child: Text(reply, style: const TextStyle(fontSize: 13, height: 1.7))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('확인')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추천을 불러오지 못했어요. 서버 연결을 확인해 주세요.')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, provider, _) {
        final prefs = provider.prefs;
        final top = prefs.topPicked;

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Stats
            Row(children: [
              _StatBox(label: '선호 메뉴', value: '${prefs.likedMenus.length}'),
              const SizedBox(width: 8),
              _StatBox(label: '기피 메뉴', value: '${prefs.dislikedMenus.length}'),
            ]),
            const SizedBox(height: 10),

            // Liked
            _PrefCard(
              title: '👍 선호 메뉴',
              tags: prefs.likedMenus,
              color: const Color(0xFFEAF3DE),
              textColor: const Color(0xFF27500A),
              borderColor: const Color(0xFFC0DD97),
              emptyMsg: '아직 없어요. 식단에서 👍를 눌러보세요!',
              onRemove: (name) => provider.removeLike(name),
            ),
            const SizedBox(height: 10),

            // Disliked
            _PrefCard(
              title: '👎 기피 메뉴 (다음 추천에서 제외)',
              tags: prefs.dislikedMenus,
              color: const Color(0xFFFCEBEB),
              textColor: const Color(0xFF791F1F),
              borderColor: const Color(0xFFF7C1C1),
              emptyMsg: '아직 없어요. 싫은 메뉴에 👎를 눌러보세요!',
              onRemove: (name) => provider.removeDislike(name),
            ),
            const SizedBox(height: 10),

            // Top picked
            if (top.isNotEmpty) ...[
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
                    const Text('📊 자주 선택한 메뉴',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5, runSpacing: 5,
                      children: top.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3DE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC0DD97), width: 0.5),
                        ),
                        child: Text('${e.key}  ${e.value}회',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF27500A))),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // AI personalized
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF185FA5).withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨ AI 맞춤 추천 받기',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF185FA5))),
                  const SizedBox(height: 6),
                  const Text('선호·기피 정보를 바탕으로 AI가 맞춤 식단을 추천해 드려요.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888780))),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _aiPersonalized(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: _loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('내 취향으로 오늘 식단 추천받기', style: TextStyle(fontSize: 13)),
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
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
          ],
        ),
      ),
    );
  }
}

class _PrefCard extends StatelessWidget {
  final String title;
  final List<String> tags;
  final Color color, textColor, borderColor;
  final String emptyMsg;
  final void Function(String) onRemove;

  const _PrefCard({
    required this.title, required this.tags, required this.color,
    required this.textColor, required this.borderColor,
    required this.emptyMsg, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          tags.isEmpty
            ? Text(emptyMsg,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB4B2A9), fontStyle: FontStyle.italic))
            : Wrap(
                spacing: 5, runSpacing: 5,
                children: tags.map((name) => Container(
                  padding: const EdgeInsets.fromLTRB(9, 3, 6, 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(name, style: TextStyle(fontSize: 12, color: textColor)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onRemove(name),
                      child: Text('✕', style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6))),
                    ),
                  ]),
                )).toList(),
              ),
        ],
      ),
    );
  }
}
