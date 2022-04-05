import 'package:flutter/material.dart';

import 'page_configuration.dart';

export 'page_configuration.dart';

/// Abstract class to allow creating pages as a [StatefulWidget].
abstract class StatefulPage<T extends PageConfiguration> extends StatefulWidget {
  final T configuration;

  const StatefulPage(this.configuration) : assert(configuration != null);
}
