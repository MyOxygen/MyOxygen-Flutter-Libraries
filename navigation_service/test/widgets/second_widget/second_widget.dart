import 'package:flutter/material.dart';
import 'package:navigation_service/navigation_service.dart';

import 'second_widget_configuration.dart';

export 'second_widget_configuration.dart';

class SecondWidget extends StatefulPage<SecondWidgetConfiguration> {
  const SecondWidget(SecondWidgetConfiguration configuration) : super(configuration);

  @override
  SecondWidgetState createState() => SecondWidgetState();
}

class SecondWidgetState extends State<SecondWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.configuration.onTap,
      child: Container(
        color: const Color(0xFFFF00FF),
        child: const Text('Y'),
      ),
    );
  }
}
