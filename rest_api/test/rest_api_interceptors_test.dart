import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

import '../lib/rest_api.dart';

const _baseUrl = "www.example.com";
const _endpoint = "/endpoint";
const _interceptEndpoint = "/intercept";
const _fooBody = '{"foo": 0}';
const _barBody = '{"bar": 0}';

const _fooStatusCode = 401;
const _barStatusCode = 200;

void main() {
  Client client;
  RestApi restApi;
  _RedirectInterceptor redirectInterceptor;

  setUp(() {
    client = _MockClient();
    redirectInterceptor = _RedirectInterceptor();

    restApi = RestApi(
      baseUrl: _baseUrl,
      defaultHeaderProviders: [],
      clientOverride: client,
      defaultInterceptors: [redirectInterceptor],
      logger: null,
    );
  });

  test("RestApi interceptors can intercept a response and return a different one", () async {
    when(client.get(_baseUrl + _endpoint, headers: {}))
        .thenAnswer((_) async => Response(_fooBody, _fooStatusCode));
    when(client.get(_baseUrl + _interceptEndpoint, headers: {}))
        .thenAnswer((_) async => Response(_barBody, _barStatusCode));

    final response = await restApi.get(_endpoint);

    expect(response.body.toMap(), equals({"bar": 0}));
  });
}

class _RedirectInterceptor implements RestApiInterceptor {
  @override
  Future<Response> interceptAfterResponse(
      RestApi restApi, Client restClient, Response response) async {
    if (response.statusCode == _fooStatusCode) {
      return restClient.get(_baseUrl + _interceptEndpoint, headers: {});
    }
    return response;
  }
}

class _MockClient extends Mock implements Client {}
