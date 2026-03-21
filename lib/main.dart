import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'firebase_options.dart';
import 'di/service_locator.dart';
import 'services/ad_service.dart';
import 'services/sound_service.dart';
import 'services/auth_service.dart';
import 'services/iap_service.dart';
import 'services/remote_config_service.dart';
import 'services/secure_storage_service.dart';
import 'ui/force_update_screen.dart';
import 'ui/home_screen.dart';
import 'ui/main_screen.dart';
import 'ui/maintenance_screen.dart';
import 'ui/nickname_screen.dart';
import 'ui/tutorial_screen.dart';
import 'ui/welcome_screen.dart';
import 'l10n/app_localizations.dart';
import 'game/game_state.dart';
import 'game/game_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics 초기화 (디버그 모드에서 비활성화)
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 디버그 모드에서 Analytics 수집 비활성화
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  ServiceLocator().init();
  await RemoteConfigService().initialize();
  await IAPService().initialize();
  await SoundService().initialize();
  await AdService().initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,         // iOS
      statusBarIconBrightness: Brightness.dark,       // Android
      systemNavigationBarColor: Color(0xFFF8F5F0),   // Android bottom nav
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FlipopApp());
}

/// 다크모드 상태를 위젯 트리에 전달하는 InheritedWidget
class DarkModeProvider extends InheritedWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const DarkModeProvider({
    super.key,
    required this.themeModeNotifier,
    required super.child,
  });

  static DarkModeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DarkModeProvider>()!;
  }

  static DarkModeProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DarkModeProvider>();
  }

  @override
  bool updateShouldNotify(DarkModeProvider oldWidget) =>
      themeModeNotifier != oldWidget.themeModeNotifier;
}

class FlipopApp extends StatefulWidget {
  const FlipopApp({super.key});

  @override
  State<FlipopApp> createState() => _FlipopAppState();
}

class _FlipopAppState extends State<FlipopApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final value = await SecureStorageService().getDarkMode();
    if (value == 'true') {
      _themeModeNotifier.value = ThemeMode.dark;
    } else if (value == 'false') {
      _themeModeNotifier.value = ThemeMode.light;
    } else {
      _themeModeNotifier.value = ThemeMode.system;
    }
  }

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DarkModeProvider(
      themeModeNotifier: _themeModeNotifier,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'FLIPOP',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: GameColors.blockColors[BlockColor.blue]!,
                surface: GameColors.background,
              ),
              fontFamily: 'SF Pro Rounded',
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: GameColors.blockColors[BlockColor.blue]!,
                brightness: Brightness.dark,
                surface: GameColors.backgroundDark,
              ),
              fontFamily: 'SF Pro Rounded',
              brightness: Brightness.dark,
            ),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => const AuthGate(),
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }
}

/// 로그인 상태에 따라 홈 / 닉네임 / 게임 화면 분기
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

enum _Screen {
  loading,
  forceUpdate,
  maintenance,
  welcome,
  home,
  nickname,
  tutorial,
  game,
}

class _AuthGateState extends State<AuthGate> {
  _Screen _screen = _Screen.loading;
  bool _imagesCached = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesCached) {
      _imagesCached = true;
      for (final path in GameColors.blockImages.values) {
        precacheImage(AssetImage(path), context);
      }
    }
  }

  Future<void> _checkAuth() async {
    try {
      // 점검 모드 체크
      final rc = RemoteConfigService();
      if (rc.maintenanceMode) {
        if (mounted) setState(() => _screen = _Screen.maintenance);
        return;
      }

      // 강제 업데이트 체크
      final forceVersion = rc.forceUpdateVersion;
      if (forceVersion != '0.0.0' && forceVersion.isNotEmpty) {
        final info = await PackageInfo.fromPlatform();
        if (_shouldForceUpdate(info.version, forceVersion)) {
          if (mounted) setState(() => _screen = _Screen.forceUpdate);
          return;
        }
      }

      final auth = AuthService();
      if (auth.isSignedIn) {
        final hasProfile = await auth.hasProfile();
        if (mounted) {
          setState(() {
            _screen = hasProfile ? _Screen.game : _Screen.nickname;
          });
        }
      } else {
        final hasSeenWelcome = await SecureStorageService().hasSeenWelcome();
        if (mounted) {
          setState(() {
            _screen = hasSeenWelcome ? _Screen.home : _Screen.welcome;
          });
        }
      }
    } catch (e) {
      // Firebase 오류 시 홈 화면 표시
      if (mounted) setState(() => _screen = _Screen.home);
    }
  }

  /// 현재 버전이 강제 업데이트 버전보다 낮은지 확인
  bool _shouldForceUpdate(String current, String required) {
    final cur = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final req = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final c = i < cur.length ? cur[i] : 0;
      final r = i < req.length ? req[i] : 0;
      if (c < r) return true;
      if (c > r) return false;
    }
    return false; // 동일 버전이면 업데이트 불필요
  }

  /// 비로그인(익명) 시작 → 튜토리얼/게임
  Future<void> _onGuestStart() async {
    final seenOnboarding = await SecureStorageService().hasSeenOnboarding();
    if (mounted) {
      setState(() {
        _screen = seenOnboarding ? _Screen.game : _Screen.tutorial;
      });
    }
  }

  /// WelcomeScreen: 로그인 없이 시작 (익명 로그인 → 튜토리얼/게임)
  Future<void> _startAsGuest() async {
    await SecureStorageService().setSeenWelcome();
    try {
      await AuthService().signInAnonymously();
    } catch (_) {
      // 익명 로그인 실패해도 게임 진입 허용
    }
    if (mounted) {
      final seenOnboarding = await SecureStorageService().hasSeenOnboarding();
      setState(() {
        _screen = seenOnboarding ? _Screen.game : _Screen.tutorial;
      });
    }
  }

  /// WelcomeScreen: Google 로그인
  Future<void> _onWelcomeGoogleSignIn() async {
    final (user, failure) = await AuthService().signInWithGoogle();
    if (failure != null || user == null) return;
    await SecureStorageService().setSeenWelcome();
    final hasProfile = await AuthService().hasProfile();
    if (mounted) {
      if (!hasProfile) {
        setState(() => _screen = _Screen.nickname);
      } else {
        final seenOnboarding = await SecureStorageService().hasSeenOnboarding();
        setState(() {
          _screen = seenOnboarding ? _Screen.game : _Screen.tutorial;
        });
      }
    }
  }

  /// WelcomeScreen: Apple 로그인
  Future<void> _onWelcomeAppleSignIn() async {
    final (user, failure) = await AuthService().signInWithApple();
    if (failure != null || user == null) return;
    await SecureStorageService().setSeenWelcome();
    final hasProfile = await AuthService().hasProfile();
    if (mounted) {
      if (!hasProfile) {
        setState(() => _screen = _Screen.nickname);
      } else {
        final seenOnboarding = await SecureStorageService().hasSeenOnboarding();
        setState(() {
          _screen = seenOnboarding ? _Screen.game : _Screen.tutorial;
        });
      }
    }
  }

  /// 소셜 로그인 성공
  void _onSocialLogin(bool hasProfile) {
    setState(() {
      _screen = hasProfile ? _Screen.game : _Screen.nickname;
    });
  }

  /// 닉네임 설정 완료 → 튜토리얼/게임
  Future<void> _onNicknameComplete() async {
    final seenOnboarding = await SecureStorageService().hasSeenOnboarding();
    if (mounted) {
      setState(() {
        _screen = seenOnboarding ? _Screen.game : _Screen.tutorial;
      });
    }
  }

  /// 튜토리얼 완료
  void _onTutorialComplete() {
    setState(() => _screen = _Screen.game);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case _Screen.loading:
        return const Scaffold(
          backgroundColor: GameColors.background,
          body: Center(
            child: CircularProgressIndicator(
              color: GameColors.textSecondary,
            ),
          ),
        );
      case _Screen.forceUpdate:
        return const ForceUpdateScreen();
      case _Screen.maintenance:
        return const MaintenanceScreen();
      case _Screen.welcome:
        return WelcomeScreen(
          onSkip: _startAsGuest,
          onGoogleSignIn: _onWelcomeGoogleSignIn,
          onAppleSignIn: _onWelcomeAppleSignIn,
        );
      case _Screen.home:
        return HomeScreen(
          onGuestStart: _onGuestStart,
          onSocialLogin: _onSocialLogin,
        );
      case _Screen.nickname:
        return NicknameScreen(onComplete: _onNicknameComplete);
      case _Screen.tutorial:
        return TutorialScreen(onComplete: _onTutorialComplete);
      case _Screen.game:
        return const MainScreen();
    }
  }
}
