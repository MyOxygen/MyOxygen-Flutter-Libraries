import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'environment.dart';

export 'package:store/store.dart';
export 'environment.dart';

class EnvironmentStore {
  static const _environmentKey = "ENVIRONMENT_KEY";

  final Store store;

  const EnvironmentStore({
    @required this.store,
  }) : assert(store != null);

  Future<String> getSavedEnvironment() async {
    final environmentName = await store.getString(_environmentKey);
    return environmentName;
  }

  Future<void> saveEnvironment(Environment environment) async {
    if (environment == null) {
      await store.setString(null, key: _environmentKey);
    } else {
      await store.setString(environment.name, key: _environmentKey);
    }
  }
}
