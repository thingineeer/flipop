import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flipop/game/game_colors.dart';
import 'package:flipop/game/game_state.dart';
import 'package:flipop/l10n/app_localizations.dart';
import 'package:flipop/ui/game_screen.dart';
import 'package:flipop/ui/game_over_overlay.dart';

/// Firebase 없이 GameScreen을 직접 테스트하기 위한 래퍼
Widget buildTestApp({Widget? child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: GameColors.blockColors[BlockColor.blue]!,
        surface: GameColors.background,
      ),
    ),
    home: child ?? const GameScreen(),
  );
}

/// pumpAndSettle 대신 사용 — 무한 애니메이션이 있어도 안전하게 프레임 진행
Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('START 오버레이 → 탭 → 게임 시작 → 블록 탭', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await pumpFrames(tester, frames: 20);

    // 1. START 오버레이 존재 확인
    expect(find.byKey(const Key('start_overlay')), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // 2. START 탭 → 게임 시작
    await tester.tap(find.byKey(const Key('start_overlay')));
    await pumpFrames(tester, frames: 20);

    // 3. START 오버레이 사라짐
    expect(find.byKey(const Key('start_overlay')), findsNothing);

    // 4. 게임 UI 요소 확인
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('FLIPOP'), findsOneWidget);

    // 5. 초기 점수 0
    expect(find.text('0'), findsWidgets);

    // 6. 블록 탭 시도 — ValueKey<int>를 가진 위젯 찾기
    final blockFinder = find.byWidgetPredicate(
      (widget) => widget.key is ValueKey<int>,
    );
    final blockCount = tester.widgetList(blockFinder).length;
    expect(blockCount, greaterThan(0));

    // 블록 5개 탭
    for (int i = 0; i < 5 && i < blockCount; i++) {
      final key = tester.widgetList(blockFinder).elementAt(i).key!;
      await tester.tap(find.byKey(key), warnIfMissed: false);
      await pumpFrames(tester, frames: 5);
    }

    binding.reportData = {'game_start': 'success'};
  });

  testWidgets('GameOverOverlay: GAME OVER + PLAY AGAIN', (tester) async {
    bool restartCalled = false;

    await tester.pumpWidget(buildTestApp(
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: Stack(
          children: [
            GameOverOverlay(
              score: 1500,
              bestScore: 2000,
              onRestart: () => restartCalled = true,
              canRevive: true,
              canTimeBonus: true,
              canScoreDouble: true,
            ),
          ],
        ),
      ),
    ));
    await pumpFrames(tester, frames: 20);

    // GAME OVER 표시
    expect(find.text('GAME OVER'), findsOneWidget);

    // 점수 표시
    expect(find.text('1500'), findsOneWidget);

    // PLAY AGAIN 버튼 탭
    expect(find.byKey(const Key('play_again_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('play_again_button')));
    await pumpFrames(tester);

    expect(restartCalled, isTrue);
  });

  testWidgets('GameOverOverlay: NEW BEST 표시', (tester) async {
    await tester.pumpWidget(buildTestApp(
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: Stack(
          children: [
            GameOverOverlay(
              score: 3000,
              bestScore: 3000,
              onRestart: () {},
            ),
          ],
        ),
      ),
    ));
    await pumpFrames(tester, frames: 20);

    // score == bestScore → NEW BEST
    expect(find.textContaining('NEW BEST'), findsOneWidget);
    expect(find.text('3000'), findsWidgets);
  });

  testWidgets('GameOverOverlay: 리워드 버튼 비활성 상태', (tester) async {
    await tester.pumpWidget(buildTestApp(
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: Stack(
          children: [
            GameOverOverlay(
              score: 500,
              bestScore: 1000,
              onRestart: () {},
              canRevive: false,
              canTimeBonus: false,
              canScoreDouble: false,
            ),
          ],
        ),
      ),
    ));
    await pumpFrames(tester, frames: 20);

    // GAME OVER 표시
    expect(find.text('GAME OVER'), findsOneWidget);
    // PLAY AGAIN은 항상 표시
    expect(find.byKey(const Key('play_again_button')), findsOneWidget);
  });
}
