import 'package:http/http.dart';

import '../rest_api.dart';

abstract class RestApiInterceptor {
  /// Intercept after the [response]. This can return a different response
  /// which will replace the response in the flow. It's asynchronous, allowing you to
  /// call a different endpoint in it's place - however, only if the interceptors are set
  /// to an empty array, to prevent an infinite loop.
  Future<Response> interceptAfterResponse(RestApi restApi, Response response);
}
