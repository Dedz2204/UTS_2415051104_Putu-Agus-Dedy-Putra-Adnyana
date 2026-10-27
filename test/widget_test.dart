import 'package:flutter_test/flutter_test.dart';
import 'package:expense_task/main.dart';

void main() {
  testWidgets('ExpenseTask dapat dibuat', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTaskApp());

    expect(find.byType(ExpenseTaskApp), findsOneWidget);
  });
}
