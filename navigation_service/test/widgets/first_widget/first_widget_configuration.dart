import 'package:flutter/src/widgets/framework.dart';
import 'package:navigation_service/navigation_service.dart';

import 'first_widget.dart';

class FirstWidgetConfiguration extends PageConfiguration {
  final String _route;
  final void Function() onNavigateTo;

  FirstWidgetConfiguration(String route, this.onNavigateTo) : _route = route;

  @override
  Widget createPage() {
    return FirstWidget(this);
  }

  @override
  List<Object> get props => [_route, onNavigateTo];

  @override
  String get route => _route;
}
