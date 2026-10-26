import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/main.dart';
import 'package:stockflow/widgets/app_button.dart';

void main() {
  testWidgets('StockFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const StockFlowApp());

    expect(find.text('StockFlow'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);

    // Tap login to verify navigation to the Home Shell / Dashboard
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    // Verify Dashboard with Shared Visibility Pipeline and Stockout Risk displays
    expect(find.text('Shared Visibility Pipeline'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Warehouse'), findsOneWidget);
  });
}
