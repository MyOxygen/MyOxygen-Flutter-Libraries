library infinite_scroll_view;

import 'package:flutter/material.dart';

import 'infinite_scroll_controller.dart';

/// This is a wrapper class to facilitte creating a [ListView] that continuously
/// updates its contents as the user scrolls down the list.
class InfiniteScrollView extends StatefulWidget {
  final Function(BuildContext, int index) builder;
  final int itemCount;
  final Function onReachedEndCallback;
  final int endOfScrollOffset;
  final ScrollController scrollController;
  final Widget separator;
  final EdgeInsets padding;

  /// Creates a [ListView] with infinite scroll capabilities.
  ///
  /// [builder] - The builder for creating each list item. This cannot be null.
  /// [itemCount] - The total number of items in the list **after** they would
  /// be added. This cannot be null, and must be creater than 0.
  /// [onReachedEndCallback] - The callback for when the user has scrolled to
  /// the bottom of the list.
  const InfiniteScrollView({
    Key key,
    @required this.builder,
    @required this.itemCount,
    @required this.onReachedEndCallback,
    this.endOfScrollOffset = 100,
    this.scrollController,
    this.separator,
    this.padding,
  })  : assert(builder != null),
        assert(itemCount != null),
        assert(itemCount > 0),
        super(key: key);

  _InfiniteScrollViewState createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  InfiniteScrollController _infiniteScrollController;

  @override
  void initState() {
    super.initState();

    _infiniteScrollController = InfiniteScrollController(
      reachedEndCallback: widget.onReachedEndCallback,
      delta: widget.endOfScrollOffset,
      controller: widget.scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.separator == null) {
      return ListView.builder(
        padding: widget.padding,
        itemBuilder: widget.builder,
        itemCount: widget.itemCount,
        controller: _infiniteScrollController.scrollController,
      );
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) => widget.separator,
        padding: widget.padding,
        itemBuilder: widget.builder,
        itemCount: widget.itemCount,
        controller: _infiniteScrollController.scrollController,
      );
    }
  }

  @override
  void dispose() {
    _infiniteScrollController?.dispose();
    super.dispose();
  }
}
