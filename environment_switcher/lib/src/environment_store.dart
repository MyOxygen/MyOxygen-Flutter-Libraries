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
    return await store.getString(_environmentKey);
  }

  Future<void> saveEnvironment(Environment environment) async {
    await store.setString(environment?.name, key: _environmentKey);
  }
}
