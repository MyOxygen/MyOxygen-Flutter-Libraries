import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'environment.dart';
import 'environment_bloc.dart';
import 'environment_bloc_state.dart';
import 'environment_store.dart';
import 'select_environment_sheet.dart';

export 'environment.dart';

class EnvironmentSwitcher extends StatefulWidget {
  final Widget child;
  final List<Environment> environments;

  /// A banner that visually shows the user what [Environment]
  /// is currently set to.
  /// This is useful because it's possible to be on one Flavour
  /// in the native code, and another in the Flutter code.
  const EnvironmentSwitcher({
    @required this.child,
    @required this.environments,
  })  : assert(child != null),
        assert(environments != null && environments.length != 0);

  @override
  State<StatefulWidget> createState() {
    return _StateEnvironmentSwitcher(environments);
  }
}

class _StateEnvironmentSwitcher extends State<EnvironmentSwitcher> {
  final EnvironmentBloc bloc;

  _StateEnvironmentSwitcher(List<Environment> environments)
      : bloc = EnvironmentBloc(
          environments: environments,
          environmentStore: EnvironmentStore(store: Store()),
        );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocBuilder<EnvironmentBloc, EnvironmentBlocState>(
        builder: (context, state) {
          if (state.environment == null || state.bannerText == null || state.bannerText == "") {
            return widget.child;
          }

          return Stack(
            children: <Widget>[
              Banner(
                message: state.bannerText,
                location: BannerLocation.topEnd,
                color: state.bannerColor,
                child: widget.child,
              ),
              _BannerHitBox(onTap: _onBannerTapped),
            ],
          );
        },
      ),
    );
  }

  void _onBannerTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SelectEnvironmentSheet(environments: widget.environments),
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
