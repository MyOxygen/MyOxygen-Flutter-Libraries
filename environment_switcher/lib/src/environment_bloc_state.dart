import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'environment.dart';

export 'environment.dart';

@immutable
class EnvironmentBlocState extends Equatable {
  final Environment environment;

  String get bannerText => environment.name;

  Color get bannerColor => environment.bannerColor;

  String get baseUrl => environment.value;

  bool get useMockRepositories => baseUrl.isEmpty;

  bool get isLoading => environment == null;

  /// Private constructor.
  const EnvironmentBlocState._({
    @required this.environment,
  });

  /// Initial state
  factory EnvironmentBlocState.initial() {
    return const EnvironmentBlocState._(environment: null);
  }

  factory EnvironmentBlocState.environment(Environment environment) {
    return EnvironmentBlocState._(environment: environment);
  }

  @override
  List<Object> get props => [environment];
}
