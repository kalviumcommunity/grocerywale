import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/main.dart';

void main() {
  testWidgets('StockFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const StockFlowApp());

    expect(find.text('StockFlow'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}