import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';

import 'environment.dart';
import 'environment_bloc_event.dart';
import 'environment_bloc_state.dart';
import 'environment_store.dart';

export 'environment.dart';
export 'environment_bloc_state.dart';
export 'environment_bloc_event.dart';
export 'environment_store.dart';

class EnvironmentBloc extends Bloc<EnvironmentBlocEvent, EnvironmentBlocState> {
  final EnvironmentStore environmentStore;
  final List<Environment> environments;

  EnvironmentBloc({
    @required this.environmentStore,
    @required this.environments,
  })  : assert(environmentStore != null),
        assert(environments != null && environments.length != 0);

  @override
  EnvironmentBlocState get initialState => EnvironmentBlocState.initial();

  @override
  Stream<EnvironmentBlocState> mapEventToState(EnvironmentBlocEvent event) {
    if (event is LoadEnvironmentEvent) {
      return _handleLoadEnvironmentEvent(event);
    } else if (event is ChangeEnvironmentEvent) {
      return _handleChangeEnvironmentEvent(event);
    }

    throw ArgumentError("Unknown event: $event");
  }

  Stream<EnvironmentBlocState> _handleLoadEnvironmentEvent(LoadEnvironmentEvent event) async* {
    try {
      final savedEnvironmentName = await environmentStore.getSavedEnvironment();
      if (savedEnvironmentName == null) {
        throw "No environment saved";
      }
      final environment =
          environments.firstWhere((env) => env.name == savedEnvironmentName, orElse: () => null);
      if (environment == null) {
        throw "Environment not found in list";
      }

      yield EnvironmentBlocState.environment(environment);
    } catch (e) {
      print(e.toString());
      yield EnvironmentBlocState.environment(event.defaultEnvironment);
    }
  }

  Stream<EnvironmentBlocState> _handleChangeEnvironmentEvent(ChangeEnvironmentEvent event) async* {
    try {
      await environmentStore.saveEnvironment(event.environment);
      yield EnvironmentBlocState.environment(event.environment);
    } catch (e) {
      print(e.toString());
    }
  }
}
