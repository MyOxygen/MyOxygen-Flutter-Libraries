import 'package:flutter/foundation.dart';

import 'environment.dart';

export 'environment.dart';

@immutable
abstract class EnvironmentBlocEvent {}

/// Load the persisted environment.
class LoadEnvironmentEvent implements EnvironmentBlocEvent {
  final Environment defaultEnvironment;

  const LoadEnvironmentEvent({@required this.defaultEnvironment})
      : assert(defaultEnvironment != null);
}

class ChangeEnvironmentEvent implements EnvironmentBlocEvent {
  final Environment environment;

  const ChangeEnvironmentEvent(this.environment) : assert(environment != null);
}
