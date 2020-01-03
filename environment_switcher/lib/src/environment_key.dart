import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment.dart';
import 'environment_bloc.dart';

export 'environment.dart';

class EnvironmentKey extends ValueKey<Environment> {
  /// A Key that is tied to an instance of [Environments]
  /// Mark a widget with this key if you want it to rebuild
  /// whenever the environment changes.
  const EnvironmentKey(Environment value) : super(value);

  /// A factory constructor to reduce boilerplace.
  factory EnvironmentKey.of(BuildContext context) {
    final currentEnvironment = BlocProvider.of<EnvironmentBloc>(context).state.environment;
    return EnvironmentKey(currentEnvironment);
  }
}
