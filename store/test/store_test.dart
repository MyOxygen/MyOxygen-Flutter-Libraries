import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

const _boolKey = "BOOL_KEY";
const _boolValue = true;

const _stringKey = "STRING_KEY";
const _stringValue = "TEST";

const _intKey = "INT_KEY";
const _intValue = 100;

const _doubleKey = "DOUBLE_KEY";
const _doubleValue = 3.14;

void main() {
  Store store;
  _TestSharedPreferences _testSharedPreferences;

  setUp(() {
    _testSharedPreferences = _TestSharedPreferences();

    // inject a mock version of the library.
    store = Store(
      () async => _testSharedPreferences,
    );
  });

  test("[Store] store booleans", () async {
    when(_testSharedPreferences.setBool(_boolKey, _boolValue)).thenAnswer((_) async => true);
    when(_testSharedPreferences.getBool(_boolKey)).thenAnswer((_) => _boolValue);

    await store.setBool(true, key: _boolKey);
    final result = await store.getBool(_boolKey);

    expect(result, equals(_boolValue));

    verify(_testSharedPreferences.setBool(_boolKey, true));
    verify(_testSharedPreferences.getBool(_boolKey));
  });

  test("[Store] store strings", () async {
    when(_testSharedPreferences.setString(_stringKey, _stringValue)).thenAnswer((_) async => true);
    when(_testSharedPreferences.getString(_stringKey)).thenAnswer((_) => _stringValue);

    await store.setString(_stringValue, key: _stringKey);
    final result = await store.getString(_stringKey);

    expect(result, equals(_stringValue));

    verify(_testSharedPreferences.setString(_stringKey, _stringValue));
    verify(_testSharedPreferences.getString(_stringKey));
  });

  test("[Store] store ints", () async {
    when(_testSharedPreferences.setInt(_intKey, _intValue)).thenAnswer((_) async => true);
    when(_testSharedPreferences.getInt(_intKey)).thenAnswer((_) => _intValue);

    await store.setInt(_intValue, key: _intKey);
    final result = await store.getInt(_intKey);

    expect(result, equals(_intValue));

    verify(_testSharedPreferences.setInt(_intKey, _intValue));
    verify(_testSharedPreferences.getInt(_intKey));
  });

  test("[Store] store doubles", () async {
    when(_testSharedPreferences.setDouble(_doubleKey, _doubleValue)).thenAnswer((_) async => true);
    when(_testSharedPreferences.getDouble(_doubleKey)).thenAnswer((_) => _doubleValue);

    await store.setDouble(_doubleValue, key: _doubleKey);
    final result = await store.getDouble(_doubleKey);

    expect(result, equals(_doubleValue));

    verify(_testSharedPreferences.setDouble(_doubleKey, _doubleValue));
    verify(_testSharedPreferences.getDouble(_doubleKey));
  });
}

class _TestSharedPreferences extends Mock implements SharedPreferences {}
