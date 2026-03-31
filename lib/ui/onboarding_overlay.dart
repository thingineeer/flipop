import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  static const _totalSteps = 3;

  late final PageController _pageController;
  int _currentPage = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _lineController;

  List<String> _titles(AppLocalizations l10n) => [
    l10n.tutorialTapTitle,
    l10n.tutorialClearTitle,
    l10n.tutorialComboTitle,
  ];
  List<String> _descriptions(AppLocalizations l10n) => [
    l10n.tutorialTapDesc,
    l10n.tutorialClearDesc,
    l10n.tutorialComboDesc,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDismiss();
    }
  }

  /// 한 줄 완성 애니메이션에서 각 블록의 glow 강도 (0.0~1.0)
  double _glowForBlock(int col) {
    final t = _lineController.value;
    // 0~0.3: col0 glow, 0.3~0.6: col1 glow, 0.6~0.9: col2 glow
    final start = col * 0.2;
    final end = start + 0.2;
    if (t < start || t > end + 0.1) return 0.0;
    if (t <= end) {
      // fade in
      return ((t - start) / 0.2).clamp(0.0, 1.0);
    }
    // fade out
    return (1.0 - ((t - end) / 0.1)).clamp(0.0, 1.0);
  }

  /// 한 줄 완성 애니메이션에서 전체 줄의 scale
  double _lineScale() {
    final t = _lineController.value;
    if (t < 0.6) return 1.0;
    if (t < 0.7) {
      // scale 1.0 → 1.2
      final p = (t - 0.6) / 0.1;
      return 1.0 + 0.2 * p;
    }
    if (t < 0.8) {
      // scale 1.2 → 0.0
      final p = (t - 0.7) / 0.1;
      return 1.2 * (1.0 - p);
    }
    if (t < 0.85) {
      // 사라진 상태 유지
      return 0.0;
    }
    // scale 0.0 → 1.0 (다시 나타남)
    final p = (t - 0.85) / 0.15;
    return p.clamp(0.0, 1.0);
  }

  /// 한 줄 완성 애니메이션에서 전체 줄의 opacity
  double _lineOpacity() {
    final t = _lineController.value;
    if (t < 0.75) return 1.0;
    if (t < 0.8) {
      // 1.0 → 0.0 (사라짐)
      final p = (t - 0.75) / 0.05;
      return (1.0 - p).clamp(0.0, 1.0);
    }
    if (t < 0.85) return 0.0;
    // 0.0 → 1.0 (나타남)
    final p = (t - 0.85) / 0.15;
    return p.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                _buildIndicator(),
                const SizedBox(height: 20),

                // PageView 영역
                SizedBox(
                  height: 330,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalSteps,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(index);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 버튼
                GestureDetector(
                  onTap: _next,
                  child: Container(
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
                        _currentPage < _totalSteps - 1 ? l10n.tutorialNext : l10n.tutorialStart,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
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

  /// 하단 인디케이터 (현재 페이지에 따라 애니메이션)
  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalSteps,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: i == _currentPage ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == _currentPage
                ? GameColors.blockColors[BlockColor.blue]
                : GameColors.gridLine,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// 각 페이지 콘텐츠
  Widget _buildPage(int step) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 일러스트
            _buildIllustration(step, constraints.maxWidth),
            const SizedBox(height: 16),

            // 제목
            Text(
              _titles(l10n)[step],
              style: const TextStyle(
                color: GameColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              _descriptions(l10n)[step],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        );
      },
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

  /// Step 1: tap -> adjacent color change (before -> after)
  Widget _buildTapIllustration(double maxWidth) {
    final l10n = AppLocalizations.of(context)!;
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
        Text(
          l10n.tutorialTapHint,
          style: const TextStyle(
            fontSize: 12,
            color: GameColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        _buildColorCycleHint(),
      ],
    );
  }

  /// Step 2: 한 줄 같은 색 = 클리어 (glow → pop 애니메이션)
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

    return AnimatedBuilder(
      animation: _lineController,
      builder: (context, child) {
        final scale = _lineScale();
        final opacity = _lineOpacity();

        return Column(
          children: [
            Center(
              child: _miniGridAnimated(
                grid,
                cellSize.toDouble(),
                gap,
                animatedRow: 1,
                rowScale: scale,
                rowOpacity: opacity,
                glowIntensities: [
                  _glowForBlock(0),
                  _glowForBlock(1),
                  _glowForBlock(2),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('✨ POP! ✨',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GameColors.textPrimary)),
          ],
        );
      },
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
          const Text('COMBO x1  →  +100점  +3초',
              style:
                  TextStyle(fontSize: 14, color: GameColors.textSecondary)),
          const Text('COMBO x2  →  +200점  +5초',
              style:
                  TextStyle(fontSize: 14, color: GameColors.textSecondary)),
          const Text('COMBO x3  →  +300점  +7초 🔥',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GameColors.textPrimary)),
        ],
      ),
    );
  }

  /// 애니메이션 적용된 미니 3x3 그리드 (Step 2 전용)
  Widget _miniGridAnimated(
    List<List<BlockColor>> blockColors,
    double cellSize,
    double gap, {
    required int animatedRow,
    required double rowScale,
    required double rowOpacity,
    required List<double> glowIntensities,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < blockColors.length; r++)
          Padding(
            padding: EdgeInsets.only(
                bottom: r < blockColors.length - 1 ? gap : 0),
            child: r == animatedRow
                ? Transform.scale(
                    scale: rowScale,
                    child: Opacity(
                      opacity: rowOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int c = 0; c < blockColors[r].length; c++)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: c < blockColors[r].length - 1
                                      ? gap
                                      : 0),
                              child: _buildAnimatedCell(
                                blockColors[r][c],
                                cellSize,
                                glowIntensities[c],
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int c = 0; c < blockColors[r].length; c++)
                        Padding(
                          padding: EdgeInsets.only(
                              right: c < blockColors[r].length - 1
                                  ? gap
                                  : 0),
                          child: _buildMiniCell(
                            blockColors[r][c],
                            cellSize,
                            r,
                            c,
                          ),
                        ),
                    ],
                  ),
          ),
      ],
    );
  }

  /// 한 줄 완성 애니메이션에서 glow가 적용된 개별 셀
  Widget _buildAnimatedCell(
    BlockColor bc,
    double cellSize,
    double glowIntensity,
  ) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: GameColors.blockColors[bc],
        borderRadius: BorderRadius.circular(cellSize * 0.2),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          if (glowIntensity > 0)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9 * glowIntensity),
              blurRadius: 12 * glowIntensity,
              spreadRadius: 3 * glowIntensity,
            ),
          if (glowIntensity > 0)
            BoxShadow(
              color: GameColors.blockColors[bc]!
                  .withValues(alpha: 0.6 * glowIntensity),
              blurRadius: 20 * glowIntensity,
              spreadRadius: 5 * glowIntensity,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cellSize * 0.2),
        child: Padding(
          padding: EdgeInsets.all(cellSize * 0.08),
          child: Image.asset(
            GameColors.blockImages[bc]!,
            width: cellSize * 0.84,
            height: cellSize * 0.84,
            fit: BoxFit.contain,
          ),
        ),
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

  /// 색 순환 규칙 다이어그램 (빨강→파랑→노랑→빨강)
  Widget _buildColorCycleHint() {
    const colors = [BlockColor.red, BlockColor.blue, BlockColor.yellow];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < colors.length; i++) ...[
            _colorCycleItem(colors[i]),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('→',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ],
          // 다시 처음으로 돌아가는 표시
          _colorCycleItem(colors[0]),
        ],
      ),
    );
  }

  Widget _colorCycleItem(BlockColor bc) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: GameColors.blockColors[bc],
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        GameColors.blockImages[bc]!,
        fit: BoxFit.contain,
      ),
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
                          AppLocalizations.of(context)!.labelTap,
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
