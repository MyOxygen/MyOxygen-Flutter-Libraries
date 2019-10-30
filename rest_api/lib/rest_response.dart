import 'package:flutter/foundation.dart';
import 'package:rest_api/rest_api.dart';
import 'package:rest_api/rest_header_provider.dart';

class RestResponse {
  final int statusCode;
  final Set<Header> headers;
  final JsonObject body;

  /// A response from a [RestApi] call.
  /// [statusCode] is guarenteed non-null.
  /// [headers] is also non-null but may be empty.
  /// [body] is the JSON body (nullable).
  const RestResponse({
    @required this.statusCode,
    @required this.headers,
    @required this.body,
  })  : assert(statusCode != null),
        assert(headers != null);

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  bool get hasBody => body != null;
}
