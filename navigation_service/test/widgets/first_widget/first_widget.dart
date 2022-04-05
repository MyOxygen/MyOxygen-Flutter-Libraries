import 'package:flutter/material.dart';
import 'package:navigation_service/navigation_service.dart';

import 'first_widget_configuration.dart';

export 'first_widget_configuration.dart';

class FirstWidget extends StatelessPage<FirstWidgetConfiguration> {
  const FirstWidget(FirstWidgetConfiguration configuration) : super(configuration);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: configuration.onNavigateTo,
      child: Container(
        color: const Color(0xFFFFFF00),
        child: const Text('X'),
      ),
    );
  }
}
