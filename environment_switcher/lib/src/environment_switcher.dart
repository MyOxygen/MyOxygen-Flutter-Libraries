import 'package:flutter/material.dart';

import 'environment.dart';
import 'environment_store.dart';
import 'select_environment_sheet.dart';

export 'environment.dart';
export 'environment_store.dart';

class EnvironmentSwitcher extends StatefulWidget {
  final Widget Function(Environment) builder;
  final List<Environment> environments;
  final EnvironmentStore environmentStore;
  final bool showBanner;

  /// A banner that visually shows the user what [Environment]
  /// is currently set to.
  /// This is useful because it's possible to be on one Flavour
  /// in the native code, and another in the Flutter code.
  const EnvironmentSwitcher({
    @required this.builder,
    @required this.environments,
    this.environmentStore, // mainly required for testing
    this.showBanner = true,
  })  : assert(builder != null),
        assert(environments != null && environments.length != 0),
        assert(showBanner != null);

  @override
  State<StatefulWidget> createState() {
    return _StateEnvironmentSwitcher(environments, environmentStore);
  }
}

class _StateEnvironmentSwitcher extends State<EnvironmentSwitcher> {
  final List<Environment> environments;
  final EnvironmentStore environmentStore;

  Environment currentEnvironment;

  Environment get firstEnvironmentOrDefault {
    if ((environments ?? []).isNotEmpty) {
      return environments[0];
    } else {
      return null;
    }
  }

  _StateEnvironmentSwitcher(this.environments, EnvironmentStore store)
      : environmentStore = store ?? EnvironmentStore(store: Store());

  @override
  Widget build(BuildContext context) {
    // If we don't want to show the banner, we can hide it altogether easily.
    // This also acts as a null-check.
    if (widget.showBanner == false) {
      return const SizedBox();
    }

    if (currentEnvironment == null) {
      return FutureBuilder<Environment>(
        future: _getSavedEnvironmentOrDefault(),
        builder: (context, snapshot) {
          currentEnvironment = snapshot.data ?? firstEnvironmentOrDefault;
          return _Banner(
            environment: currentEnvironment,
            child: widget.builder?.call(currentEnvironment),
            onBannerTapped: _onBannerTapped,
          );
        },
      );
    } else {
      return _Banner(
        environment: currentEnvironment,
        child: widget.builder?.call(currentEnvironment),
        onBannerTapped: _onBannerTapped,
      );
    }
  }

  Future<Environment> _getSavedEnvironmentOrDefault() async {
    try {
      final savedEnvironmentName = await environmentStore.getSavedEnvironment();
      if (savedEnvironmentName == null) {
        throw "No environment saved";
      }
      final environment =
          environments.firstWhere((env) => env.name == savedEnvironmentName, orElse: () => null);
      if (environment == null) {
        throw "Environment not found in list";
      }
      return environment;
    } catch (e) {
      print(e.toString());
    }

    return firstEnvironmentOrDefault;
  }

  void _onBannerTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SelectEnvironmentSheet(
        environments: widget.environments,
        currentEnvironment: currentEnvironment,
        onNewEnvironmentSelected: _onNewEvironmentTapped,
      ),
    );
  }

  Future<void> _onNewEvironmentTapped(Environment newEnvironment) async {
    try {
      await environmentStore.saveEnvironment(newEnvironment);
      setState(() {
        currentEnvironment = newEnvironment;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class _Banner extends StatelessWidget {
  final Environment environment;
  final Widget child;
  final void Function(BuildContext) onBannerTapped;

  const _Banner({
    @required this.environment,
    @required this.child,
    @required this.onBannerTapped,
  })  : assert(environment != null),
        assert(child != null),
        assert(onBannerTapped != null);

  @override
  Widget build(BuildContext context) {
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
