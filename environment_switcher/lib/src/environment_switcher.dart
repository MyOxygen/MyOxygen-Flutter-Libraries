import 'package:environment_switcher/environment_switcher.dart';
import 'package:flutter/material.dart';

import 'environment.dart';
import 'environment_store.dart';
import 'select_environment_sheet.dart';

export 'environment.dart';
export 'environment_store.dart';

/// Inherited widget to allow access to the current environment field of the
/// state.
class _EnvironmentSwitcher extends InheritedWidget {
  final Environment currentEnvironment;

  _EnvironmentSwitcher({
    Key key,
    @required Widget child,
    @required this.currentEnvironment,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class EnvironmentSwitcher extends StatefulWidget {
  static const _title = "Select Environment";
  static const _description = "This switcher will not be present in the live version of the "
      "app. It's here to quickly switch between various environments (for example, live or "
      "mock data). It'll restart the app in order to make sure all the data is fresh.";

  final Widget Function(BuildContext) childBuilder;
  final List<Environment> environments;
  final Environment defaultEnvironment;
  final EnvironmentStore _environmentStore;
  final bool showBanner;
  final String selectionTitle;
  final String selectionDescription;

  /// A banner that visually shows the user what [Environment]
  /// is currently set to.
  EnvironmentSwitcher({
    @required this.childBuilder,
    @required this.environments,
    EnvironmentStore environmentStore, // mainly required for testing
    this.showBanner = true,
    this.defaultEnvironment,
    this.selectionTitle = _title,
    this.selectionDescription = _description,
  })  : assert(childBuilder != null),
        assert(environments != null && environments.length != 0),
        assert(showBanner != null),
        assert(showBanner ? defaultEnvironment != null : true,
            "The EnvironmentSwitcher needs a default environment if the banner is showing."),
        assert(selectionTitle != null && selectionTitle.trim().isNotEmpty),
        assert(selectionDescription != null && selectionDescription.trim().isNotEmpty),
        _environmentStore = environmentStore ?? EnvironmentStore(store: Store());

  @override
  State<StatefulWidget> createState() {
    return _StateEnvironmentSwitcher();
  }

  static _EnvironmentSwitcher of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_EnvironmentSwitcher>();
  }
}

class _StateEnvironmentSwitcher extends State<EnvironmentSwitcher> {
  Environment currentEnvironment;

  Environment get firstEnvironmentOrDefault {
    if ((widget.environments ?? []).isNotEmpty) {
      return widget.environments[0];
    } else {
      return widget.defaultEnvironment;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.showBanner == false) {
      currentEnvironment = widget.defaultEnvironment;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we don't want to show the banner, we can hide it altogether easily.
    // When this happens, we want to show the default environment no matter the
    // previously saved environment
    // Note: Adding "== false" also acts as a null-check.
    if (widget.showBanner == false) {
      return widget.childBuilder?.call(context);
    }

    if (currentEnvironment == null) {
      // On first run, we need to load the saved environment (if any). If none
      // are saved, use the first in the list. If the list is empty, use the
      // default.
      return FutureBuilder<Environment>(
        future: _getSavedEnvironmentOrDefault(),
        builder: (context, snapshot) {
          currentEnvironment = snapshot.data ?? firstEnvironmentOrDefault;
          return _buildBanner(context, currentEnvironment);
        },
      );
    } else {
      return _buildBanner(context, currentEnvironment);
    }
  }

  Widget _buildBanner(BuildContext context, Environment environment) {
    return _EnvironmentSwitcher(
      currentEnvironment: environment,
      child: _Banner(
        child: Builder(
          builder: (context) => widget.childBuilder?.call(context),
        ),
        onBannerTapped: _onBannerTapped,
      ),
    );
  }

  Future<Environment> _getSavedEnvironmentOrDefault() async {
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
      builder: (_) => SelectEnvironmentSheet(
        environments: widget.environments,
        currentEnvironment: currentEnvironment,
        onNewEnvironmentSelected: _onNewEvironmentTapped,
        title: widget.selectionTitle,
        description: widget.selectionDescription,
      ),
    );
  }

  Future<void> _onNewEvironmentTapped(Environment newEnvironment) async {
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

class _Banner extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext) onBannerTapped;

  const _Banner({
    @required this.child,
    @required this.onBannerTapped,
  })  : assert(child != null),
        assert(onBannerTapped != null);

  @override
  Widget build(BuildContext context) {
    final environment = EnvironmentSwitcher.of(context)?.currentEnvironment;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: (environment == null || !environment.isNameValid)
          ? child
          : Stack(
              children: <Widget>[
                Banner(
                  message: environment.name,
                  location: BannerLocation.topEnd,
                  color: environment.bannerColor,
                  child: child,
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
