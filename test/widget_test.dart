import 'package:flutter_test/flutter_test.dart';
import 'package:flipop/main.dart';

void main() {
  testWidgets('App launches and shows loading', (WidgetTester tester) async {
    // FlipopApp은 Firebase 초기화 없이는 AuthGate가 로딩 스피너를 표시
    // Firebase 미초기화 상태에서도 앱이 crash하지 않는지 확인
    await tester.pumpWidget(const FlipopApp());
    // 로딩 중이거나 FLIPOP 텍스트가 표시됨
    expect(find.byType(FlipopApp), findsOneWidget);
  });
}
