import 'dart:io';

import 'package:flutter/material.dart';
import '../domain/entities/app_user.dart';
import '../domain/failures/auth_failure.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';

/// 더보기(설정/프로필) 화면
class MoreScreen extends StatefulWidget {
  /// 랭킹 탭으로 전환하는 콜백
  final VoidCallback? onSwitchToRanking;

  const MoreScreen({super.key, this.onSwitchToRanking});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _loading = false;

  // 아바타 이미지 매핑 (leaderboard_screen과 동일)
  static const _avatarImages = {
    'cat': 'assets/images/cat_red.png',
    'puppy': 'assets/images/puppy_blue.png',
    'bunny': 'assets/images/bunny_yellow.png',
    'frog': 'assets/images/frog_green.png',
  };

  static const _avatarColors = {
    'cat': BlockColor.red,
    'puppy': BlockColor.blue,
    'bunny': BlockColor.yellow,
    'frog': BlockColor.green,
  };

  AppUser? get _user => AuthService().appUser;

  String get _providerLabel {
    final user = _user;
    if (user == null) return '로그인 안 됨';
    return switch (user.provider) {
      SignInProvider.google => 'Google',
      SignInProvider.apple => 'Apple',
      SignInProvider.anonymous => 'Guest',
    };
  }

  // ── 계정 연동 ──

  Future<void> _linkGoogle() async {
    setState(() => _loading = true);
    final (user, failure) = await AuthService().linkWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);

    if (failure != null) {
      _showError(failure);
      return;
    }
    if (user != null) {
      _showSuccess('Google 계정이 연동되었습니다');
    }
  }

  Future<void> _linkApple() async {
    setState(() => _loading = true);
    final (user, failure) = await AuthService().linkWithApple();
    if (!mounted) return;
    setState(() => _loading = false);

    if (failure != null) {
      _showError(failure);
      return;
    }
    if (user != null) {
      _showSuccess('Apple 계정이 연동되었습니다');
    }
  }

  // ── 로그아웃 / 계정 삭제 ──

  Future<void> _signOut() async {
    final confirmed = await _showConfirmDialog(
      title: '로그아웃',
      message: '로그아웃하면 게스트로 새 세션이 시작됩니다.\n소셜 로그인으로 다시 돌아올 수 있습니다.',
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    await AuthService().signOut();
    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _RestartPlaceholder()),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _showConfirmDialog(
      title: '계정 삭제',
      message: '계정을 삭제하면 모든 게임 데이터와\n랭킹 기록이 영구적으로 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.',
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    final (success, failure) = await AuthService().deleteAccount();
    if (!mounted) return;
    setState(() => _loading = false);

    if (failure != null) {
      _showError(failure);
      return;
    }
    if (success) {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _RestartPlaceholder()),
      );
    }
  }

  // ── URL 오픈 (url_launcher 추가 후 교체 예정) ──

  void _openUrl(String url) {
    // TODO: url_launcher 패키지 추가 후 launchUrl() 사용
    _showSuccess('준비 중입니다');
  }

  // ── 유틸 ──

  void _showError(AuthFailure failure) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: GameColors.blockColors[BlockColor.red],
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GameColors.blockColors[BlockColor.green],
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: GameColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              destructive ? '삭제' : '확인',
              style: TextStyle(
                color: destructive
                    ? GameColors.blockColors[BlockColor.red]
                    : GameColors.blockColors[BlockColor.blue],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        bottom: false, // 탭 바가 하단 처리
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: GameColors.textSecondary,
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  // 타이틀
                  const Text(
                    '더보기',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1) 프로필 카드
                  _buildProfileCard(),
                  const SizedBox(height: 28),

                  // 2) 게임 섹션
                  _buildSectionHeader('게임'),
                  const SizedBox(height: 8),
                  _buildSectionCard(children: [
                    _buildListTile(
                      icon: Icons.emoji_events_rounded,
                      iconColor: GameColors.blockColors[BlockColor.yellow]!,
                      title: '랭킹',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: GameColors.textSecondary,
                      ),
                      onTap: widget.onSwitchToRanking,
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // 3) 계정 섹션
                  _buildAccountSection(),

                  // 4) 정보 섹션
                  _buildSectionHeader('정보'),
                  const SizedBox(height: 8),
                  _buildSectionCard(children: [
                    _buildListTile(
                      icon: Icons.shield_outlined,
                      iconColor: GameColors.textSecondary,
                      title: '개인정보 처리방침',
                      trailing: const Icon(
                        Icons.open_in_new_rounded,
                        color: GameColors.textSecondary,
                        size: 18,
                      ),
                      onTap: () => _openUrl(
                        'https://flipop.app/privacy', // placeholder URL
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.description_outlined,
                      iconColor: GameColors.textSecondary,
                      title: '이용약관',
                      trailing: const Icon(
                        Icons.open_in_new_rounded,
                        color: GameColors.textSecondary,
                        size: 18,
                      ),
                      onTap: () => _openUrl(
                        'https://flipop.app/terms', // placeholder URL
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: GameColors.textSecondary,
                      title: '앱 버전',
                      trailing: const Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // 계정 삭제 (항상 표시)
                  _buildActionButton(
                    label: '계정 삭제',
                    color: GameColors.blockColors[BlockColor.red]!,
                    onTap: _deleteAccount,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  // ── 프로필 카드 ──

  Widget _buildProfileCard() {
    final user = _user;
    final auth = AuthService();
    final avatarId = auth.avatarId ?? 'cat';
    final avatarImage = _avatarImages[avatarId] ?? 'assets/images/cat_red.png';
    final avatarColor = _avatarColors[avatarId] ?? BlockColor.red;
    final nickname = auth.nickname ?? '???';
    final countryFlag = countryCodeToFlag(auth.countryCode);
    final isAnonymous = user?.isAnonymous ?? true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.gridLine, width: 2),
      ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: GameColors.blockColors[avatarColor],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(avatarImage, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 16),

          // 닉네임 + 국기 + 프로바이더 뱃지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 + 국기
                Row(
                  children: [
                    if (countryFlag.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          countryFlag,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    Flexible(
                      child: Text(
                        nickname,
                        style: const TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 프로바이더 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAnonymous
                        ? GameColors.blockColors[BlockColor.yellow]!
                            .withValues(alpha: 0.3)
                        : GameColors.blockColors[BlockColor.green]!
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _providerLabel,
                    style: TextStyle(
                      color: isAnonymous
                          ? GameColors.textSecondary
                          : GameColors.blockColors[BlockColor.green],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 계정 섹션 (조건부) ──

  Widget _buildAccountSection() {
    final user = _user;
    final isAnonymous = user?.isAnonymous ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('계정'),
        const SizedBox(height: 8),

        if (isAnonymous) ...[
          // 익명 사용자: 소셜 연동 버튼
          _buildLinkButton(
            label: 'Google로 연동',
            icon: Icons.g_mobiledata,
            color: GameColors.blockColors[BlockColor.blue]!,
            onTap: _linkGoogle,
          ),
          const SizedBox(height: 10),
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildLinkButton(
                label: 'Apple로 연동',
                icon: Icons.apple,
                color: GameColors.textPrimary,
                onTap: _linkApple,
              ),
            ),
        ] else ...[
          // 로그인 사용자: 로그아웃
          _buildActionButton(
            label: '로그아웃',
            color: GameColors.textSecondary,
            onTap: _signOut,
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }

  // ── 공통 위젯 빌더 ──

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: GameColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.gridLine, width: 1.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: GameColors.gridLine.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildLinkButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// AuthGate로 돌아가기 위한 임시 위젯
class _RestartPlaceholder extends StatelessWidget {
  const _RestartPlaceholder();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    });
    return const Scaffold(
      backgroundColor: GameColors.background,
      body: Center(
        child: CircularProgressIndicator(color: GameColors.textSecondary),
      ),
    );
  }
}
