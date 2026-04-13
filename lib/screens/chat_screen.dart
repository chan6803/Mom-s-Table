import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _loading = false;
  bool _quickShown = true;

  final _quickChips = ['다이어트 식단 추천해줘', '고단백 한식 알려줘', '간단한 혼밥 메뉴 추천', '속이 좋지 않을 때 식단'];

  @override
  void initState() {
    super.initState();
    _messages.add({'role': 'ai', 'text': '안녕하세요! 🍽️ 어떤 식단이 필요하세요?\n건강식, 다이어트, 특정 재료 등 뭐든 물어보세요.'});
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
      _quickShown = false;
    });
    _scrollBottom();

    final provider = context.read<MealProvider>();
    try {
      final reply = await ApiService.chat(
        message: text, history: _history, prefs: provider.prefs);
      _history.add({'role': 'user', 'content': text});
      _history.add({'role': 'assistant', 'content': reply});
      setState(() => _messages.add({'role': 'ai', 'text': reply}));
    } catch (e) {
      setState(() => _messages.add(
        {'role': 'ai', 'text': '오류가 발생했어요. 서버 연결을 확인해 주세요.'}));
    }
    setState(() => _loading = false);
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _messages.length && _loading) {
                return const _TypingBubble();
              }
              final msg = _messages[i];
              return _ChatBubble(role: msg['role']!, text: msg['text']!);
            },
          ),
        ),
        if (_quickShown)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
            child: Row(
              children: _quickChips.map((chip) => GestureDetector(
                onTap: () => _send(chip),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.12), width: 0.5),
                  ),
                  child: Text(chip, style: const TextStyle(fontSize: 11)),
                ),
              )).toList(),
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '식단이나 메뉴를 물어보세요...',
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFFB4B2A9)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                    ),
                    onSubmitted: _send,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                onTap: () => _send(_ctrl.text),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF185FA5), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String role, text;
  const _ChatBubble({required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    final isAi = role == 'ai';
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : const Color(0xFF185FA5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isAi ? 3 : 14),
            bottomRight: Radius.circular(isAi ? 14 : 3),
          ),
          border: isAi ? Border.all(color: Colors.black.withOpacity(0.08), width: 0.5) : null,
        ),
        child: Text(text,
          style: TextStyle(
            fontSize: 13, height: 1.6,
            color: isAi ? const Color(0xFF1A1A1A) : Colors.white)),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14), topRight: Radius.circular(14),
            bottomLeft: Radius.circular(3), bottomRight: Radius.circular(14)),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0), const SizedBox(width: 4),
          _Dot(delay: 150), const SizedBox(width: 4),
          _Dot(delay: 300),
        ]),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ac.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(width: 5, height: 5,
          decoration: const BoxDecoration(color: Color(0xFFB4B2A9), shape: BoxShape.circle)),
      ),
    );
  }
}
