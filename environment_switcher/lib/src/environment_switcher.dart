import 'package:environment_switcher/environment_switcher.dart';
import 'package:flutter/material.dart';

import 'environment.dart';
import 'environment_store.dart';
import 'select_environment_sheet.dart';

export 'environment.dart';
export 'environment_store.dart';

/// Inherited widget to allow access to the current environment field of the
/// state.
class InheritedEnvironmentSwitcher<T extends EnvironmentData> extends InheritedWidget {
  final Environment<T> currentEnvironment;

  InheritedEnvironmentSwitcher({
    Key key,
    @required Widget child,
    @required this.currentEnvironment,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedEnvironmentSwitcher<T> oldWidget) {
    return oldWidget.currentEnvironment != currentEnvironment;
  }
}

class EnvironmentSwitcher<T extends EnvironmentData> extends StatefulWidget {
  static const _title = "Select Environment";
  static const _description = "This switcher will not be present in the live version of the "
      "app. It's here to quickly switch between various environments (for example, live or "
      "mock data). It'll restart the app in order to make sure all the data is fresh.";

  final Widget Function(BuildContext) childBuilder;
  final List<Environment<T>> environments;
  final Environment defaultEnvironment;
  final EnvironmentStore _environmentStore;
  final bool showBanner;
  final String selectionTitle;
  final String selectionDescription;

  /// A banner that visually shows the user what [Environment]
  /// is currently set to.
  /// - `childBuilder` - This is the builder for the child on which the
  /// `EnvironmentSwitcher` will be built on top of.
  /// - `environments` - This is a list of `Environment` objects that will be
  /// displayed in the switcher for the tester to choose from. This cannot be
  /// empty.
  /// - `defaultEnvironment` - This sets the environment to use when either
  /// there is an issue with loading the saved environment, or when the banner
  /// is not shown (`showBanner: false`).
  /// - `environmentStore` - [Optional] This is preferences storage extension
  /// that can be used. The default `EnvironmentStorage` object uses the
  /// MyOxygen `Store` package to store the last used `Environment`.
  /// - `showBanner` - [Optional] This simply hides the banner from view. The
  /// idea is that on a Production release, developers can simply toggle this
  /// flag to disable the switcher. Default: `true`.
  EnvironmentSwitcher({
    @required this.childBuilder,
    @required this.environments,
    EnvironmentStore environmentStore, // mainly required for testing
    this.showBanner = true,
    @required this.defaultEnvironment,
    this.selectionTitle = _title,
    this.selectionDescription = _description,
  })  : assert(childBuilder != null),
        assert(environments != null && environments.length != 0),
        assert(showBanner != null),
        assert(defaultEnvironment != null),
        assert(selectionTitle != null && selectionTitle.trim().isNotEmpty),
        assert(selectionDescription != null && selectionDescription.trim().isNotEmpty),
        _environmentStore = environmentStore ?? EnvironmentStore(store: Store());

  @override
  State<StatefulWidget> createState() {
    return _StateEnvironmentSwitcher<T>();
  }

  static InheritedEnvironmentSwitcher<T> of<T extends EnvironmentData>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedEnvironmentSwitcher<T>>();
  }
}

class _StateEnvironmentSwitcher<T extends EnvironmentData> extends State<EnvironmentSwitcher<T>> {
  Environment<T> currentEnvironment;

  Environment<T> get firstEnvironmentOrDefault {
    if ((widget.environments ?? []).isNotEmpty) {
      return widget.environments[0];
    } else {
      return widget.defaultEnvironment;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we don't want to show the banner, we can hide it altogether easily.
    // When this happens, we want to show the default environment no matter the
    // previously saved environment
    // Note: Adding "== false" also acts as a null-check.
    if (widget.showBanner == false) {
      return InheritedEnvironmentSwitcher<T>(
        currentEnvironment: widget.defaultEnvironment,
        child: Builder(builder: widget.childBuilder),
      );
    }

    if (currentEnvironment == null) {
      // On first run, we need to load the saved environment (if any). If none
      // are saved, use the first in the list. If the list is empty, use the
      // default.
      return FutureBuilder<Environment<T>>(
        future: _getSavedEnvironmentOrDefault(),
        builder: (context, snapshot) {
          currentEnvironment = snapshot.data ?? firstEnvironmentOrDefault;
          return _buildBanner(currentEnvironment);
        },
      );
    } else {
      return _buildBanner(currentEnvironment);
    }
  }

  Widget _buildBanner(Environment<T> environment) {
    return InheritedEnvironmentSwitcher<T>(
      currentEnvironment: environment,
      child: LocalBanner<T>(
        onBannerTapped: _onBannerTapped,
        childBuilder: widget.childBuilder,
      ),
    );
  }

  Future<Environment<T>> _getSavedEnvironmentOrDefault() async {
    final savedEnvironmentName = await widget._environmentStore.getSavedEnvironment();
    if (savedEnvironmentName == null) {
      print("No environment saved");
      return firstEnvironmentOrDefault;
    }
    final environment = widget.environments
        ?.firstWhere((env) => env.name == savedEnvironmentName, orElse: () => null);
    if (environment == null) {
      print("Environment not found in list");
      return firstEnvironmentOrDefault;
    }
    return environment;
  }

  void _onBannerTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => InheritedEnvironmentSwitcher<T>(
        currentEnvironment: currentEnvironment,
        child: SelectEnvironmentSheet(
          environments: widget.environments,
          onNewEnvironmentSelected: _onNewEvironmentTapped,
          title: widget.selectionTitle,
          description: widget.selectionDescription,
        ),
      ),
    );
  }

  Future<void> _onNewEvironmentTapped(Environment<T> newEnvironment) async {
    try {
      await widget._environmentStore.saveEnvironment(newEnvironment);
      setState(() {
        currentEnvironment = newEnvironment;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class LocalBanner<T extends EnvironmentData> extends StatelessWidget {
  final Widget Function(BuildContext) childBuilder;
  final void Function(BuildContext) onBannerTapped;

  const LocalBanner({
    this.childBuilder,
    @required this.onBannerTapped,
  })  : assert(childBuilder != null),
        assert(onBannerTapped != null);

  @override
  Widget build(BuildContext context) {
    final environment = EnvironmentSwitcher.of<T>(context)?.currentEnvironment;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: (environment == null || !environment.isNameValid)
          ? Builder(builder: childBuilder)
          : Stack(
              children: <Widget>[
                Banner(
                  message: environment.name,
                  location: BannerLocation.topEnd,
                  color: environment.bannerColor,
                  child: Builder(builder: childBuilder),
                ),
                _BannerHitBox(onTap: onBannerTapped),
              ],
            ),
    );
  }
}

class _BannerHitBox extends StatelessWidget {
  final void Function(BuildContext context) onTap;
  final double size;

  /// This an invisible gesture detector that's approx
  /// the size of the banner.
  /// A gesture detector ensures that only tap events in
  /// this box trigger the callback.
  ///
  /// If you apply the GestureDetector to the banner causes it to
  /// intercept all touch events.
  const _BannerHitBox({
    @required this.onTap,
    this.size = 80, // this is about the size of the banner.
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(context),
        child: SizedBox(
          width: size,
          height: size,
        ),
      ),
    );
  }
}
