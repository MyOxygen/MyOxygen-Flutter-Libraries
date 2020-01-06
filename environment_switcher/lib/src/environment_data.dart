import 'package:equatable/equatable.dart';

/// An abstract class to be able to pass any fields and provide assertions in
/// the constructors. No default fields are required for [EnvironmentData] to
/// function.
abstract class EnvironmentData extends Equatable {
  const EnvironmentData();
}
