library infinite_scroll_view;

import 'package:flutter/material.dart';

import 'infinite_scroll_controller.dart';

/// This is a wrapper class to facilitte creating a [ListView] that continuously
/// updates its contents as the user scrolls down the list.
class InfiniteScrollView extends StatefulWidget {
  final Widget Function(BuildContext, int index) builder;
  final int itemCount;
  final Function onReachedEndCallback;
  final int endOfScrollOffset;
  final ScrollController scrollController;
  final Widget separator;
  final EdgeInsets padding;
  final Widget loadingFooter;

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
    this.loadingFooter = const CircularProgressIndicator(),
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
    final itemCount = widget.loadingFooter == null ? widget.itemCount : widget.itemCount + 1;

    if (widget.separator == null) {
      return ListView.builder(
        padding: widget.padding,
        itemBuilder: widget.builder,
        itemCount: itemCount,
        controller: _infiniteScrollController.scrollController,
      );
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) =>
            index == (widget.itemCount - 2) ? const SizedBox() : widget.separator,
        padding: widget.padding,
        itemBuilder: _buildItem,
        itemCount: itemCount,
        controller: _infiniteScrollController.scrollController,
      );
    }
  }

  @override
  void dispose() {
    _infiniteScrollController?.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index >= widget.itemCount) {
      return _EndListProgressIndicator(progressIndicator: widget.loadingFooter);
    } else {
      return widget.builder(context, index);
    }
  }
}

class _EndListProgressIndicator extends StatelessWidget {
  final Widget progressIndicator;

  const _EndListProgressIndicator({
    this.progressIndicator = const CircularProgressIndicator(),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: progressIndicator,
      ),
    );
  }
}
