import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../rest_api.dart';

class RestApiLogger {
  final bool runInRelease;

  bool get _isLogging => this.runInRelease || kDebugMode;

  /// Log the networking stuff. Keeps the logging code out of the
  /// main networking code.
  const RestApiLogger({
    this.runInRelease = false,
  }) : assert(runInRelease != null);

  void logRequest(
    RestRequestType requestType,
    String url, {
    JsonObject jsonBody,
    Map<String, String> headers,
  }) {
    if (!_isLogging) {
      return;
    }

    _log("---> ${_requestTypeName(requestType)} ${url ?? "NULL"}");
    if (headers != null) {
      headers.forEach((k, v) => _log("---> $k : $v"));
    }

    if (jsonBody != null) {
      final String jsonString = jsonBody.jsonString;
      _log("---> Body: $jsonString");
    }
  }

  void logException(dynamic exception) {
    if (!_isLogging) {
      return;
    }

    _log("<--- EXCEPTION");
    if (exception != null) {
      _log("<--- ${exception.toString()}");
    }
  }

  void logResponse(Response response) {
    if (!_isLogging) {
      return;
    }

    if (response == null) {
      _log("<--- Null response");
      return;
    }

    _log("<--- ${response.statusCode} ${response.request.url}");
    if (response.headers != null) {
      response.headers.forEach((k, v) => _log("<--- $k : $v"));
    }
    if (response.body != null) {
      _log("<--- Body: ${response.body}");
    }
  }

  void _log(String text) {
    Fimber.i(text ?? "");
  }

  // Just for pretty printing.
  String _requestTypeName(RestRequestType type) {
    switch (type) {
      case RestRequestType.post:
        return "POST";
      case RestRequestType.put:
        return "PUT";
      case RestRequestType.delete:
        return "DELETE";
      case RestRequestType.get:
        return "GET";
    }
    return "NULL TYPE";
  }
}
