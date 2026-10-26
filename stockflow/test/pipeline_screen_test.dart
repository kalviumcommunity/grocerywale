import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/screens/pipeline_screen.dart';
import 'package:stockflow/widgets/status_badge.dart';
import 'package:stockflow/widgets/priority_badge.dart';

void main() {
  testWidgets('PipelineScreen renders tabs, filters and request cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PipelineScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Tabs
    expect(find.text('Replenishment Pipeline'), findsOneWidget);
    expect(find.text('All Stages'), findsOneWidget);
    expect(find.text('Requested'), findsWidgets);
    expect(find.text('Approved'), findsWidgets);
    expect(find.text('Dispatched'), findsWidgets);
    expect(find.text('Received'), findsWidgets);

    // Verify Status & Priority badges render
    expect(find.byType(StatusBadge), findsWidgets);
    expect(find.byType(PriorityBadge), findsWidgets);

    // Tap on Dispatched tab
    await tester.tap(find.text('Dispatched').first);
    await tester.pumpAndSettle();

    // Verify dispatched requests or empty state
    expect(find.byType(StatusBadge), findsWidgets);
  });
}
