import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/apple_sign_in_datasource.dart';
import '../datasources/google_sign_in_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignInDatasource _googleDatasource;
  final AppleSignInDatasource _appleDatasource;

  // 인메모리 캐시
  String? _nickname;
  String? _avatarId;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignInDatasource? googleDatasource,
    AppleSignInDatasource? appleDatasource,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleDatasource = googleDatasource ?? GoogleSignInDatasource(),
        _appleDatasource = appleDatasource ?? AppleSignInDatasource();

  static final _nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,12}$');

  // ── 현재 유저 ──

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  // ── 인증 ──

  @override
  Future<AppUser> signInAnonymously() async {
    if (_auth.currentUser != null) {
      await _loadProfile();
      return _mapFirebaseUser(_auth.currentUser!);
    }
    final credential = await _auth.signInAnonymously();
    return _mapFirebaseUser(credential.user!);
  }

  @override
  Future<(AppUser?, AuthFailure?)> signInWithGoogle() async {
    try {
      final oauthCredential = await _googleDatasource.getCredential();
      if (oauthCredential == null) return (null, const AuthCancelled());

      final credential = await _auth.signInWithCredential(oauthCredential);
      await _loadProfile();
      return (_mapFirebaseUser(credential.user!), null);
    } on FirebaseAuthException catch (e) {
      return (null, _mapFirebaseError(e));
    } catch (e) {
      return (null, AuthUnknown(e.toString()));
    }
  }

  @override
  Future<(AppUser?, AuthFailure?)> signInWithApple() async {
    try {
      final oauthCredential = await _appleDatasource.getCredential();
      if (oauthCredential == null) return (null, const AuthCancelled());

      final credential = await _auth.signInWithCredential(oauthCredential);
      await _loadProfile();
      return (_mapFirebaseUser(credential.user!), null);
    } on FirebaseAuthException catch (e) {
      return (null, _mapFirebaseError(e));
    } catch (e) {
      return (null, AuthUnknown(e.toString()));
    }
  }

  // ── 소셜 연동 (익명 → 소셜 업그레이드) ──

  @override
  Future<(AppUser?, AuthFailure?)> linkWithGoogle() async {
    try {
      final oauthCredential = await _googleDatasource.getCredential();
      if (oauthCredential == null) return (null, const AuthCancelled());

      final credential =
          await _auth.currentUser!.linkWithCredential(oauthCredential);
      return (_mapFirebaseUser(credential.user!), null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return (
          null,
          AuthCredentialAlreadyInUse(email: e.email),
        );
      }
      return (null, _mapFirebaseError(e));
    } catch (e) {
      return (null, AuthUnknown(e.toString()));
    }
  }

  @override
  Future<(AppUser?, AuthFailure?)> linkWithApple() async {
    try {
      final oauthCredential = await _appleDatasource.getCredential();
      if (oauthCredential == null) return (null, const AuthCancelled());

      final credential =
          await _auth.currentUser!.linkWithCredential(oauthCredential);
      return (_mapFirebaseUser(credential.user!), null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return (
          null,
          AuthCredentialAlreadyInUse(email: e.email),
        );
      }
      return (null, _mapFirebaseError(e));
    } catch (e) {
      return (null, AuthUnknown(e.toString()));
    }
  }

  // ── 프로필 ──

  @override
  Future<void> saveProfile(String nickname, String avatarId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _nickname = nickname;
    _avatarId = avatarId;

    await _firestore.collection('users').doc(user.uid).set({
      'nickname': nickname,
      'avatarId': avatarId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> hasProfile() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await _loadProfile();
    return _nickname != null && _nickname!.isNotEmpty;
  }

  @override
  String? validateNickname(String nickname) {
    if (nickname.isEmpty) return '닉네임을 입력해주세요';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다';
    if (nickname.length > 12) return '닉네임은 12자 이하여야 합니다';
    if (!_nicknameRegex.hasMatch(nickname)) return '한글, 영문, 숫자만 사용 가능합니다';
    return null;
  }

  @override
  Future<bool> checkNicknameAvailable(String nickname) async {
    final query = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return true;

    final myUid = _auth.currentUser?.uid;
    if (myUid != null &&
        query.docs.length == 1 &&
        query.docs.first.id == myUid) {
      return true;
    }
    return false;
  }

  // ── 세션 ──

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  @override
  Future<void> signOut() async {
    await _googleDatasource.signOut();
    _clearCache();
    await _auth.signOut();
  }

  @override
  Future<(bool, AuthFailure?)> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return (false, const AuthUnknown('로그인 상태가 아닙니다'));

    try {
      // Auth 계정 삭제 (Firestore 정리는 Cloud Functions onUserDeleted가 담당)
      await user.delete();
      _clearCache();
      return (true, null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return (false, const AuthRequiresRecentLogin());
      }
      return (false, _mapFirebaseError(e));
    } catch (e) {
      return (false, AuthUnknown(e.toString()));
    }
  }

  // ── 스트림 ──

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  // ── 내부 헬퍼 ──

  AppUser _mapFirebaseUser(User user) {
    final provider = _resolveProvider(user);
    return AppUser(
      uid: user.uid,
      email: user.email,
      provider: provider,
      nickname: _nickname,
      avatarId: _avatarId,
    );
  }

  SignInProvider _resolveProvider(User user) {
    for (final info in user.providerData) {
      if (info.providerId == 'google.com') return SignInProvider.google;
      if (info.providerId == 'apple.com') return SignInProvider.apple;
    }
    return SignInProvider.anonymous;
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _nickname = doc.data()?['nickname'] as String?;
      _avatarId = doc.data()?['avatarId'] as String?;
    }
  }

  void _clearCache() {
    _nickname = null;
    _avatarId = null;
  }

  AuthFailure _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'network-request-failed' => const AuthNetworkError(),
      'credential-already-in-use' =>
        AuthCredentialAlreadyInUse(email: e.email),
      'requires-recent-login' => const AuthRequiresRecentLogin(),
      _ => AuthUnknown(e.message ?? e.code),
    };
  }

  // facade 호환 getter
  String? get nickname => _nickname;
  String? get avatarId => _avatarId;
}
