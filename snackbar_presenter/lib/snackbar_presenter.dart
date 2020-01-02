library snackbar_presenter;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _successColor = Color(0xff4dd662);
const _errorColor = Color(0xffed6e73);
const _separationDistance = 12.0;

class SnackBarPresenter {
  const SnackBarPresenter._();

  /// Present an information [SnackBar] in the provided [Scaffold].
  static void presentInformation(GlobalKey<ScaffoldState> scaffoldKey, String message,
      {Color iconColor}) {
    // If the `iconColor` is null, it will default to the system color, whatever
    // that may be.
    _presentSnackbar(
      scaffoldKey,
      message,
      iconColor,
      FontAwesomeIcons.infoCircle,
    );
  }

  /// Present a success [SnackBar] in the provided [Scaffold].
  static void presentSuccess(GlobalKey<ScaffoldState> scaffoldKey, String message,
      {Color iconColor}) {
    _presentSnackbar(
      scaffoldKey,
      message,
      iconColor ?? _successColor,
      FontAwesomeIcons.solidCheckCircle,
    );
  }

  /// Present an error [SnackBar] in the provided [Scaffold].
  static void presentError(GlobalKey<ScaffoldState> scaffoldKey, String error, {Color iconColor}) {
    _presentSnackbar(
      scaffoldKey,
      error,
      iconColor ?? _errorColor,
      FontAwesomeIcons.exclamationCircle,
    );
  }

  /// Handles displaying the action [SnackBar] with its contents.
  static void _presentSnackbar(
      GlobalKey<ScaffoldState> scaffoldKey, String message, Color color, IconData icon) {
    assert(scaffoldKey != null);
    assert(message != null);
    assert(message.isNotEmpty);

    final snackbar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: _separationDistance),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    );

    // Hide any currently showing SnackBars. If there are none, this will do
    // nothing.
    scaffoldKey.currentState.hideCurrentSnackBar();

    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
