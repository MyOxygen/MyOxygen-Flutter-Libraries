import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:rest_api/rest_api.dart';
import 'package:rest_api/rest_header_provider.dart';

const _baseUrl = "https://www.example.com";
const _headerName = "HEADER_NAME";
const _headerValue = "HEADER_VALUE";
const _mockJSON = '{"key": "value"}';

void main() {
  _MockClient _client;
  RestApi restApi;

  setUp(() {
    _client = _MockClient();

    restApi = RestApi(
      baseUrl: _baseUrl,
      clientOverride: _client,
      headerProviders: [
        _MockHeaderProvider(),
      ],
    );
  });

  test("RestApi makes successfull GET call", () async {
    when(_client.get("$_baseUrl/test", headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.get("/test");

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull POST call", () async {
    when(_client.post("$_baseUrl/test", body: _mockJSON, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.post(
      "/test",
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull PUT call", () async {
    when(_client.put("$_baseUrl/test", body: _mockJSON, headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.put(
      "/test",
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });

  test("RestApi makes successfull DELETE call", () async {
    when(_client.delete("$_baseUrl/test", headers: {_headerName: _headerValue}))
        .thenAnswer((_) async => Response(_mockJSON, 200));

    final result = await restApi.delete(
      "/test",
      jsonBody: JsonObject.fromString(_mockJSON),
    );

    expect(result.statusCode, equals(200));
    expect(result.body.toMap()["key"], equals("value"));
  });
}

class _MockClient extends Mock implements Client {}

/// Provides consistent headers that can be tested.
class _MockHeaderProvider extends HeaderProvider {
  @override
  Future<Header> getHeader() async => Header(name: _headerName, value: _headerValue);
}
