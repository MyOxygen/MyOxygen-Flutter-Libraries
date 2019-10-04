import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_on_build/do_on_build.dart';

MaterialApp _buildTestApp(Function onBuild, {Function testsWhileBuilding}) {
  return MaterialApp(
    home: Material(
      child: Builder(
        builder: (BuildContext context) {
          onBuild?.call();
          testsWhileBuilding?.call();
          return Center(
            child: const Text("Open Dialog"),
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('doOnBuild() called only after build() is complete', (WidgetTester tester) async {
    bool hasBeenBuilt = false;

    await tester.pumpWidget(_buildTestApp(
      () => doOnBuild(() => hasBeenBuilt = true),
      testsWhileBuilding: () => expect(hasBeenBuilt, false),
    ));

    expect(hasBeenBuilt, true);
  });
}
