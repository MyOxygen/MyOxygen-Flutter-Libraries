library store;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  /// A key-value store that uses SharedPreferences on Android
  /// and UserDefaults on iOS.
  /// This is a wrapper around SharedPreferences library because it's hard to mock.
  const Store();

  /// Gets an instance of the [SharedPreferences] library.
  /// uses [_preferencesBuilder] if supplied.
  Future<SharedPreferences> _getSharedPrefrences() => SharedPreferences.getInstance();

  /// Clear the shared preferences.
  Future<void> clear() {
    return _getSharedPrefrences().then((preferences) => preferences.clear());
  }

  /*
   * Getters and setters 
   */

  /// Get a value from the store with the key [key].
  /// May return null if nothing is set with that key.
  Future<bool> getBool(String key) {
    assert(key != null);
    return _getSharedPrefrences().then((preferences) => preferences.getBool(key));
  }

  /// Set [value] in the store with [key].
  /// [value] can be null to clear the store for that value.
  /// Returns the value that was set.
  Future<bool> setBool(bool value, {@required String key}) async {
    assert(key != null);

    final preferences = await _getSharedPrefrences();
    final result = await preferences.setBool(key, value);
    assert(result, "Unable to save to shared preferences");

    return value;
  }

  /// Get a value from the store with the key [key].
  /// May return null if nothing is set with that key.
  Future<int> getInt(String key) {
    assert(key != null);
    return _getSharedPrefrences().then((preferences) => preferences.getInt(key));
  }

  /// Set [value] in the store with [key].
  /// [value] can be null to clear the store for that value.
  /// Returns the value that was set.
  Future<int> setInt(int value, {@required String key}) async {
    assert(key != null);

    final preferences = await _getSharedPrefrences();
    final result = await preferences.setInt(key, value);
    assert(result, "Unable to save to shared preferences");

    return value;
  }

  /// Get a value from the store with the key [key].
  /// May return null if nothing is set with that key.
  Future<double> getDouble(String key) {
    assert(key != null);
    return _getSharedPrefrences().then((preferences) => preferences.getDouble(key));
  }

  /// Set [value] in the store with [key].
  /// [value] can be null to clear the store for that value.
  /// Returns the value that was set.
  Future<double> setDouble(double value, {@required String key}) async {
    assert(key != null);

    final preferences = await _getSharedPrefrences();
    final result = await preferences.setDouble(key, value);
    assert(result, "Unable to save to shared preferences");

    return value;
  }

  /// Get a value from the store with the key [key].
  /// May return null if nothing is set with that key.
  Future<String> getString(String key) {
    assert(key != null);
    return _getSharedPrefrences().then((preferences) => preferences.getString(key));
  }

  /// Set [value] in the store with [key].
  /// [value] can be null to clear the store for that value.
  /// Returns the value that was set.
  Future<String> setString(String value, {@required String key}) async {
    assert(key != null);

    final preferences = await _getSharedPrefrences();
    final result = await preferences.setString(key, value);
    assert(result, "Unable to save to shared preferences");

    return value;
  }
}