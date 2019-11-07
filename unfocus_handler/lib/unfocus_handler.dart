library unfocus_handler;

import 'package:flutter/material.dart';

class UnfocusHandler extends StatelessWidget {
  final Widget child;

  /// Wrap this around a view to automatically clear focus when the user
  /// taps outside of the text field.
  const UnfocusHandler({@required this.child}) : assert(child != null);

  /// Clears any focus on the page.
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () => clearFocus(context),
    );
  }
}
