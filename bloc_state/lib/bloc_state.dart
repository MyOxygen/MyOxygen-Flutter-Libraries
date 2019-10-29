library bloc_state;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A subclass to remove some of the boilerplate around creating [Bloc]s.
/// It means you'll never forget to dispose them.
abstract class BlocWidgetState<W extends StatefulWidget, T<E, S> extends Bloc<WidgetEvent, WidgetState>>
    extends State<W> {
  Bloc<WidgetEvent, WidgetState> bloc;

  /// Initialize the bloc you're using.
  Bloc<WidgetEvent, WidgetState> createBloc();

  /// A replacement for the [build] function that replaces some of the boilerplate
  /// around blocs.
  /// [localizations] is there for convenience.
  Widget buildFromState(BuildContext context, WidgetState state);

  /// Called once when state is changed, from outside the stream.
  /// Here is where you use [Router] or [SnackBar]
  void onStateChange(BuildContext context, WidgetState state) {
    // override this method if it's necessary to react to a state change.
  }

  /// use this to invoke an event as soon as the bloc is created.
  /// i.e. to load the page data. if it'll null it'll be ignored.
  WidgetEvent get initialEvent => null;

  /// controls if the bloc should be disposed when this widget disposes.
  /// defaults to true.
  bool get automaticallyDisposeBloc => true;

  void onBlocCreated(Bloc<WidgetEvent, WidgetState> bloc) {
    // override this method to dispatch an event to the bloc as soon as it's created.
    // e.g. to load page content.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (bloc == null) {
      bloc = createBloc();
      onBlocCreated(bloc);
      if (initialEvent != null) {
        bloc.add(initialEvent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: bloc,
      listener: onStateChange,
      child: BlocBuilder(
        bloc: bloc,
        builder: (context, state) => buildFromState(context, state),
      ),
    );
  }

  @override
  void dispose() {
    if (automaticallyDisposeBloc) {
      bloc?.dispose();
      bloc = null;
    }

    super.dispose();
  }
}
