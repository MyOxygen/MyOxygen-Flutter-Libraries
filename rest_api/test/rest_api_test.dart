import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:rest_api/rest_api.dart';
import 'package:rest_api/src/rest_api_errors.dart';
import 'package:rest_api/src/rest_header_provider.dart';

const _baseUrl = "https://www.example.com";
const _endpoint = "/test";
const _headerName = "HEADER_NAME";
const _headerValue = "HEADER_VALUE";
const _mockJSON = '{"key": "value"}';

const _keyA = "queryA";
const _valueA = "valueA";
const _keyB = "queryB";
const _valueB = "valueB";

void main() {
  const _fullUrl = "$_baseUrl$_endpoint?$_keyA=$_valueA&$_keyB=$_valueB";

  _MockClient _client;
  RestApi restApi;

  setUp(() {
    _client = _MockClient();

    restApi = RestApi(
      baseUrl: _baseUrl,
      clientOverride: _client,
      logger: null, // no logging in tests.
      defaultHeaderProviders: [
        _MockHeaderProvider(),
      ],
    );
  });

  test("RestApi makes successfull GET call", () async {
    when(_client.get(_fullUrl, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.get(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi handles an unsuccessfull GET call", () async {
    when(_client.get(_fullUrl, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 400));

    final result = await restApi.get(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
    );

    expect(result.statusCode, equals(400));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull POST call", () async {
    when(_client.post(_fullUrl, body: _mockJSON, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.post(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull PUT call", () async {
    when(_client.put(_fullUrl, body: _mockJSON, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.put(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull DELETE call", () async {
    when(_client.delete(_fullUrl, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.delete(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi handles No response", () async {
    when(_client.get(_fullUrl, headers: {_headerName: _headerValue})).thenAnswer((_) async => null);

    try {
      await restApi.get(
        _endpoint,
        queryParameters: {_keyA: _valueA, _keyB: _valueB},
      );
      expect(false, true, reason: "the api call should have failed before it got here.");
    } catch (e) {
      expect(e, isA<NoResponseError>());
    }
  });

  test("RestApi handles SocketException", () async {
    when(_client.get(_fullUrl, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => throw SocketException("No Connection"));

    try {
      await restApi.get(
        _endpoint,
        queryParameters: {_keyA: _valueA, _keyB: _valueB},
      );
      expect(false, true, reason: "the api call should have failed before it got here.");
    } catch (e) {
      expect(e, isA<NoConnectionError>());
    }
  });

  test("RestApi adds override headers", () async {
    // override the provided header with this.
    final overrideHeaderValue = "Override value";

    // a new header added this way.
    final newHeaderName = "A_NEW_HEADER_NAME";
    final newHeaderValue = "A_NEW_HEADER_VALUE";

    // header providers for this one call.
    final overrideHeaderProviders = [
      _MockHeaderProvider(name: _headerName, value: overrideHeaderValue),
      _MockHeaderProvider(name: newHeaderName, value: newHeaderValue),
    ];

    final expectedHeaders = {
      _headerName: overrideHeaderValue,
      newHeaderName: newHeaderValue,
    };

    when(_client.get(_fullUrl, headers: expectedHeaders))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.get(
      _endpoint,
      queryParameters: {_keyA: _valueA, _keyB: _valueB},
      jsonBody: JsonObject.fromString(_mockJSON),
      headers: overrideHeaderProviders,
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });
}

class _MockClient extends Mock implements Client {}

/// Provides consistent headers that can be tested.
class _MockHeaderProvider extends HeaderProvider {
  final String name;
  final String value;

  const _MockHeaderProvider({
    this.name = _headerName,
    this.value = _headerValue,
  });

  @override
  Future<Header> getHeader() async => Header(name: name, value: value);
}
