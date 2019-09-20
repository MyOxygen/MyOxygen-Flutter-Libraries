import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quickdialogs/quickdialogs.dart';

MaterialApp _appWithDialog(Function(BuildContext) createDialog) {
  return MaterialApp(
    home: Material(
      child: Builder(
        builder: (BuildContext context) {
          return Center(
            child: RaisedButton(
              child: const Text("Open Dialog"),
              onPressed: () => createDialog(context),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _createAppOpenDialog(WidgetTester tester, Function(BuildContext) createDialog) async {
  await tester.pumpWidget(_appWithDialog(createDialog));

  await tester.tap(find.text("Open Dialog"));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("Info dialog opens and closes", (WidgetTester tester) async {
    final createDialog = (context) => QuickDialogs.infoDialog(context, "MyTitle", "Some message.");
    await _createAppOpenDialog(tester, createDialog);

    final okTextFinder = find.text("OK");
    expect(okTextFinder, findsOneWidget, reason: "The dialog should have opened.");

    await tester.tap(okTextFinder);
    await tester.pumpAndSettle();

    expect(okTextFinder, findsNothing, reason: "The dialog should have closed.");
  });

  testWidgets("Destructive dialog opens and closes", (WidgetTester tester) async {
    bool didDestroy = false;
    final createDialog = (context) => QuickDialogs.destructive(
          context,
          title: "MyTitle",
          message: "Delete?",
          constructiveActionName: "Deny",
          destructiveActionName: "Confirm",
          destructiveActionCallback: () => didDestroy = true,
        );
    await _createAppOpenDialog(tester, createDialog);

    final confirmTextFinder = find.text("Confirm".toUpperCase());

    expect(confirmTextFinder, findsOneWidget, reason: "The dialog should have opened.");
    expect(didDestroy, false, reason: "The destructive button should not have been tapped yet.");

    await tester.tap(confirmTextFinder);
    await tester.pumpAndSettle();

    expect(confirmTextFinder, findsNothing, reason: "The dialog should have closed.");
    expect(didDestroy, true, reason: "The destructive button should have been tapped.");
  });

  testWidgets("Confirmation dialog opens and closes", (WidgetTester tester) async {
    bool didContinue = false;
    final createDialog = (context) async {
      didContinue = await QuickDialogs.confirmationDialogAsync(
        context: context,
        title: "MyTitle",
        message: "Continue?",
        positiveButtonText: "Yes",
        negativeButtonText: "No",
      );
    };
    await _createAppOpenDialog(tester, createDialog);

    final confirmTextFinder = find.text("Yes");

    expect(confirmTextFinder, findsOneWidget, reason: "The dialog should have opened.");
    expect(didContinue, false, reason: "The positive button should not have been tapped yet.");

    await tester.tap(confirmTextFinder);
    await tester.pumpAndSettle();

    expect(confirmTextFinder, findsNothing, reason: "The dialog should have closed.");
    expect(didContinue, true, reason: "The positive button should have been tapped.");
  });
}
