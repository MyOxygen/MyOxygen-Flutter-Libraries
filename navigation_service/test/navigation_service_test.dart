import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:navigation_service/navigation_service.dart';

import 'widgets/first_widget/first_widget.dart';
import 'widgets/second_widget/second_widget_configuration.dart';

void main() {
  testWidgets("Can navigator navigate to and from a stateful page", (tester) async {
    // Build the app layout
    await tester.pumpWidget(MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: (settings) => NavigationService.getRoute(settings),
      home: FirstWidget(FirstWidgetConfiguration(
        "/first",
        () {
          NavigationService.navigateTo(SecondWidgetConfiguration(
            "/second",
            () {
              NavigationService.pop();
            },
          ));
        },
      )),
    ));

    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y', skipOffstage: false), findsNothing);

    // Simulate pushing
    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();
    expect(find.text('X'), findsNothing);
    expect(find.text('Y'), findsOneWidget);

    // Simulate popping
    await tester.tap(find.text('Y'));
    await tester.pumpAndSettle();
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsNothing);
  });
}
