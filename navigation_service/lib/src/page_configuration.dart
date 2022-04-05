import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Abstract configuration class to be used when creating new pages. A new page
/// should have its arguments laid out in a configuration file to facilitate
/// navigation and prevent unwanted data being passed through.
///
/// All fields within this class should be final.
@immutable
abstract class PageConfiguration extends Equatable {
  /// Corresponds to [fullScreenDialog] in [MaterialPageRoute]
  bool get isFullscreenDialog => false;

  /// Corresponds to [maintainState] in [MaterialPageRoute]
  bool get maintainState => true;

  String get route;

  const PageConfiguration();

  Widget createPage();
}
