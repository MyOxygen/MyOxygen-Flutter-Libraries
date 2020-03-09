import 'package:flutter/material.dart';

import 'page_configuration.dart';

export 'page_configuration.dart';

/// Abstract class to allow creating pages as a [StatelessWidget].
abstract class StatelessPage<T extends PageConfiguration> extends StatelessWidget {
  final T configuration;

  const StatelessPage(this.configuration) : assert(configuration != null);
}
