library quickdialogs;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DialogTheme {
  platformSpecific,
  materialOnly,
  cupertinoOnly,
}

class QuickDialogs {
  /// Gets or sets the overall app dialog theme. This defaults to "platform
  /// specific", meaning `QuickDialogs` will automatically determine whether to
  /// user Cupertino-style dialogs for iOS, or Material-style dialogs for
  /// Android.
  static DialogTheme dialogTheme = DialogTheme.platformSpecific;

  // Prevent multiple instances of QuickDialogs class being created.
  QuickDialogs._();

  /// Creates a dialog with the option for a destructive action.
  /// [context] is required to build the dialog
  /// [title] and [message] make up the dialog content
  /// [destructiveActionName] will be an *uppercased* option on the dialog given in a red font.
  /// [destructiveActionCallback] is the callback from the above action.
  /// As well as the destructive action, there will be a "Cancel" option given
  static void destructive(
    BuildContext context, {
    @required String title,
    @required String message,
    @required String constructiveActionName,
    @required String destructiveActionName,
    Function destructiveActionCallback,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return _PlatformAlertDialog.stringContent(
            title: title,
            content: message,
            actions: <Widget>[
              FlatButton(
                child: Text(
                  constructiveActionName.toUpperCase(),
                  style: const TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  // Close the dialog.
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(destructiveActionName?.toUpperCase() ?? "",
                    style: const TextStyle(color: Colors.red)),
                onPressed: () {
                  // Close the dialog.
                  Navigator.of(context).pop();

                  destructiveActionCallback?.call();
                },
              )
            ],
          );
        });
  }

  /// Display a standard information dialog.
  static void infoDialog(
    BuildContext context,
    String title,
    String message, {
    String okButton = "OK",
    Function onOkClicked,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _PlatformAlertDialog.stringContent(
            title: title,
            content: message,
            actions: <Widget>[
              _PlatformDialogButton.stringContent(
                text: okButton ?? "OK",
                onPressed: () {
                  // Dialog is part of the Navigator.
                  // This will just close the *dialog*.
                  Navigator.pop(context);

                  onOkClicked?.call();
                },
              ),
            ],
          );
        });
  }

  /// Display a confirmation dialog, and set the required positive and negative
  /// buttons texts.
  static Future<bool> confirmationDialogAsync({
    BuildContext context,
    String title,
    String message,
    String positiveButtonText,
    String negativeButtonText,
  }) async {
    final bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _PlatformAlertDialog.stringContent(
            title: title,
            content: message,
            actions: <Widget>[
              _PlatformDialogButton.stringContent(
                text: negativeButtonText,
                onPressed: () {
                  // Dialog is pat of the Navigator.
                  // This will just close the *dialog*.
                  Navigator.pop(context, false);
                },
              ),
              _PlatformDialogButton.stringContent(
                text: positiveButtonText,
                onPressed: () {
                  // Return true for confirmation
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });

    return result;
  }
}

class _PlatformAlertDialog extends StatelessWidget {
  final String title;

  //String content;
  final Widget contentWidget;
  final List<Widget> actions;

  _PlatformAlertDialog.stringContent({String title, String content, List<Widget> actions})
      : this.widgetContent(title: title, actions: actions, contentWidget: Text(content));

  const _PlatformAlertDialog.widgetContent({this.title, this.contentWidget, this.actions});

  @override
  Widget build(BuildContext context) {
    switch (QuickDialogs.dialogTheme) {
      case DialogTheme.cupertinoOnly:
        return _createCupertinoDialog(title, contentWidget, actions);

      case DialogTheme.materialOnly:
        return _createMaterialDialog(title, contentWidget, actions);

      case DialogTheme.platformSpecific:
      default:
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return _createCupertinoDialog(title, contentWidget, actions);
        } else {
          return _createMaterialDialog(title, contentWidget, actions);
        }
    }
  }

  Widget _createCupertinoDialog(String title, Widget contentWidget, List<Widget> actions) {
    return CupertinoAlertDialog(
      title: title.isEmpty ? null : Text(title),
      content: contentWidget,
      actions: actions == null ? [] : actions,
    );
  }

  Widget _createMaterialDialog(String title, Widget contentWidget, List<Widget> actions) {
    return AlertDialog(
      title: Text(title),
      content: contentWidget,
      actions: actions == null ? [] : actions,
    );
  }
}

class _PlatformDialogButton extends StatelessWidget {
  final Widget textWidget;
  final Function onPressed;

  _PlatformDialogButton.stringContent({@required String text, @required Function onPressed})
      : this.widgetContent(textWidget: Text(text), onPressed: onPressed);

  const _PlatformDialogButton.widgetContent({@required this.textWidget, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    switch (QuickDialogs.dialogTheme) {
      case DialogTheme.cupertinoOnly:
        return _createCupertinoAction(textWidget, onPressed);

      case DialogTheme.materialOnly:
        return _createMaterialAction(textWidget, onPressed);

      case DialogTheme.platformSpecific:
      default:
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return _createCupertinoAction(textWidget, onPressed);
        } else {
          return _createMaterialAction(textWidget, onPressed);
        }
    }
  }

  Widget _createCupertinoAction(Widget textWidget, Function onPressed) {
    return CupertinoDialogAction(
      child: textWidget,
      onPressed: onPressed,
    );
  }

  Widget _createMaterialAction(Widget textWidget, Function onPressed) {
    return FlatButton(
      child: textWidget,
      onPressed: onPressed,
    );
  }
}
