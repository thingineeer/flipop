import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../services/auth_service.dart';

class NicknameScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const NicknameScreen({super.key, required this.onComplete});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _controller = TextEditingController();
  String _selectedAvatar = 'cat';
  bool _saving = false;

  static const _avatars = [
    {'id': 'cat', 'image': 'assets/images/cat_red.png', 'color': BlockColor.red},
    {'id': 'puppy', 'image': 'assets/images/puppy_blue.png', 'color': BlockColor.blue},
    {'id': 'bunny', 'image': 'assets/images/bunny_yellow.png', 'color': BlockColor.yellow},
    {'id': 'frog', 'image': 'assets/images/frog_green.png', 'color': BlockColor.green},
  ];

  Future<void> _save() async {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty || nickname.length > 12) return;

    setState(() => _saving = true);

    try {
      await AuthService().saveProfile(nickname, _selectedAvatar);
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FLIPOP',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '닉네임을 정해주세요!',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // 아바타 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _avatars.map((avatar) {
                  final id = avatar['id'] as String;
                  final image = avatar['image'] as String;
                  final color = avatar['color'] as BlockColor;
                  final isSelected = _selectedAvatar == id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GameColors.blockColors[color]
                            : GameColors.gridBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: GameColors.gridLine, width: 2),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: GameColors.blockColors[color]!
                                      .withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(image, fit: BoxFit.contain),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // 닉네임 입력
              Container(
                decoration: BoxDecoration(
                  color: GameColors.gridBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameColors.gridLine, width: 2),
                ),
                child: TextField(
                  controller: _controller,
                  maxLength: 12,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: '닉네임 (2~12자)',
                    hintStyle: TextStyle(
                      color: GameColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _save(),
                ),
              ),
              const SizedBox(height: 24),

              // 시작 버튼
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.blue],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.blockDarkColors[BlockColor.blue]!
                            .withValues(alpha: 0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'START!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
