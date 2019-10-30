library rest_api;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:rest_api/rest_api_errors.dart';
import 'package:rest_api/rest_api_logger.dart';
import 'package:rest_api/rest_header_provider.dart';
import 'package:rest_api/rest_response.dart';

import 'json_object.dart';

export 'json_object.dart';

const _timeout = Duration(seconds: 30);

enum RestRequestType { post, get, put, delete }

/// Provides generic POST, GET, PUT, and DELETE Rest requests. The class should
/// be used to facilitate API calls to any server.
class BaseWebApi {
  final String baseUrl;
  final List<BaseHeaderProvider> headerProviders;
  final BaseWebApiLogger logger;
  final Client clientOverride;
  final Duration timeout;

  /// [baseUrl] is the endpoint we're pointing at. It will be prepended to all requests.
  /// [headerProviders] intercept the api calls, and will add any required headers.
  /// [logger] is intercepts requests and logs them (nullable).
  /// [clientOverride] can be used to set a specific client. By default, it'll use a new client for each call.
  /// [timeout] is the duration the call will wait before giving out. Defaults to 30s
  const BaseWebApi({
    @required this.baseUrl,
    @required this.headerProviders,
    this.logger,
    this.clientOverride,
    this.timeout = _timeout,
  }) : assert(baseUrl != null);

  // create a new client, unless an override is provided.
  Client get _client => clientOverride ?? Client();

  /// Sends a request to the server. The request type is set in [requestType],
  /// and the server/API is set in [url]. The output type is optional, but
  /// defaults to the raw response object, which contains status codes.
  Future<RestResponse> request(
    RestRequestType requestType,
    String endpoint, {
    JsonObject jsonBody,
    Map<String, String> queryParameters,
  }) async {
    assert(endpoint != null);
    assert(endpoint != "");

    // Add the query parameters automatically.
    final url = _buildUrl(endpoint, queryParameters);

    // add all the available headers.
    final headers = await createHeaderMap(headerProviders);

    logger?.logRequest(requestType, url, headers: headers, jsonBody: jsonBody);

    // Shouldn't matter if the json parameter is null.
    Response response;
    try {
      switch (requestType) {
        case RestRequestType.post:
          response = await _client
              .post(url, headers: headers, body: jsonBody?.jsonString)
              .timeout(_timeout);
          break;

        case RestRequestType.get:
          response = await _client.get(url, headers: headers).timeout(_timeout);
          break;

        case RestRequestType.put:
          response = await _client
              .put(url, headers: headers, body: jsonBody?.jsonString)
              .timeout(_timeout);
          break;

        case RestRequestType.delete:
          response = await _client.delete(url, headers: headers).timeout(_timeout);
          break;
      }
    } catch (exception, stacktrace) {
      if (exception is SocketException) {
        throw NoConnectionError();
      }

      print("BaseWebApi - Failed to get response. Cause: $exception");
      print("$stacktrace");
      rethrow;
    }

    return _createResponse(response);
  }

  /// Builds a url by concatenating the [baseUrl] and [endpoint] and automatically
  /// makes a query string out of [query]
  String _buildUrl(String endpoint, Map<String, String> query) {
    final fullUrl = baseUrl + endpoint + buildQueryParameters(query);
    return Uri.encodeFull(fullUrl);
  }

  /// Converts a map of {query : parameter} to url encoded query parameters
  /// e.g. "?param1=foo&param2=bar"
  static String buildQueryParameters(Map<String, String> parameters) {
    if (parameters == null || parameters.isEmpty) {
      return "";
    }

    var result = "?";

    parameters.forEach((param, value) {
      if (!result.endsWith("?")) {
        result += "&";
      }
      result += "$param=$value";
    });

    return result;
  }

  RestResponse _createResponse(Response response) {
    if (response == null) {
      throw NoResponseError();
    }

    final body = response.body != null ? JsonObject.fromString(response.body) : null;

    final headers = Set<Header>();
    if (response.headers != null) {
      response.headers.forEach(
        (key, value) => headers.add(Header(name: key, value: value)),
      );
    }

    return RestResponse(
      statusCode: response.statusCode,
      body: body,
      headers: headers,
    );
  }
}
