import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../domain/entities/app_user.dart';
import '../domain/failures/auth_failure.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = false;

  AppUser? get _user => AuthService().appUser;

  String _providerLabel(AppLocalizations l10n) {
    final user = _user;
    if (user == null) return l10n.notLoggedIn;
    return switch (user.provider) {
      SignInProvider.google => l10n.googleAccount,
      SignInProvider.apple => l10n.appleAccount,
      SignInProvider.anonymous => l10n.guest,
    };
  }

  String _providerDetail(AppLocalizations l10n) {
    final user = _user;
    if (user == null || user.isAnonymous) {
      return l10n.accountLinkHint;
    }
    return user.email ?? '';
  }

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
      _showSuccess(AppLocalizations.of(context)!.googleLinked);
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
      _showSuccess(AppLocalizations.of(context)!.appleLinked);
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      title: l10n.logoutTitle,
      message: l10n.logoutMessage,
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    await AuthService().signOut();
    if (!mounted) return;

    // 앱 재시작 (AuthGate로 돌아감)
    Navigator.of(context).popUntil((route) => route.isFirst);
    // main.dart의 AuthGate가 다시 initAuth를 수행
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _RestartPlaceholder()),
    );
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      title: l10n.deleteTitle,
      message: l10n.deleteMessage,
      destructive: true,
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    final (success, failure) = await AuthService().deleteAccount();
    if (!mounted) return;
    setState(() => _loading = false);

    if (failure != null) {
      if (failure is AuthRequiresRecentLogin) {
        _showError(failure);
        // 재로그인 후 재시도 필요 → 사용자에게 안내
        return;
      }
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

  Future<void> _changeCountry() async {
    final currentCode = _user?.countryCode ??
        PlatformDispatcher.instance.locale.countryCode ??
        'KR';

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempSelected = currentCode;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: GameColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.of(context)!.changeCountry,
              style: const TextStyle(
                color: GameColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final (code, name) = _countries[index];
                  final flag = countryCodeToFlag(code);
                  final isSelected = tempSelected == code;
                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: isSelected
                            ? GameColors.blockColors[BlockColor.blue]
                            : GameColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: GameColors.blockColors[BlockColor.blue],
                          )
                        : null,
                    onTap: () {
                      setDialogState(() => tempSelected = code);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, tempSelected),
                child: Text(
                  AppLocalizations.of(context)!.change,
                  style: TextStyle(
                    color: GameColors.blockColors[BlockColor.blue],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected == currentCode) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      final nickname = _user?.nickname ?? '';
      final avatarId = _user?.avatarId ?? 'cat';
      await AuthService().saveProfile(nickname, avatarId, countryCode: selected);
      if (mounted) {
        setState(() => _loading = false);
        _showSuccess(AppLocalizations.of(context)!.countryChanged);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('변경 실패: $e')),
        );
      }
    }
  }

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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              destructive ? AppLocalizations.of(context)!.delete : AppLocalizations.of(context)!.confirm,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _user;
    final isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GameColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: GameColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: GameColors.textSecondary,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // 계정 정보 카드
                    _buildAccountCard(),
                    const SizedBox(height: 24),

                    // 소셜 연동 (익명일 때만)
                    if (isAnonymous) ...[
                      Text(
                        l10n.linkAccount,
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkButton(
                        label: l10n.linkGoogle,
                        icon: Icons.g_mobiledata,
                        color: GameColors.blockColors[BlockColor.blue]!,
                        onTap: _linkGoogle,
                      ),
                      const SizedBox(height: 10),
                      if (Platform.isIOS)
                        _buildLinkButton(
                          label: l10n.linkApple,
                          icon: Icons.apple,
                          color: GameColors.textPrimary,
                          onTap: _linkApple,
                        ),
                      const SizedBox(height: 24),
                    ],

                    const Spacer(),

                    // 하단 버튼들
                    if (!isAnonymous)
                      _buildActionButton(
                        label: l10n.logout,
                        color: GameColors.textSecondary,
                        onTap: _signOut,
                      ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: l10n.deleteAccount,
                      color: GameColors.blockColors[BlockColor.red]!,
                      onTap: _deleteAccount,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAccountCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.gridLine, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_user?.isAnonymous ?? true)
                      ? GameColors.blockColors[BlockColor.yellow]!
                          .withValues(alpha: 0.3)
                      : GameColors.blockColors[BlockColor.green]!
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _providerLabel(l10n),
                  style: TextStyle(
                    color: (_user?.isAnonymous ?? true)
                        ? GameColors.textSecondary
                        : GameColors.blockColors[BlockColor.green],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_user?.nickname != null)
            Row(
              children: [
                if (_user?.countryCode != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      countryCodeToFlag(_user!.countryCode),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                Expanded(
                  child: Text(
                    _user!.nickname!,
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _changeCountry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GameColors.blockColors[BlockColor.blue]!
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.changeCountry,
                      style: TextStyle(
                        color: GameColors.blockColors[BlockColor.blue],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Text(
            _providerDetail(l10n),
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
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
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
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
    // 즉시 AuthGate를 다시 표시
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
