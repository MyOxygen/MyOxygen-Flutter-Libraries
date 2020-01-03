import 'package:environment_switcher/src/select_environment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:environment_switcher/environment_switcher.dart';

final environments = [
  Environment(
    name: "Mock Blue",
    description: "A blue mock environment",
    bannerColor: Colors.blue,
    databaseName: "mockB",
  ),
  Environment(
    name: "Mock Green",
    description: "A green mock environment",
    bannerColor: Colors.green,
    databaseName: "mockG",
  ),
  Environment(
    name: "Mock Red",
    description: "A red mock environment",
    bannerColor: Colors.red,
    databaseName: "mockR",
  ),
];

Widget _app() {
  return MaterialApp(
    home: Builder(
      builder: (context) => EnvironmentSwitcher(
        environments: environments,
        environmentStore: _MockEnvironmentStore(),
        builder: (env) => Material(
          child: Scaffold(
            body: Center(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _createApp(WidgetTester tester, {Environment initialEnvironment}) async {
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();

  await _findBanner(tester, environment: initialEnvironment ?? environments[0]);
}

Future<void> _findBanner(WidgetTester tester, {Environment environment}) async {
  final WidgetPredicate widgetPredicate = (widget) {
    return widget is Banner &&
        widget.message != "DEBUG" &&
        (environment == null ? true : widget.message == environment.name);
  };
  final widgetFinder = find.byWidgetPredicate(widgetPredicate,
      description: "Find Banner whose name is not \"DEBUG\"" +
          (environment == null ? "" : " and has name \"${environment.name}\""));
  expect(widgetFinder, findsOneWidget,
      reason: "The EnvironmentSwitcher banner should be displayed.");
}

Future<void> _presentSwitcher(WidgetTester tester) async {
  // Search for the banner by looking for the GestureDetector whose child is the
  // tap box, as that is what we need to tap, and what Flutter Test will react
  // to.
  final WidgetPredicate widgetPredicate = (widget) {
    return widget is GestureDetector &&
        widget.behavior == HitTestBehavior.opaque &&
        widget.child is SizedBox &&
        (widget.child as SizedBox).height == 80 &&
        (widget.child as SizedBox).width == 80;
  };
  final bannerFinder = find.byWidgetPredicate(widgetPredicate);

  expect(bannerFinder, findsOneWidget,
      reason: "The EnvironmentSwitcher banner should be displayed.");

  await tester.tap(bannerFinder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("Switcher shows", (WidgetTester tester) async {
    await _createApp(tester);

    // Present the SelectEnvironmentSheet widget
    await _presentSwitcher(tester);

    // Look for the SelectEnvironmentSheet widget.
    final WidgetPredicate widgetPredicate = (widget) {
      return widget is SelectEnvironmentSheet;
    };
    final widgetFinder = find.byWidgetPredicate(widgetPredicate);
    expect(widgetFinder, findsOneWidget,
        reason: "The SelectEnvironmentSheet widget should be displayed.");

    // Make sure there are 3 items (as per the list of test environments)
    final WidgetPredicate listItemPredicate = (widget) {
      return widget is ListTile;
    };
    final listItemFinder = find.byWidgetPredicate(listItemPredicate);
    expect(listItemFinder, findsNWidgets(environments.length),
        reason: "The should be ${environments.length} item(s) in the list of environments.");

    // Select a new environment
    final newEnvironmentFinder = find.text(environments[2].name);
    expect(newEnvironmentFinder, findsOneWidget,
        reason: "The third environment should be available to select.");
    await tester.tap(newEnvironmentFinder);
    await tester.pumpAndSettle();

    // Find the new banner
    await _findBanner(tester, environment: environments[2]);
  });
}

class _MockEnvironmentStore extends EnvironmentStore {
  _MockEnvironmentStore() : super(store: Store());

  @override
  Future<String> getSavedEnvironment() async {
    return null;
  }

  @override
  Future<void> saveEnvironment(Environment environment) async {
    // Do nothing
  }
}