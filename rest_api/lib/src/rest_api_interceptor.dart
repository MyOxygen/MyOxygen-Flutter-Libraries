import 'package:http/http.dart';
import 'package:rest_api/rest_api.dart';

abstract class RestApiInterceptor {
  /// intercept the response and return a new one.
  /// It's a future, so a new response can be made as well.
  Future<Response> interceptResponse(Response response, RestApi restApi);
}
