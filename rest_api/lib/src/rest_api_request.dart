import 'package:flutter/foundation.dart';

import '../rest_api.dart';

class RestApiRequest {
  final RestRequestType requestType;
  final String endpoint;
  final JsonObject jsonBody;
  final Map<String, String> queryParameters;
  final List<HeaderProvider> headerProviders;
  final List<RestApiInterceptor> interceptors;

  const RestApiRequest({
    @required this.requestType,
    @required this.endpoint,
    this.jsonBody,
    this.queryParameters,
    this.headerProviders,
    this.interceptors,
  })  : assert(requestType != null),
        assert(endpoint != null);
}
