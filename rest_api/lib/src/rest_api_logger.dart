import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../rest_api.dart';

class RestApiLogger {
  /// Log the networking stuff. Keeps the logging code out of the
  /// main networking code.
  const RestApiLogger();

  void logRequest(
    RestRequestType requestType,
    String url, {
    JsonObject jsonBody,
    Map<String, String> headers,
  }) {
    // Do it in an assert so it only runs in debug mode,
    assert(() {
      _logRequest(requestType, url, jsonBody: jsonBody, headers: headers);
      return true;
    }());
  }

  void logException(dynamic exception) {
    // do it in an assert so it only runs in debug mode,
    assert(() {
      _logException(exception);
      return true;
    }());
  }

  void logResponse(Response response) {
    // do it in an assert so it only runs in debug mode,
    assert(() {
      _logResponse(response);
      return true;
    }());
  }

  /// Prints a request.
  void _logRequest(
    RestRequestType requestType,
    String url, {
    JsonObject jsonBody,
    Map<String, String> headers,
  }) {
    debugPrint("---> ${_requestTypeName(requestType)} ${url ?? "NULL"}");
    if (headers != null) {
      headers.forEach((k, v) => debugPrint("---> $k : $v"));
    }
    if (jsonBody != null) {
      final String jsonString = jsonBody.jsonString;
      debugPrint("---> Body: $jsonString");
    }
  }

  /// Prints an Exception.
  void _logException(dynamic exception) {
    debugPrint("<--- EXCEPTION");
    if (exception != null) {
      debugPrint("<--- ${exception.toString()}");
    }
  }

  /// Prints a response.
  void _logResponse(Response response) {
    if (response == null) {
      debugPrint("<--- Null response");
      return;
    }

    debugPrint("<--- ${response.statusCode} ${response.request?.url}");
    if (response.headers != null) {
      response.headers.forEach((k, v) => debugPrint("<--- $k : $v"));
    }
    if (response.body != null) {
      debugPrint("<--- Body: ${response.body}");
    }
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
