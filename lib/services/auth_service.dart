import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';

import '../di/service_locator.dart';
import '../domain/entities/app_user.dart';
import '../domain/failures/auth_failure.dart';
import '../domain/repositories/auth_repository.dart';

/// AuthService — facade 패턴
/// 기존 UI 코드(game_screen, nickname_screen 등)와의 호환성 유지
/// 내부적으로 AuthRepository에 위임
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  AuthRepository get _repo => ServiceLocator().authRepository;

  User? get currentUser => FirebaseAuth.instance.currentUser;
  bool get isSignedIn => FirebaseAuth.instance.currentUser != null;
  bool get isAnonymous => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  String? get nickname => _repo.currentUser?.nickname;
  String? get avatarId => _repo.currentUser?.avatarId;

  /// 현재 AppUser
  AppUser? get appUser => _repo.currentUser;

  /// 기기 locale에서 국가코드 가져오기
  String? get countryCode {
    final locale = PlatformDispatcher.instance.locale;
    final code = locale.countryCode;
    if (code != null && code.length == 2) return code;
    return null;
  }

  /// 익명 로그인
  Future<User> signInAnonymously() async {
    await _repo.signInAnonymously();
    return FirebaseAuth.instance.currentUser!;
  }

  /// 소셜 로그인
  Future<(AppUser?, AuthFailure?)> signInWithGoogle() => _repo.signInWithGoogle();
  Future<(AppUser?, AuthFailure?)> signInWithApple() => _repo.signInWithApple();

  /// 소셜 연동 (익명 → 소셜 업그레이드)
  Future<(AppUser?, AuthFailure?)> linkWithGoogle() => _repo.linkWithGoogle();
  Future<(AppUser?, AuthFailure?)> linkWithApple() => _repo.linkWithApple();

  /// 닉네임 검증
  String? validateNickname(String nickname) => _repo.validateNickname(nickname);

  /// 닉네임 중복 체크
  Future<bool> checkNicknameAvailable(String nickname) =>
      _repo.checkNicknameAvailable(nickname);

  /// 프로필 저장
  Future<void> saveProfile(String nickname, String avatarId, {String? countryCode}) =>
      _repo.saveProfile(nickname, avatarId, countryCode: countryCode);

  /// 프로필 존재 여부
  Future<bool> hasProfile() => _repo.hasProfile();

  /// 로그아웃
  Future<void> signOut() => _repo.signOut();

  /// 계정 삭제
  Future<(bool, AuthFailure?)> deleteAccount() => _repo.deleteAccount();

  /// ID 토큰
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _repo.getIdToken(forceRefresh: forceRefresh);

  /// auth 상태 변경 스트림
  Stream<AppUser?> authStateChanges() => _repo.authStateChanges();
}
