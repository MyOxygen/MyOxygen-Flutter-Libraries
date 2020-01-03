import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'environment.dart';

export 'environment.dart';

class SelectEnvironmentSheet extends StatelessWidget {
  static const _titlePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const _textPadding = EdgeInsets.symmetric(horizontal: 20);

  final List<Environment> environments;
  final Environment currentEnvironment;
  final void Function(Environment) onNewEnvironmentSelected;

  SelectEnvironmentSheet({
    @required this.environments,
    @required this.currentEnvironment,
    @required this.onNewEnvironmentSelected,
  })  : assert(environments != null && environments.isNotEmpty),
        assert(currentEnvironment != null),
        assert(onNewEnvironmentSelected != null);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                onSelected: onNewEnvironmentSelected,
              )),
        ],
      )),
    );
  }
}

class _EnvironmentTile extends StatelessWidget {
  final Environment type;
  final bool selected;
  final void Function(Environment) onSelected;

  const _EnvironmentTile(
    this.type, {
    @required this.selected,
    @required this.onSelected,
  })  : assert(type != null),
        assert(selected != null),
        assert(onSelected != null);

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
    /// if it's already selected, just close.
    if (selected) {
      Navigator.pop(context);
    } else {
      onSelected?.call(type);
    }
  }
}
