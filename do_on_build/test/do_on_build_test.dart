import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_on_build/do_on_build.dart';

MaterialApp _buildTestApp(Function onBuild, {required VoidCallback testsWhileBuilding}) {
  return MaterialApp(
    home: Material(
      child: Builder(
        builder: (BuildContext context) {
          onBuild.call();
          testsWhileBuilding.call();
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

  testWidgets('Numerous doOnBuild() methods called one after the other',
      (WidgetTester tester) async {
    int counter = 0;
    int shouldBeOne = 0, shouldBeTwo = 0, shouldBeThree = 0;

    await tester.pumpWidget(_buildTestApp(
      () {
        doOnBuild(() {
          counter++;
          shouldBeOne = counter;
        });
        doOnBuild(() {
          counter++;
          shouldBeTwo = counter;
        });
        doOnBuild(() {
          counter++;
          shouldBeThree = counter;
        });
      },
      testsWhileBuilding: () {},
    ));

    expect(shouldBeOne, 1);
    expect(shouldBeTwo, 2);
    expect(shouldBeThree, 3);
  });
}
