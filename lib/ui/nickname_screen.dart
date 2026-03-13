import 'dart:ui';

import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';

class NicknameScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const NicknameScreen({super.key, required this.onComplete});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _controller = TextEditingController();
  String _selectedAvatar = 'cat';
  String _selectedCountry = 'KR';
  bool _saving = false;
  String? _errorText;

  static const _countries = [
    ('KR', '대한민국'),
    ('US', '미국'),
    ('JP', '일본'),
    ('CN', '중국'),
    ('TW', '대만'),
    ('TH', '태국'),
    ('VN', '베트남'),
    ('ID', '인도네시아'),
    ('PH', '필리핀'),
    ('MY', '말레이시아'),
    ('SG', '싱가포르'),
    ('IN', '인도'),
    ('GB', '영국'),
    ('DE', '독일'),
    ('FR', '프랑스'),
    ('ES', '스페인'),
    ('IT', '이탈리아'),
    ('BR', '브라질'),
    ('MX', '멕시코'),
    ('AU', '호주'),
    ('CA', '캐나다'),
    ('RU', '러시아'),
  ];

  static const _avatars = [
    {'id': 'cat', 'image': 'assets/images/cat_red.png', 'color': BlockColor.red},
    {'id': 'puppy', 'image': 'assets/images/puppy_blue.png', 'color': BlockColor.blue},
    {'id': 'bunny', 'image': 'assets/images/bunny_yellow.png', 'color': BlockColor.yellow},
    {'id': 'frog', 'image': 'assets/images/frog_green.png', 'color': BlockColor.green},
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onNicknameChanged);
    // 기기 locale에서 국가코드 자동 감지
    final deviceCountry = PlatformDispatcher.instance.locale.countryCode;
    if (deviceCountry != null &&
        _countries.any((c) => c.$1 == deviceCountry)) {
      _selectedCountry = deviceCountry;
    }
  }

  void _onNicknameChanged() {
    final nickname = _controller.text;
    if (nickname.isEmpty) {
      setState(() => _errorText = null);
      return;
    }
    final error = AuthService().validateNickname(nickname);
    setState(() => _errorText = error);
  }

  Future<void> _save() async {
    final nickname = _controller.text.trim();

    // 정규표현식 검증
    final validationError = AuthService().validateNickname(nickname);
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      // 중복 체크
      final available = await AuthService().checkNicknameAvailable(nickname);
      if (!available) {
        if (mounted) {
          setState(() {
            _errorText = '이미 사용 중인 닉네임입니다';
            _saving = false;
          });
        }
        return;
      }

      await AuthService().saveProfile(nickname, _selectedAvatar, countryCode: _selectedCountry);
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
    _controller.removeListener(_onNicknameChanged);
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
              const SizedBox(height: 20),

              // 국가 선택
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: GameColors.gridBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameColors.gridLine, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    dropdownColor: GameColors.gridBackground,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: GameColors.textSecondary,
                    ),
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _countries.map((country) {
                      final (code, name) = country;
                      final flag = countryCodeToFlag(code);
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(
                          '$flag  $name',
                          style: const TextStyle(
                            color: GameColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCountry = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 닉네임 입력
              Container(
                decoration: BoxDecoration(
                  color: GameColors.gridBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _errorText != null
                        ? GameColors.blockColors[BlockColor.red]!
                        : GameColors.gridLine,
                    width: 2,
                  ),
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

              // 에러 메시지
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: GameColors.blockColors[BlockColor.red],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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
