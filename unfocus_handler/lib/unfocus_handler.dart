library unfocus_handler;

import 'package:flutter/material.dart';

class UnfocusHandler extends StatelessWidget {
  final Widget child;
  final bool excludeFromSemantics;

  /// Wrap this around a view to automatically clear focus when the user
  /// taps outside of the text field.
  /// To allow screen-readers to express "double tap to active" (or similar),
  /// set `excludeFromSemantics` to `false`.
  const UnfocusHandler({
    @required this.child,
    this.excludeFromSemantics = true,
  })  : assert(child != null),
        assert(excludeFromSemantics != null);

  /// Clears any focus on the page.
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      excludeFromSemantics: excludeFromSemantics,
      onTap: () => clearFocus(context),
    );
  }
}
