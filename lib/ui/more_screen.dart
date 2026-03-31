import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/entities/app_user.dart';
import '../domain/failures/auth_failure.dart';
import '../game/avatar_data.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/iap_service.dart';
import '../services/leaderboard_service.dart';
import '../services/daily_bonus_service.dart';
import '../services/secure_storage_service.dart';
import '../services/sound_service.dart';
import '../main.dart';
import 'achievement_screen.dart';

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
  String _appVersion = '';
  Set<String> _unlockedAvatars = {};
  bool _adsRemoved = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUnlockedAvatars();
    _loadCoins();
    _adsRemoved = IAPService().adsRemoved;
    _musicEnabled = SoundService().musicEnabled;
    _sfxEnabled = SoundService().sfxEnabled;
  }

  Future<void> _loadUnlockedAvatars() async {
    final unlocked = await SecureStorageService().getUnlockedAvatars();
    if (mounted) {
      setState(() => _unlockedAvatars = unlocked);
    }
  }

  Future<void> _loadCoins() async {
    final coins = await DailyBonusService().getCoins();
    if (mounted) {
      setState(() => _coins = coins);
    }
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = 'v${info.version}');
    }
  }

  AppUser? get _user => AuthService().appUser;

  String _providerLabel(AppLocalizations l) {
    final user = _user;
    if (user == null) return l.notLoggedIn;
    return switch (user.provider) {
      SignInProvider.google => 'Google',
      SignInProvider.apple => 'Apple',
      SignInProvider.anonymous => l.guest,
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

  // ── 로그아웃 / 계정 삭제 ──

  Future<void> _signOut() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      title: l.logoutTitle,
      message: l.logoutMessage,
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
    final l = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog(
      title: l.deleteTitle,
      message: l.deleteMessage,
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

  // ── IAP 구매 ──

  Future<void> _purchaseRemoveAds() async {
    setState(() => _loading = true);
    try {
      await IAPService().purchaseRemoveAds();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseFailed),
            backgroundColor: GameColors.blockColors[BlockColor.red],
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _adsRemoved = IAPService().adsRemoved;
      });
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _loading = true);
    try {
      await IAPService().restorePurchases();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseFailed),
          ),
        );
      }
    }
    // 잠시 대기 후 상태 갱신 (스트림 콜백 처리 시간)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _loading = false;
        _adsRemoved = IAPService().adsRemoved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.restoreComplete),
        ),
      );
    }
  }

  // ── URL 오픈 ──

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── 유틸 ──

  String _friendlyErrorMessage(Object e) {
    final l10n = AppLocalizations.of(context)!;
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return l10n.errorNetwork;
    }
    if (msg.contains('permission')) {
      return l10n.errorPermission;
    }
    return l10n.errorGeneric;
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

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: GameColors.getBackground(isDark),
      body: SafeArea(
        bottom: false, // 탭 바가 하단 처리
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: GameColors.textSecondary,
                ),
              )
            : Builder(builder: (context) {
                final l = AppLocalizations.of(context)!;
                return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  // 타이틀
                  Text(
                    l.moreTitle,
                    style: const TextStyle(
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
                  _buildSectionHeader(l.gameSection),
                  const SizedBox(height: 8),
                  _buildSectionCard(children: [
                    _buildListTile(
                      icon: Icons.emoji_events_rounded,
                      iconColor: GameColors.blockColors[BlockColor.yellow]!,
                      title: l.ranking,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: GameColors.textSecondary,
                      ),
                      onTap: widget.onSwitchToRanking,
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.military_tech_rounded,
                      iconColor: GameColors.blockColors[BlockColor.red]!,
                      title: l.meta_achievements,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_coins ${l.meta_coins}',
                            style: TextStyle(
                              color: GameColors.blockColors[BlockColor.yellow],
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: GameColors.textSecondary,
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AchievementScreen(),
                          ),
                        );
                        _loadCoins();
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.music_note_rounded,
                      iconColor: GameColors.blockColors[BlockColor.blue]!,
                      title: l.soundMusic,
                      value: _musicEnabled,
                      onChanged: (v) async {
                        setState(() => _musicEnabled = v);
                        await SoundService().setMusicEnabled(v);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.volume_up_rounded,
                      iconColor: GameColors.blockColors[BlockColor.green]!,
                      title: l.soundSfx,
                      value: _sfxEnabled,
                      onChanged: (v) async {
                        setState(() => _sfxEnabled = v);
                        await SoundService().setSFXEnabled(v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // 2.5) 설정 섹션 (다크 모드)
                  _buildSettingsSection(l),

                  // 3) 구매 섹션
                  _buildPurchaseSection(l),

                  // 4) 계정 섹션
                  _buildAccountSection(),

                  // 4.5) 친구 초대
                  _buildInviteSection(l),

                  // 5) 정보 섹션
                  _buildSectionHeader(l.infoSection),
                  const SizedBox(height: 8),
                  _buildSectionCard(children: [
                    _buildListTile(
                      icon: Icons.shield_outlined,
                      iconColor: GameColors.textSecondary,
                      title: l.privacyPolicy,
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
                      title: l.termsOfService,
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
                      title: l.appVersion,
                      trailing: Text(
                        _appVersion,
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.article_outlined,
                      iconColor: GameColors.textSecondary,
                      title: l.openSourceLicenses,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: GameColors.textSecondary,
                      ),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'FLIPOP',
                        applicationVersion: _appVersion,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // 계정 삭제 (항상 표시)
                  _buildActionButton(
                    label: l.deleteAccount,
                    color: GameColors.blockColors[BlockColor.red]!,
                    onTap: _deleteAccount,
                  ),
                  const SizedBox(height: 40),
                ],
              );
              }),
      ),
    );
  }

  // ── 프로필 카드 ──

  // ── 아바타 선택 BottomSheet ──

  void _showAvatarPicker() {
    final auth = AuthService();
    String selectedId = auth.avatarId ?? 'cat';

    showModalBottomSheet(
      context: context,
      backgroundColor: GameColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핸들 바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: GameColors.gridLine,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 타이틀
                  Text(
                    AppLocalizations.of(context)!.avatarPicker,
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 기본 섹션
                  _buildAvatarSectionLabel(AppLocalizations.of(context)!.avatarBasic),
                  const SizedBox(height: 8),
                  _buildAvatarGrid(
                    AvatarData.basicAvatars,
                    selectedId,
                    onSelect: (id) => setSheetState(() => selectedId = id),
                  ),
                  const SizedBox(height: 16),

                  // 추가 섹션
                  _buildAvatarSectionLabel(AppLocalizations.of(context)!.avatarExtra),
                  const SizedBox(height: 8),
                  _buildAvatarGrid(
                    AvatarData.extraAvatars,
                    selectedId,
                    onSelect: (id) => setSheetState(() => selectedId = id),
                  ),
                  const SizedBox(height: 16),

                  // 특별 섹션 (광고 시청으로 해금)
                  _buildAvatarSectionLabel(AppLocalizations.of(context)!.avatarSpecial),
                  const SizedBox(height: 8),
                  _buildAvatarGrid(
                    AvatarData.specialAvatars,
                    selectedId,
                    adUnlockable: true,
                    onSelect: (id) => setSheetState(() => selectedId = id),
                    onAdUnlock: (id) async {
                      AdService().showRewardedAd(
                        onRewarded: () async {
                          await SecureStorageService().unlockAvatar(id);
                          final unlocked = await SecureStorageService().getUnlockedAvatars();
                          AnalyticsService().logAdWatched(type: 'rewarded_avatar_$id');
                          if (mounted) {
                            setState(() => _unlockedAvatars = unlocked);
                            setSheetState(() => selectedId = id);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 저장 버튼
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _saveAvatar(selectedId);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: GameColors.blockColors[BlockColor.blue],
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.blockColors[BlockColor.blue]!
                                .withValues(alpha: 0.3),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: GameColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildAvatarGrid(
    List<String> avatarIds,
    String selectedId, {
    bool adUnlockable = false,
    required ValueChanged<String> onSelect,
    ValueChanged<String>? onAdUnlock,
  }) {
    return Row(
      children: avatarIds.map((id) {
        final isAvailable = AvatarData.availableAvatars.contains(id);
        final isUnlockedByAd = _unlockedAvatars.contains(id);
        final locked = adUnlockable ? (!isUnlockedByAd) : !isAvailable;
        final isSelected = id == selectedId;
        final image = AvatarData.images[id] ?? 'assets/images/cat_red.png';
        final color = AvatarData.avatarColors[id] ?? BlockColor.red;

        return Expanded(
          child: GestureDetector(
            onTap: locked
                ? (adUnlockable ? () => onAdUnlock?.call(id) : null)
                : () => onSelect(id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: locked
                    ? GameColors.gridBackground
                    : GameColors.blockColors[color]?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected && !locked
                      ? GameColors.blockColors[color] ?? GameColors.gridLine
                      : GameColors.gridLine,
                  width: isSelected && !locked ? 2.5 : 1.5,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    // 아바타 이미지
                    if (isAvailable || isUnlockedByAd)
                      Center(
                        child: Opacity(
                          opacity: locked ? 0.3 : 1.0,
                          child: Image.asset(image, fit: BoxFit.contain),
                        ),
                      ),

                    // 잠금 오버레이
                    if (locked)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              adUnlockable
                                  ? Icons.play_circle_filled_rounded
                                  : Icons.lock_rounded,
                              color: adUnlockable
                                  ? GameColors.blockColors[BlockColor.yellow]
                                  : GameColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              adUnlockable
                                  ? AppLocalizations.of(context)!.watchAd
                                  : (AvatarData.unlockConditions[id] ??
                                      AppLocalizations.of(context)!.comingSoon),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: adUnlockable
                                    ? GameColors.blockColors[BlockColor.yellow]
                                    : GameColors.textSecondary,
                                fontSize: adUnlockable ? 8 : 7,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveAvatar(String avatarId) async {
    final auth = AuthService();
    final nickname = auth.nickname ?? '???';
    final countryCode = _user?.countryCode;

    setState(() => _loading = true);
    try {
      await auth.saveProfile(nickname, avatarId, countryCode: countryCode);
      if (mounted) {
        setState(() => _loading = false);
        _showSuccess(AppLocalizations.of(context)!.avatarChanged);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyErrorMessage(e))),
        );
      }
    }
  }

  Widget _buildProfileCard() {
    final user = _user;
    final auth = AuthService();
    final avatarId = auth.avatarId ?? 'cat';
    final avatarImage =
        AvatarData.images[avatarId] ?? 'assets/images/cat_red.png';
    final avatarColor = AvatarData.avatarColors[avatarId] ?? BlockColor.red;
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
          // 아바타 (탭하면 선택 BottomSheet)
          GestureDetector(
            onTap: _showAvatarPicker,
            child: Stack(
              children: [
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
                // 편집 아이콘
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: GameColors.textPrimary,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: GameColors.gridBackground,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
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
                    _providerLabel(AppLocalizations.of(context)!),
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

  // ── 설정 섹션 (다크 모드) ──

  Widget _buildSettingsSection(AppLocalizations l) {
    final provider = DarkModeProvider.maybeOf(context);
    if (provider == null) return const SizedBox.shrink();

    final notifier = provider.themeModeNotifier;
    final isDarkOn = notifier.value == ThemeMode.dark ||
        (notifier.value == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l.ui_settingsSection),
        const SizedBox(height: 8),
        _buildSectionCard(children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            iconColor: GameColors.blockColors[BlockColor.blue]!,
            title: l.ui_darkMode,
            value: isDarkOn,
            onChanged: (v) async {
              final newMode = v ? ThemeMode.dark : ThemeMode.light;
              notifier.value = newMode;
              await SecureStorageService()
                  .setDarkMode(v ? 'true' : 'false');
              if (mounted) setState(() {});
            },
          ),
        ]),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── 구매 섹션 ──

  Widget _buildPurchaseSection(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l.purchaseSection),
        const SizedBox(height: 8),
        _buildSectionCard(children: [
          _buildListTile(
            icon: _adsRemoved
                ? Icons.check_circle_rounded
                : Icons.block_rounded,
            iconColor: _adsRemoved
                ? GameColors.blockColors[BlockColor.green]!
                : GameColors.blockColors[BlockColor.yellow]!,
            title: _adsRemoved ? l.adsRemoved : l.removeAds,
            trailing: _adsRemoved
                ? null
                : Text(
                    l.removeAdsPrice,
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            onTap: _adsRemoved ? null : _purchaseRemoveAds,
          ),
          _buildDivider(),
          _buildListTile(
            icon: IAPService().avatarPack
                ? Icons.check_circle_rounded
                : Icons.auto_awesome_rounded,
            iconColor: IAPService().avatarPack
                ? GameColors.blockColors[BlockColor.green]!
                : GameColors.blockColors[BlockColor.blue]!,
            title: IAPService().avatarPack
                ? l.avatarPackOwned
                : l.avatarPack,
            trailing: IAPService().avatarPack
                ? null
                : Text(
                    l.avatarPackPrice,
                    style: const TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            onTap: IAPService().avatarPack
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      await IAPService().purchaseAvatarPack();
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.purchaseFailed),
                          ),
                        );
                      }
                    }
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.restore_rounded,
            iconColor: GameColors.textSecondary,
            title: l.restorePurchases,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: GameColors.textSecondary,
            ),
            onTap: _restorePurchases,
          ),
        ]),
        const SizedBox(height: 28),
      ],
    );
  }

  // ── 계정 섹션 (조건부) ──

  Widget _buildAccountSection() {
    final user = _user;
    final isAnonymous = user?.isAnonymous ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(AppLocalizations.of(context)!.accountSection),
        const SizedBox(height: 8),

        if (isAnonymous) ...[
          // 익명 사용자: 소셜 연동 버튼
          _buildLinkButton(
            label: AppLocalizations.of(context)!.linkGoogle,
            icon: Icons.g_mobiledata,
            color: GameColors.blockColors[BlockColor.blue]!,
            onTap: _linkGoogle,
          ),
          const SizedBox(height: 10),
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildLinkButton(
                label: AppLocalizations.of(context)!.linkApple,
                icon: Icons.apple,
                color: GameColors.textPrimary,
                onTap: _linkApple,
              ),
            ),
        ] else ...[
          // 로그인 사용자: 로그아웃
          _buildActionButton(
            label: AppLocalizations.of(context)!.logout,
            color: GameColors.textSecondary,
            onTap: _signOut,
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }

  // ── 친구 초대 섹션 ──

  Widget _buildInviteSection(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final message = l.social_inviteMessage;
            // 앱스토어 링크 (placeholder)
            const appLink = 'https://apps.apple.com/app/flipop/id6744066907';
            Share.share('$message\n$appLink');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.green],
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: GameColors.blockDarkColors[BlockColor.green]!
                      .withValues(alpha: 0.4),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.social_inviteFriends,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: GameColors.blockColors[BlockColor.blue],
          ),
        ],
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
