import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/avatar_data.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final bool embedded;
  final ValueNotifier<bool>? tabVisible;

  const LeaderboardScreen({
    super.key,
    this.embedded = false,
    this.tabVisible,
  });

  @override
  State<LeaderboardScreen> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry>? _entries;
  int? _myRank;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.tabVisible?.addListener(_onTabVisibleChanged);
  }

  @override
  void dispose() {
    widget.tabVisible?.removeListener(_onTabVisibleChanged);
    super.dispose();
  }

  void _onTabVisibleChanged() {
    if (widget.tabVisible?.value == true) {
      _loadData();
    }
  }

  void refresh() {
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final entries = await LeaderboardService().getTopScores(limit: 50);
      final uid = AuthService().currentUser?.uid;
      int? myRank;
      if (uid != null) {
        myRank = await LeaderboardService().getMyRank(uid);
      }

      if (mounted) {
        setState(() {
          _entries = entries;
          _myRank = myRank;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      bottom: !widget.embedded,
      child: Column(
        children: [
          _buildHeader(),
          if (_myRank != null) _buildMyRankCard(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: GameColors.textSecondary,
                    ),
                  )
                : _entries == null || _entries!.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 기록이 없어요!',
                          style: TextStyle(
                            color: GameColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _entries!.length,
                          itemBuilder: (context, index) =>
                              _buildRankItem(index, _entries![index]),
                        ),
                      ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: GameColors.background,
          child: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: GameColors.background,
      body: body,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (!widget.embedded) ...[
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GameColors.gridBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GameColors.gridLine, width: 2),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: GameColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          const Expanded(
            child: Text(
              'RANKING',
              style: TextStyle(
                color: GameColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GameColors.gridBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameColors.gridLine, width: 2),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: GameColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCard() {
    final auth = AuthService();
    final avatarImage =
        AvatarData.images[auth.avatarId] ?? 'assets/images/cat_red.png';
    final avatarColor = AvatarData.avatarColors[auth.avatarId] ?? BlockColor.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.blockColors[BlockColor.blue]!.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GameColors.blockColors[BlockColor.blue]!.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: GameColors.blockColors[avatarColor],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(avatarImage, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.nickname ?? '???',
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '내 순위: #$_myRank',
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(int index, LeaderboardEntry entry) {
    final rank = index + 1;
    final isMe = entry.uid == AuthService().currentUser?.uid;
    final avatarImage =
        AvatarData.images[entry.avatarId] ?? 'assets/images/cat_red.png';
    final avatarColor = AvatarData.avatarColors[entry.avatarId] ?? BlockColor.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? GameColors.blockColors[BlockColor.blue]!.withValues(alpha: 0.1)
            : GameColors.gridBackground,
        borderRadius: BorderRadius.circular(14),
        border: isMe
            ? Border.all(
                color: GameColors.blockColors[BlockColor.blue]!
                    .withValues(alpha: 0.3),
                width: 2)
            : Border.all(color: GameColors.gridLine, width: 1),
      ),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(
                    rank == 1
                        ? '1st'
                        : rank == 2
                            ? '2nd'
                            : '3rd',
                    style: TextStyle(
                      color: rank == 1
                          ? GameColors.blockColors[BlockColor.yellow]
                          : rank == 2
                              ? GameColors.textSecondary
                              : GameColors.blockColors[BlockColor.red],
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : Text(
                    '#$rank',
                    style: const TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // 아바타
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: GameColors.blockColors[avatarColor],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(avatarImage, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),

          // 닉네임 + 국기
          Expanded(
            child: Row(
              children: [
                if (countryCodeToFlag(entry.countryCode).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      countryCodeToFlag(entry.countryCode),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                Flexible(
                  child: Text(
                    entry.nickname,
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 15,
                      fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 점수
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
