import 'package:flutter/material.dart';

import 'environment.dart';

export 'environment.dart';

class EnvironmentKey extends ValueKey<Environment> {
  /// A Key that is tied to an instance of [Environments]
  /// Mark a widget with this key if you want it to rebuild
  /// whenever the environment changes.
  const EnvironmentKey(Environment value) : super(value);
}
