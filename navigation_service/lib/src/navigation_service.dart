import 'package:flutter/material.dart';
import 'page_configuration.dart';

export 'page_configuration.dart';

class NavigationService {
  /// The [navigatorKey] must be placed within the [MatterialApp]'s or
  /// [CupertinoApp]'s [navigatorKey] property.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Widget Function(Widget overlay) overlayBuilder;

  /// Constructor not required, as the entire class uses static methods.
  NavigationService._();

  /// Navigates to the desired page using the [configuration]'s [route].
  static Future<T> navigateTo<T>(PageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.route != null);
    return navigatorKey.currentState.pushNamed<T>(configuration.route, arguments: configuration);
  }

  /// Navigate to a route named [route] with the provided [configuration], and
  /// pop the route before if they share the same name. This prevents having the
  /// same page open (for example) three times.
  static Future<T> navigateSingleInstance<T>(PageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.route != null);
    return navigatorKey.currentState.pushNamedAndRemoveUntil<T>(
      configuration.route,
      (route) => !route.isCurrent || route.settings.name != configuration.route,
      arguments: configuration,
    );
  }

  /// Replace the current navigation stack with the [configuration] provided.
  static Future<T> navigateReplacing<T>(PageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.route != null);
    return navigatorKey.currentState
        .pushReplacementNamed<T, void>(configuration.route, arguments: configuration);
  }

  /// If possible, navigates back to the previous screen. The optional [result]
  /// will be passed to the previous page.
  static void pop([dynamic result]) {
    final navigator = navigatorKey.currentState;
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  /// If possible, pops until you get to the first page.
  static void popToRoot() {
    final navigator = navigatorKey.currentState;
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  /// Pop until you get to a route with the given name.
  static void popToNamed(String routeName) {
    navigatorKey.currentState.popUntil((route) => route.settings.name == routeName);
  }

  /// Gets the [Route] to build and navigate to.
  static Route getRoute(RouteSettings settings) {
    assert(settings.arguments is PageConfiguration);
    final configuration = settings.arguments as PageConfiguration;

    return _buildRoute(configuration);
  }

  /// Creates a [MaterialPageRoute] to pass on to the navigation handler with
  /// the page [configuration] passed.
  static MaterialPageRoute _buildRoute(PageConfiguration configuration) {
    return MaterialPageRoute(
      builder: (_) {
        /// Apply `overlayBuilder` to every page, if available.
        if (overlayBuilder != null) {
          return overlayBuilder(configuration.createPage());
        } else {
          return configuration.createPage();
        }
      },
      maintainState: configuration.maintainState,
      fullscreenDialog: configuration.isFullscreenDialog,
    );
  }
}
