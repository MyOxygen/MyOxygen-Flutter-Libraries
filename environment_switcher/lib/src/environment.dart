import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'environment_data.dart';

export 'environment_data.dart';

class Environment<T extends EnvironmentData> extends Equatable {
  final String name;
  final String description;
  final Color bannerColor;
  final T data;

  bool get isNameValid => name != null && name.trim().isNotEmpty;

  /// Creates an environment object.
  /// - `name` : The name of the environment. This acts as the "header/title" of
  /// the environment.
  /// - `description` : A short description explaining what makes this object
  /// different to another [Environment] object.
  /// - `bannerColor` : The colour of the banner to easily show which environment
  /// is active.
  /// - `values` : Any additional information per object should be passed here.
  Environment({
    @required this.name,
    @required this.description,
    @required this.bannerColor,
    this.data,
  })  : assert(name != null && name.trim().isNotEmpty),
        assert(description != null && description.trim().isNotEmpty),
        assert(bannerColor != null);

  @override
  List<Object> get props => [name, description, bannerColor, data];
}
