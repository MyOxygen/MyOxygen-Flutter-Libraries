import 'package:flutter/material.dart';

/// A wrapper around [ScrollController] that listens to scroll events and when
/// it gets to within [delta] pixels of the end. Will notify via [reachedEndCallback]
class InfiniteScrollController {
  final ScrollController scrollController;
  final int delta;
  final Function reachedEndCallback;
  bool _hasCallbackBeenExecuted = false;

  /// [reachedEndCallback] is called when the scrollview gets to within [delta] of the end of the list.
  /// You can manually add a scroll controller, otherwise a default one will be created.
  InfiniteScrollController({
    this.reachedEndCallback,
    ScrollController controller,
    this.delta = 100,
  }) : scrollController = controller ?? ScrollController() {
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final double maxScroll = scrollController.position.maxScrollExtent;
    final double currentScroll = scrollController.position.pixels;
    final bool hasReachedEnd = (maxScroll - currentScroll < delta);

    if ((hasReachedEnd) && (reachedEndCallback != null) && (!_hasCallbackBeenExecuted)) {
      _hasCallbackBeenExecuted = true;
      reachedEndCallback();
    } else if (!hasReachedEnd) {
      _hasCallbackBeenExecuted = false;
    }
  }

  void dispose() {
    scrollController?.dispose();
  }
}
