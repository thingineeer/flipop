import '../entities/app_user.dart';
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  // 인증
  Future<AppUser> signInAnonymously();
  Future<(AppUser?, AuthFailure?)> signInWithGoogle();
  Future<(AppUser?, AuthFailure?)> signInWithApple();

  // 소셜 연동 (익명 → 소셜 업그레이드)
  Future<(AppUser?, AuthFailure?)> linkWithGoogle();
  Future<(AppUser?, AuthFailure?)> linkWithApple();

  // 프로필
  Future<void> saveProfile(String nickname, String avatarId, {String? countryCode});
  Future<bool> hasProfile();
  String? validateNickname(String nickname);
  Future<bool> checkNicknameAvailable(String nickname);

  // 세션
  Future<String?> getIdToken({bool forceRefresh = false});
  Future<void> signOut();
  Future<(bool, AuthFailure?)> deleteAccount();

  // 스트림
  Stream<AppUser?> authStateChanges();

  // 현재 유저
  AppUser? get currentUser;
}
