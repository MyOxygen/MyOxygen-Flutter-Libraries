import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'environment.dart';
import 'environment_switcher.dart';

export 'environment.dart';

class SelectEnvironmentSheet<T extends EnvironmentData> extends StatelessWidget {
  static const _titlePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const _textPadding = EdgeInsets.symmetric(horizontal: 20);

  final List<Environment<T>> environments;
  final void Function(Environment<T>) onNewEnvironmentSelected;
  final String title;
  final String description;

  SelectEnvironmentSheet({
    @required this.environments,
    @required this.onNewEnvironmentSelected,
    @required this.title,
    @required this.description,
  })  : assert(environments != null && environments.isNotEmpty),
        assert(onNewEnvironmentSelected != null),
        assert(title != null && title.trim().isNotEmpty),
        assert(description != null && description.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final currentEnvironment = EnvironmentSwitcher.of<T>(context)?.currentEnvironment;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: _titlePadding,
              child: Text(
                title,
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),
            Padding(
              padding: _textPadding,
              child: Text(
                description,
                textAlign: TextAlign.justify,
              ),
            ),
            ...environments.map(
              (type) => _EnvironmentTile(
                type,
                selected: type == currentEnvironment,
                onSelected: onNewEnvironmentSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentTile<T extends EnvironmentData> extends StatelessWidget {
  final Environment type;
  final bool selected;
  final void Function(Environment<T>) onSelected;

  const _EnvironmentTile(
    this.type, {
    @required this.selected,
    @required this.onSelected,
  })  : assert(type != null),
        assert(selected != null),
        assert(onSelected != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        type.name,
      ),
      subtitle: Text(type.description),
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
    if (!selected) {
      onSelected?.call(type);
    }

    Navigator.pop(context);
  }
}
