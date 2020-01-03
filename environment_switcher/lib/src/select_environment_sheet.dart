import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment.dart';
import 'environment_bloc.dart';
import 'environment_bloc_event.dart';

export 'environment.dart';

class SelectEnvironmentSheet extends StatelessWidget {
  static const _titlePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const _textPadding = EdgeInsets.symmetric(horizontal: 20);

  final List<Environment> environments;

  SelectEnvironmentSheet({
    @required this.environments,
  }) : assert(environments != null && environments.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final environmentBloc = BlocProvider.of<EnvironmentBloc>(context);
    final currentEnvironment = environmentBloc.state.environment;

    final builtWidget = SafeArea(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: _titlePadding,
            child: Text(
              "Select Environment",
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Padding(
            padding: _textPadding,
            child: Text(
              "This switcher will not be present in the live version of the "
              "app. It's here to quickly switch between using the server and "
              "mock data. It'll restart the app in order to make sure all the "
              "data is fresh.",
            ),
          ),
          ...environments.map((type) => _EnvironmentTile(
                type,
                selected: type == currentEnvironment,
              )),
        ],
      )),
    );

    environmentBloc.close();

    return builtWidget;
  }
}

class _EnvironmentTile extends StatelessWidget {
  final Environment type;
  final bool selected;

  const _EnvironmentTile(this.type, {@required this.selected})
      : assert(type != null),
        assert(selected != null);

  @override
  Widget build(BuildContext context) {
    final subtitle = "${type.description}\n${type.value}";

    return ListTile(
      title: Text(
        type.name,
      ),
      subtitle: Text(subtitle),
      leading: selected
          ? Icon(
              Icons.check,
              color: type.bannerColor,
            )
          : const SizedBox(),
      onTap: () => _onTileSelected(context),
    );
  }

  void _onTileSelected(BuildContext context) {
    final environmentBloc = BlocProvider.of<EnvironmentBloc>(context);

    /// if it's already selected, just close.
    if (environmentBloc.state.environment == type) {
      Navigator.pop(context);
    } else {
      BlocProvider.of<EnvironmentBloc>(context).add(
        ChangeEnvironmentEvent(type),
      );
    }

    environmentBloc.close();
  }
}
