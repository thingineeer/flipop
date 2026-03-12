import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  String? _nickname;
  String? _avatarId;

  String? get nickname => _nickname;
  String? get avatarId => _avatarId;

  /// 익명 로그인
  Future<User> signInAnonymously() async {
    if (_auth.currentUser != null) {
      await _loadProfile();
      return _auth.currentUser!;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user!;
  }

  /// 프로필(닉네임+아바타) 저장
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

  /// 프로필 로드
  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _nickname = doc.data()?['nickname'] as String?;
      _avatarId = doc.data()?['avatarId'] as String?;
    }
  }

  /// 프로필 존재 여부 확인
  Future<bool> hasProfile() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await _loadProfile();
    return _nickname != null && _nickname!.isNotEmpty;
  }
}
