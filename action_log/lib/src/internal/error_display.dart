import 'package:flutter/material.dart';

/// Simple error display if something goes wrong.
class ErrorDisplay extends StatelessWidget {
  final String message;

  const ErrorDisplay(this.message) : assert(message != null);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red),
      ),
    );
  }
}
