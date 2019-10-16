import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infinite_scroll_view/infinite_scroll_view.dart';

const double _itemHeight = 200.0;
const int _itemCount = 10;

Future<void> _createApp(
  WidgetTester tester,
  Function onEndCallback, {
  int endOfScrollOffset = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: InfiniteScrollView(
          onReachedEndCallback: onEndCallback,
          itemCount: _itemCount,
          endOfScrollOffset: endOfScrollOffset,
          builder: (BuildContext context, int index) {
            return Container(
              height: _itemHeight,
              child: Text('$index'),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('ListView itemExtent control test', (WidgetTester tester) async {
    await _createApp(tester, null);

    final RenderBox box = tester.renderObject<RenderBox>(find.byType(Container).first);
    expect(box.size.height, equals(_itemHeight));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsNothing);

    // Scroll down by <one item and a half>'s height
    await tester.drag(find.byType(ListView), const Offset(0.0, -(_itemHeight * 1.5)));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsNothing);
    expect(find.text('6'), findsNothing);

    // Scroll back up by one item's height.
    await tester.drag(find.byType(ListView), const Offset(0.0, _itemHeight));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsNothing);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('ListView scroll to bottom test', (WidgetTester tester) async {
    bool scrollReachedEnd = false;
    await _createApp(tester, () => scrollReachedEnd = true, endOfScrollOffset: 1);

    final RenderBox box = tester.renderObject<RenderBox>(find.byType(Container).first);
    expect(box.size.height, equals(_itemHeight));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsNothing);

    expect(scrollReachedEnd, false);
    // Scroll down the full length minus the height of one item. The scroll
    // hasn't reached the end of the ListView, therefore it should not trigger
    // the callback.
    // NOTE: the initial drag start includes the height of 3 items. These need
    // to be subtracted to get to the actual bottom of the list. Subtract (3 *
    // `_itemHeight`) to get to the bottom of the last item. Subtract (4 *
    // `_itemHeight`) to get to the bottom of the penultimate item.
    await tester.drag(
        find.byType(ListView), const Offset(0.0, -((_itemHeight * _itemCount) - 4 * _itemHeight)));
    await tester.pump();
    expect(scrollReachedEnd, false);

    expect(find.text('5'), findsNothing);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsNothing);

    // Scroll down a further height of one item (the remaining height). This
    // should reach the end and trigger the callback.
    await tester.drag(find.byType(ListView), const Offset(0.0, -_itemHeight));
    await tester.pump();
    expect(scrollReachedEnd, false); // We still have the loading widget to show!

    expect(find.text('5'), findsNothing);
    expect(find.text('6'), findsNothing);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Scroll down a further height of one item. This should display the footer
    // at the bottom, and by convention the scroll should reach the end.
    await tester.drag(find.byType(ListView), const Offset(0.0, -_itemHeight));
    await tester.pump();
    expect(scrollReachedEnd, true);
  });

  testWidgets('ListView scroll to bottom with offset test', (WidgetTester tester) async {
    bool scrollReachedEnd = false;
    // Offset set to trigger only once the user scrolls past the penultimate
    // item.
    await _createApp(tester, () => scrollReachedEnd = true, endOfScrollOffset: _itemHeight.toInt());

    final RenderBox box = tester.renderObject<RenderBox>(find.byType(Container).first);
    expect(box.size.height, equals(_itemHeight));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsNothing);

    expect(scrollReachedEnd, false);
    // Scroll down to the bottom of the penultimate item.
    await tester.drag(
        find.byType(ListView), const Offset(0.0, -((_itemHeight * _itemCount) - 4 * _itemHeight)));
    await tester.pump();
    expect(scrollReachedEnd, false);

    expect(find.text('5'), findsNothing);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsNothing);

    expect(scrollReachedEnd, false);
    // Scrolling down by 1 pixel should trigger the callback.
    await tester.drag(find.byType(ListView), const Offset(0.0, -1.0));
    await tester.pump();
    expect(scrollReachedEnd, false); // Still need to show the indicator!

    expect(find.text('5'), findsNothing);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    // Scroll down a further height of one item. This should display the footer
    // at the bottom, and by convention the scroll should reach the end.
    await tester.drag(find.byType(ListView), const Offset(0.0, -_itemHeight));
    await tester.pump();
    expect(scrollReachedEnd, true);
  });
}
