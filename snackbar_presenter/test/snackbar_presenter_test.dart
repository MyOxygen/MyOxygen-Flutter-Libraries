import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:snackbar_presenter/snackbar_presenter.dart';

const _buttonText = "Present SnackBar";
const _informationMessage = "SnackBar Information";
const _successMessage = "SnackBar Success";
const _errorMessage = "SnackBar Error";
const _customColor = Color(0xff0000FF); // Just blue

MaterialApp _appWithSnackBar(void Function(GlobalKey<ScaffoldState>) createSnackBar) {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  return MaterialApp(
    home: Material(
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            key: scaffoldKey,
            body: Center(
              child: RaisedButton(
                child: const Text(_buttonText),
                onPressed: () => createSnackBar(scaffoldKey),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _createAppPresentSnackBar(
    WidgetTester tester, void Function(GlobalKey<ScaffoldState>) createSnackBar) async {
  await tester.pumpWidget(_appWithSnackBar(createSnackBar));

  await _presentSnackBar(tester);
}

Future<void> _presentSnackBar(WidgetTester tester) async {
  await tester.tap(find.text(_buttonText));
  await tester.pumpAndSettle();
}

void main() {
  void _testForSnackBarContent(String text, IconData icon) {
    // Check the SnackBar has opened by looking for the text.
    final snackBarTextFinder = find.text(text);
    expect(snackBarTextFinder, findsOneWidget, reason: "The SnackBar should have opened.");

    // Check that the icon displayed is the information icon.
    final snackBarIconFinder = find.byIcon(icon);
    expect(snackBarIconFinder, findsOneWidget, reason: "The icon should be present.");

    // Navigate through all the widgets, and find the widget that is an Icon and
    // its color matches the custom color.
    final WidgetPredicate widgetPredicate = (widget) {
      return widget is Icon && widget.color == _customColor;
    };
    expect(find.byWidgetPredicate(widgetPredicate), findsOneWidget,
        reason: "The icon's color should be ${_customColor.toString()}");
  }

  testWidgets("Information SnackBar shows", (WidgetTester tester) async {
    final createSnackBar = (GlobalKey<ScaffoldState> key) => SnackBarPresenter.presentInformation(
        key.currentState, _informationMessage,
        iconColor: _customColor);
    await _createAppPresentSnackBar(tester, createSnackBar);

    _testForSnackBarContent(_informationMessage, FontAwesomeIcons.infoCircle);
  });

  testWidgets("Success SnackBar shows", (WidgetTester tester) async {
    final createSnackBar = (GlobalKey<ScaffoldState> key) => SnackBarPresenter.presentSuccess(
        key.currentState, _successMessage,
        iconColor: _customColor);
    await _createAppPresentSnackBar(tester, createSnackBar);

    _testForSnackBarContent(_successMessage, FontAwesomeIcons.solidCheckCircle);
  });

  testWidgets("Error SnackBar shows", (WidgetTester tester) async {
    final createSnackBar = (GlobalKey<ScaffoldState> key) =>
        SnackBarPresenter.presentError(key.currentState, _errorMessage, iconColor: _customColor);
    await _createAppPresentSnackBar(tester, createSnackBar);

    _testForSnackBarContent(_errorMessage, FontAwesomeIcons.exclamationCircle);
  });

  testWidgets("Hide currently showing SnackBar", (WidgetTester tester) async {
    int tapCount = 0;
    final buttonHandler = (GlobalKey<ScaffoldState> key) {
      if (tapCount % 2 == 0) {
        SnackBarPresenter.presentInformation(key.currentState, _informationMessage);
      } else {
        SnackBarPresenter.presentSuccess(key.currentState, _successMessage);
      }
      tapCount++;
    };
    await _createAppPresentSnackBar(tester, buttonHandler);
    await _presentSnackBar(tester);

    // Check the SnackBar has opened by looking for the text.
    final snackBar1TextFinder = find.text(_informationMessage);
    final snackBar2TextFinder = find.text(_successMessage);
    expect(snackBar1TextFinder, findsNothing, reason: "This SnackBar should not be showing.");
    expect(snackBar2TextFinder, findsOneWidget, reason: "This SnackBar should be showing.");
  });
}
