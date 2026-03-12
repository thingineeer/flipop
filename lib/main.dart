import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'di/service_locator.dart';
import 'services/ad_service.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'ui/game_screen.dart';
import 'ui/home_screen.dart';
import 'ui/nickname_screen.dart';
import 'ui/welcome_screen.dart';
import 'game/game_state.dart';
import 'game/game_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 디버그 모드에서 Analytics 수집 비활성화
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  ServiceLocator().init();
  await AdService().initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FlipopApp());
}

class FlipopApp extends StatelessWidget {
  const FlipopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLIPOP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameColors.blockColors[BlockColor.blue]!,
          surface: GameColors.background,
        ),
        fontFamily: 'SF Pro Rounded',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
      },
    );
  }
}

/// 로그인 상태에 따라 홈 / 닉네임 / 게임 화면 분기
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

enum _Screen { loading, welcome, home, nickname, game }

class _AuthGateState extends State<AuthGate> {
  _Screen _screen = _Screen.loading;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
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

  /// 비로그인(익명) 시작 → 바로 게임
  void _onGuestStart() {
    setState(() => _screen = _Screen.game);
  }

  /// WelcomeScreen: 로그인 없이 시작 (익명 로그인 → 게임)
  Future<void> _startAsGuest() async {
    await SecureStorageService().setSeenWelcome();
    try {
      await AuthService().signInAnonymously();
    } catch (_) {
      // 익명 로그인 실패해도 게임 진입 허용
    }
    if (mounted) setState(() => _screen = _Screen.game);
  }

  /// WelcomeScreen: Google 로그인
  Future<void> _onWelcomeGoogleSignIn() async {
    final (user, failure) = await AuthService().signInWithGoogle();
    if (failure != null || user == null) return;
    await SecureStorageService().setSeenWelcome();
    final hasProfile = await AuthService().hasProfile();
    if (mounted) {
      setState(() {
        _screen = hasProfile ? _Screen.game : _Screen.nickname;
      });
    }
  }

  /// WelcomeScreen: Apple 로그인
  Future<void> _onWelcomeAppleSignIn() async {
    final (user, failure) = await AuthService().signInWithApple();
    if (failure != null || user == null) return;
    await SecureStorageService().setSeenWelcome();
    final hasProfile = await AuthService().hasProfile();
    if (mounted) {
      setState(() {
        _screen = hasProfile ? _Screen.game : _Screen.nickname;
      });
    }
  }

  /// 소셜 로그인 성공
  void _onSocialLogin(bool hasProfile) {
    setState(() {
      _screen = hasProfile ? _Screen.game : _Screen.nickname;
    });
  }

  /// 닉네임 설정 완료
  void _onNicknameComplete() {
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
      case _Screen.game:
        return const GameScreen();
    }
  }
}
