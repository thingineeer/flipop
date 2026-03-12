import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String uid;
  final String nickname;
  final String avatarId;
  final int score;
  final DateTime? playedAt;
  final String? countryCode;

  LeaderboardEntry({
    required this.uid,
    required this.nickname,
    required this.avatarId,
    required this.score,
    this.playedAt,
    this.countryCode,
  });

  factory LeaderboardEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      uid: doc.id,
      nickname: data['nickname'] as String? ?? '???',
      avatarId: data['avatarId'] as String? ?? 'cat',
      score: data['bestScore'] as int? ?? 0,
      playedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      countryCode: data['countryCode'] as String?,
    );
  }
}

/// 국가코드(ISO 3166-1 alpha-2)를 국기 이모지로 변환
/// 예: "KR" → "🇰🇷", "US" → "🇺🇸"
String countryCodeToFlag(String? code) {
  if (code == null || code.length != 2) return '';
  final upper = code.toUpperCase();
  final first = String.fromCharCode(0x1F1E6 + upper.codeUnitAt(0) - 0x41);
  final second = String.fromCharCode(0x1F1E6 + upper.codeUnitAt(1) - 0x41);
  return '$first$second';
}

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._();
  factory LeaderboardService() => _instance;
  LeaderboardService._();

  final _firestore = FirebaseFirestore.instance;

  /// 점수 제출 (베스트 스코어만 갱신)
  Future<void> submitScore({
    required String uid,
    required String nickname,
    required String avatarId,
    required int score,
    String? countryCode,
  }) async {
    final docRef = _firestore.collection('leaderboard').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists || (doc.data()?['bestScore'] as int? ?? 0) < score) {
      await docRef.set({
        'nickname': nickname,
        'avatarId': avatarId,
        'bestScore': score,
        'updatedAt': FieldValue.serverTimestamp(),
        if (countryCode != null) 'countryCode': countryCode,
      }, SetOptions(merge: true));
    }
  }

  /// 상위 N명 조회
  Future<List<LeaderboardEntry>> getTopScores({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('leaderboard')
        .orderBy('bestScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => LeaderboardEntry.fromDoc(doc)).toList();
  }

  /// 내 순위 조회
  Future<int?> getMyRank(String uid) async {
    final myDoc = await _firestore.collection('leaderboard').doc(uid).get();
    if (!myDoc.exists) return null;

    final myScore = myDoc.data()?['bestScore'] as int? ?? 0;

    final higherCount = await _firestore
        .collection('leaderboard')
        .where('bestScore', isGreaterThan: myScore)
        .count()
        .get();

    return (higherCount.count ?? 0) + 1;
  }
}
