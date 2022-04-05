library snackbar_presenter;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _successColor = Color(0xff4dd662);
const _errorColor = Color(0xffed6e73);
const _separationDistance = 12.0;

class SnackBarPresenter {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  const SnackBarPresenter._();

  /// Present an information [SnackBar] in the provided [Scaffold].
  static void presentInformation(String message,
      {Color iconColor, ScaffoldMessengerState customScaffoldMessengerState}) {
    // If the `iconColor` is null, it will default to the icon theme data color.
    _presentSnackbar(
      customScaffoldMessengerState ?? scaffoldMessengerKey.currentState,
      message,
      iconColor,
      FontAwesomeIcons.infoCircle,
    );
  }

  /// Present a success [SnackBar] in the provided [Scaffold].
  static void presentSuccess(String message,
      {Color iconColor, ScaffoldMessengerState customScaffoldMessengerState}) {
    _presentSnackbar(
      customScaffoldMessengerState ?? scaffoldMessengerKey.currentState,
      message,
      iconColor ?? _successColor,
      FontAwesomeIcons.solidCheckCircle,
    );
  }

  /// Present an error [SnackBar] in the provided [Scaffold].
  static void presentError(String error,
      {Color iconColor, ScaffoldMessengerState customScaffoldMessengerState}) {
    _presentSnackbar(
      customScaffoldMessengerState ?? scaffoldMessengerKey.currentState,
      error,
      iconColor ?? _errorColor,
      FontAwesomeIcons.exclamationCircle,
    );
  }

  /// Handles displaying the action [SnackBar] with its contents.
  static void _presentSnackbar(
      ScaffoldMessengerState scaffoldMessengerState, String message, Color color, IconData icon) {
    assert(scaffoldMessengerState != null);
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
    scaffoldMessengerState.hideCurrentSnackBar();

    scaffoldMessengerState.showSnackBar(snackbar);
  }
}
