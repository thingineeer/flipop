import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  static const _totalSteps = 3;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _titles = const ['블록을 탭!', '한 줄 완성!', '연쇄 콤보!'];
  final _descriptions = const [
    '탭하면 상하좌우 블록의\n색이 바뀌어요',
    '가로 한 줄을 같은 색으로\n만들면 클리어!',
    '클리어 후 블록이 떨어져서\n연쇄가 터지면 대박 점수!',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _next,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameColors.background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 단계 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalSteps,
                    (i) => Container(
                      width: i == _step ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _step
                            ? GameColors.blockColors[BlockColor.blue]
                            : GameColors.gridLine,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 일러스트
                LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildIllustration(_step, constraints.maxWidth);
                  },
                ),

                const SizedBox(height: 16),

                // 제목
                Text(
                  _titles[_step],
                  style: const TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                // 설명
                Text(
                  _descriptions[_step],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // 버튼
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.blue],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.blockDarkColors[BlockColor.blue]!
                            .withValues(alpha: 0.4),
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _step < _totalSteps - 1 ? '다음' : '시작하기!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(int step, double maxWidth) {
    switch (step) {
      case 0:
        return _buildTapIllustration(maxWidth);
      case 1:
        return _buildLineIllustration(maxWidth);
      case 2:
        return _buildComboIllustration();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Step 1: 탭 → 주변 색 변화 (before → after)
  Widget _buildTapIllustration(double maxWidth) {
    const arrowSpace = 46.0;
    const gap = 3.0;
    final gridWidth = (maxWidth - arrowSpace) / 2;
    final cellSize = ((gridWidth - gap * 2) / 3).floorToDouble();

    const r = BlockColor.red;
    const b = BlockColor.blue;
    const y = BlockColor.yellow;

    final before = [
      [r, b, r],
      [y, r, b],
      [b, y, y],
    ];
    final after = [
      [r, y, r],
      [b, r, y],
      [b, b, y],
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _miniGrid(before, cellSize, gap,
                highlightCenter: true, showDirectionArrows: true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('→',
                  style: TextStyle(
                      fontSize: 22,
                      color: GameColors.textSecondary,
                      fontWeight: FontWeight.w700)),
            ),
            _miniGrid(after, cellSize, gap,
                glowCells: const {'01', '10', '12', '21'}),
          ],
        ),
        const SizedBox(height: 6),
        // 바뀌는 방향 힌트
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('↑←→↓ ',
                style: TextStyle(
                    fontSize: 12,
                    color: GameColors.blockColors[BlockColor.blue],
                    fontWeight: FontWeight.w800)),
            const Text('주변 4칸 색 변화!',
                style: TextStyle(
                    fontSize: 12,
                    color: GameColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  /// Step 2: 한 줄 같은 색 = 클리어
  Widget _buildLineIllustration(double maxWidth) {
    const gap = 3.0;
    final cellSize = ((maxWidth - gap * 2) / 3).floorToDouble().clamp(0, 50);

    const r = BlockColor.red;
    const b = BlockColor.blue;
    const y = BlockColor.yellow;

    final grid = [
      [r, y, b],
      [b, b, b],
      [y, r, y],
    ];

    return Column(
      children: [
        Center(
            child:
                _miniGrid(grid, cellSize.toDouble(), gap, highlightRow: 1)),
        const SizedBox(height: 8),
        const Text('✨ POP! ✨',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: GameColors.textPrimary)),
      ],
    );
  }

  /// Step 3: 연쇄 콤보
  Widget _buildComboIllustration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.blockColors[BlockColor.yellow]!
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final bc in [
                BlockColor.red,
                BlockColor.blue,
                BlockColor.yellow
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset(
                    GameColors.blockImages[bc]!,
                    width: 36,
                    height: 36,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('COMBO x1  →  +100',
              style:
                  TextStyle(fontSize: 14, color: GameColors.textSecondary)),
          const Text('COMBO x2  →  +200',
              style:
                  TextStyle(fontSize: 14, color: GameColors.textSecondary)),
          const Text('COMBO x3  →  +300 🔥',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GameColors.textPrimary)),
        ],
      ),
    );
  }

  /// 미니 3x3 그리드 위젯 — 픽셀 캐릭터 이미지 사용
  Widget _miniGrid(
    List<List<BlockColor>> blockColors,
    double cellSize,
    double gap, {
    bool highlightCenter = false,
    bool showDirectionArrows = false,
    int? highlightRow,
    Set<String>? glowCells,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < blockColors.length; r++)
          Padding(
            padding: EdgeInsets.only(
                bottom: r < blockColors.length - 1 ? gap : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int c = 0; c < blockColors[r].length; c++)
                  Padding(
                    padding: EdgeInsets.only(
                        right: c < blockColors[r].length - 1 ? gap : 0),
                    child: _buildMiniCell(
                      blockColors[r][c],
                      cellSize,
                      r,
                      c,
                      highlightCenter: highlightCenter,
                      showDirectionArrows: showDirectionArrows,
                      highlightRow: highlightRow,
                      glowCells: glowCells,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMiniCell(
    BlockColor bc,
    double cellSize,
    int r,
    int c, {
    bool highlightCenter = false,
    bool showDirectionArrows = false,
    int? highlightRow,
    Set<String>? glowCells,
  }) {
    final isCenter = highlightCenter && r == 1 && c == 1;
    final isAdjacent = showDirectionArrows &&
        ((r == 0 && c == 1) || // 위
            (r == 2 && c == 1) || // 아래
            (r == 1 && c == 0) || // 왼
            (r == 1 && c == 2)); // 오른
    final isGlow = glowCells?.contains('$r$c') == true;
    final isHighlightRow = highlightRow == r;

    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: GameColors.blockColors[bc],
        borderRadius: BorderRadius.circular(cellSize * 0.2),
        border: isCenter
            ? Border.all(color: Colors.white, width: 3)
            : isHighlightRow
                ? Border.all(color: Colors.white, width: 2)
                : isAdjacent
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 2)
                    : null,
        boxShadow: isGlow
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cellSize * 0.2),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(cellSize * 0.08),
              child: Image.asset(
                GameColors.blockImages[bc]!,
                width: cellSize * 0.84,
                height: cellSize * 0.84,
                fit: BoxFit.contain,
              ),
            ),
            // 탭 위치: 펄스 원 + "TAP" 텍스트
            if (isCenter)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(cellSize * 0.2),
                      color: Colors.white.withValues(
                          alpha: 0.3 * _pulseAnimation.value),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'TAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: cellSize * 0.22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            // 인접 셀: 작은 방향 화살표
            if (isAdjacent)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    r == 0 && c == 1
                        ? '↑'
                        : r == 2 && c == 1
                            ? '↓'
                            : r == 1 && c == 0
                                ? '←'
                                : '→',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: cellSize * 0.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
