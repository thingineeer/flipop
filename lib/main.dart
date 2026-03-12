import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';
import 'services/auth_service.dart';
import 'ui/game_screen.dart';
import 'ui/nickname_screen.dart';
import 'game/game_state.dart';
import 'game/game_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const AuthGate(),
    );
  }
}

/// 로그인 상태에 따라 닉네임 화면 / 게임 화면 분기
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _needsNickname = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await AuthService().signInAnonymously();
      final hasProfile = await AuthService().hasProfile();
      if (mounted) {
        setState(() {
          _needsNickname = !hasProfile;
          _loading = false;
        });
      }
    } catch (e) {
      // Firebase 오류 시 게임은 플레이 가능하게
      if (mounted) {
        setState(() {
          _needsNickname = false;
          _loading = false;
        });
      }
    }
  }

  void _onNicknameComplete() {
    setState(() => _needsNickname = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: GameColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: GameColors.textSecondary,
          ),
        ),
      );
    }

    if (_needsNickname) {
      return NicknameScreen(onComplete: _onNicknameComplete);
    }

    return const GameScreen();
  }
}
