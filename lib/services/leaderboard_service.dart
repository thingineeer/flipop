import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  final _functions = FirebaseFunctions.instance;

  /// 점수 제출 (Cloud Function 서버사이드 검증)
  Future<void> submitScore({
    required String uid,
    required String nickname,
    required String avatarId,
    required int score,
    String? countryCode,
  }) async {
    await _functions.httpsCallable('submitScore').call<dynamic>({
      'score': score,
      'nickname': nickname,
      'avatarId': avatarId,
      if (countryCode != null) 'countryCode': countryCode,
    });
  }

  /// 상위 N명 조회 (국가 필터 옵션)
  Future<List<LeaderboardEntry>> getTopScores({
    int limit = 50,
    String? countryCode,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('leaderboard');

    if (countryCode != null) {
      query = query.where('countryCode', isEqualTo: countryCode);
    }

    final snapshot = await query
        .orderBy('bestScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => LeaderboardEntry.fromDoc(doc)).toList();
  }

  /// 내 순위 조회 (국가 필터 옵션)
  Future<int?> getMyRank(String uid, {String? countryCode}) async {
    final myDoc = await _firestore.collection('leaderboard').doc(uid).get();
    if (!myDoc.exists) return null;

    final myScore = myDoc.data()?['bestScore'] as int? ?? 0;

    Query<Map<String, dynamic>> query = _firestore.collection('leaderboard')
        .where('bestScore', isGreaterThan: myScore);

    if (countryCode != null) {
      query = query.where('countryCode', isEqualTo: countryCode);
    }

    final higherCount = await query.count().get();

    return (higherCount.count ?? 0) + 1;
  }
}
