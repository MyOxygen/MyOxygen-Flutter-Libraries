// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:action_log_example/main.dart';

void main() {
  testWidgets('The necessary widgets are being displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that counter value is displayed.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data.startsWith('Counter:'),
      ),
      findsOneWidget,
    );

    // Verify that the button to view logs is displayed.
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is RaisedButton &&
            widget.child is Text &&
            (widget.child as Text).data.toLowerCase().startsWith('view logs'),
      ),
      findsOneWidget,
    );
  });
}
