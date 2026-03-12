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

  /// 닉네임 정규표현식 검증
  /// 2~12자, 한글/영문/숫자만 허용, 공백/특수문자/이모지 불가
  static final _nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,12}$');

  /// 닉네임 유효성 검증. 유효하면 null, 아니면 에러 메시지 반환.
  String? validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (nickname.length < 2) {
      return '닉네임은 2자 이상이어야 합니다';
    }
    if (nickname.length > 12) {
      return '닉네임은 12자 이하여야 합니다';
    }
    if (!_nicknameRegex.hasMatch(nickname)) {
      return '한글, 영문, 숫자만 사용 가능합니다';
    }
    return null;
  }

  /// 닉네임 중복 체크. 사용 가능하면 true, 중복이면 false.
  /// 자기 자신의 uid는 제외.
  Future<bool> checkNicknameAvailable(String nickname) async {
    final query = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return true;

    // 자기 자신이면 허용
    final myUid = _auth.currentUser?.uid;
    if (myUid != null && query.docs.length == 1 && query.docs.first.id == myUid) {
      return true;
    }

    return false;
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
