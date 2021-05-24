library do_on_build;

import 'package:flutter/material.dart';

/// Does an action once the page has been built. Can be safely called from
/// StreamBuilders.
void doOnBuild(VoidCallback callback) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    callback.call();
  });
}
