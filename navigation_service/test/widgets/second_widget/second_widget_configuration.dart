import 'package:flutter/src/widgets/framework.dart';
import 'package:navigation_service/navigation_service.dart';

import 'second_widget.dart';

class SecondWidgetConfiguration extends PageConfiguration {
  final String _route;
  final void Function() onTap;

  SecondWidgetConfiguration(String route, this.onTap) : _route = route;

  @override
  Widget createPage() {
    return SecondWidget(this);
  }

  @override
  List<Object> get props => [_route, onTap];

  @override
  String get route => _route;
}
