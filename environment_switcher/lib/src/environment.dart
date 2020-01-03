import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/*
 * The text in here doesn't need to be localized. It's just 
 * for testing builds and won't make it to the proper live release
 */

class Environment extends Equatable {
  final String name;
  final String description;
  final Color bannerColor;
  final String databaseName;
  final String value;

  Environment({
    @required this.name,
    @required this.description,
    @required this.bannerColor,
    @required this.databaseName,
    this.value,
  })  : assert(name != null && name.trim().isNotEmpty),
        assert(description != null && description.trim().isNotEmpty),
        assert(bannerColor != null),
        assert(databaseName != null && databaseName.trim().isNotEmpty);

  @override
  List<Object> get props => [name, description, bannerColor, databaseName, value];
}
