import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'json_object.dart';
import 'rest_api_errors.dart';
import 'rest_api_logger.dart';
import 'rest_header_provider.dart';
import 'rest_response.dart';

export 'package:http/src/client.dart';

export 'json_object.dart';
export 'rest_api_errors.dart';
export 'rest_header_provider.dart';
export 'rest_response.dart';

const _defaultTimeout = Duration(seconds: 30);

enum RestRequestType { post, get, put, delete }

/// Provides generic POST, GET, PUT, and DELETE Rest requests. The class should
/// be used to facilitate API calls to any server.
class RestApi {
  final RestApiLogger? logger;
  final String baseUrl;
  final List<HeaderProvider> defaultHeaderProviders;
  final Client? clientOverride;
  final Duration timeout;

  /// [baseUrl] is the endpoint we're pointing at. It will be prepended to all requests.
  /// [defaultHeaderProviders] intercept the api calls, and will add any required headers.
  /// To add headers to indivudal calls use the [header] property on that that.
  /// [logger] is intercepts requests and logs them (nullable).
  /// [clientOverride] can be used to set a specific client. By default, it'll use a new client for each call.
  /// [timeout] is the duration the call will wait before giving out. Defaults to 30s
  const RestApi({
    required this.baseUrl,
    this.defaultHeaderProviders = const [],
    this.logger = const RestApiLogger(),
    this.clientOverride,
    this.timeout = _defaultTimeout,
  });
  // create a new client, unless an override is provided.
  Client get _client => clientOverride ?? Client();

  /// Make a network call of type GET at the given [baseUrl] and [endpoint]
  /// after appending the [queryParameters] (nullable).
  /// headers are added through the [defaultHeaderProviders]
  /// [jsonBody] is nullable
  /// [headers] will be added in addition to the [defaultHeaders]
  Future<RestResponse> get(
    String endpoint, {
    JsonObject? jsonBody,
    Map<String, String>? queryParameters,
    List<HeaderProvider> headers = const [],
  }) {
    return _makeRequest(
      RestRequestType.get,
      endpoint,
      jsonBody: jsonBody,
      queryParameters: queryParameters,
      headerProviders: headers,
    );
  }

  /// Make a network call of type POST at the given [baseUrl] and [endpoint]
  /// after appending the [queryParameters] (nullable).
  /// headers are added through the [defaultHeaderProviders]
  /// [jsonBody] is nullable
  /// [headers] will be added in addition to the [defaultHeaders]
  Future<RestResponse> post(
    String endpoint, {
    required JsonObject jsonBody,
    Map<String, String>? queryParameters,
    List<HeaderProvider> headers = const [],
  }) {
    return _makeRequest(
      RestRequestType.post,
      endpoint,
      jsonBody: jsonBody,
      queryParameters: queryParameters,
      headerProviders: headers,
    );
  }

  /// Make a network call of type DELETE at the given [baseUrl] and [endpoint]
  /// after appending the [queryParameters] (nullable).
  /// headers are added through the [defaultHeaderProviders]
  /// [jsonBody] is nullable
  /// [headers] will be added in addition to the [defaultHeaders]
  Future<RestResponse> delete(
    String endpoint, {
    JsonObject? jsonBody,
    Map<String, String>? queryParameters,
    List<HeaderProvider> headers = const [],
  }) {
    return _makeRequest(
      RestRequestType.delete,
      endpoint,
      jsonBody: jsonBody,
      queryParameters: queryParameters,
      headerProviders: headers,
    );
  }

  /// Make a network call of type PUT at the given [baseUrl] and [endpoint]
  /// after appending the [queryParameters] (nullable).
  /// headers are added through the [defaultHeaderProviders]
  /// [jsonBody] is nullable
  /// [headers] will be added in addition to the [defaultHeaders]
  Future<RestResponse> put(
    String endpoint, {
    JsonObject? jsonBody,
    Map<String, String>? queryParameters,
    List<HeaderProvider> headers = const [],
  }) {
    return _makeRequest(
      RestRequestType.put,
      endpoint,
      jsonBody: jsonBody,
      queryParameters: queryParameters,
      headerProviders: headers,
    );
  }

  /// Makes a network call based on [requestType]
  Future<RestResponse> _makeRequest(
    RestRequestType requestType,
    String endpoint, {
    JsonObject? jsonBody,
    Map<String, String>? queryParameters,
    List<HeaderProvider>? headerProviders,
  }) async {
    assert(endpoint != "");

    // Add the query parameters automatically.
    final url = _buildUrl(endpoint, queryParameters);

    // add the defaultHeaderProviders first, then add the extra ones so that
    // they can override on a call by call basis.
    final combinedHeaders = List<HeaderProvider>.from(defaultHeaderProviders);
    if (headerProviders != null && headerProviders.isNotEmpty) {
      combinedHeaders.addAll(headerProviders);
    }

    final headers = await createHeaderMap(combinedHeaders);

    logger?.logRequest(requestType, url, headers: headers, jsonBody: jsonBody);

    // Shouldn't matter if the json parameter is null.
    Response? response;
    try {
      switch (requestType) {
        case RestRequestType.post:
          response = await _client
              .post(url, headers: headers, body: jsonBody?.jsonString)
              .timeout(this.timeout);
          break;

        case RestRequestType.get:
          response = await _client.get(url, headers: headers).timeout(this.timeout);
          break;

        case RestRequestType.put:
          response = await _client
              .put(url, headers: headers, body: jsonBody?.jsonString)
              .timeout(this.timeout);
          break;

        case RestRequestType.delete:
          response = await _client.delete(url, headers: headers).timeout(this.timeout);
          break;
      }
    } on SocketException {
      logger?.logException(NoConnectionError());
      throw NoConnectionError();
    }

    logger?.logResponse(response);

    return _createRestResponse(response);
  }

  /// Builds a url by concatenating the [baseUrl] and [endpoint] and automatically
  /// makes a query string out of [query]
  Uri _buildUrl(String endpoint, Map<String, String>? query) {
    final fullUrl = baseUrl + endpoint + buildQueryParameters(query);
    final encoded = Uri.encodeFull(fullUrl);
    return Uri.parse(encoded);
  }

  /// Converts a map of {query : parameter} to url encoded query parameters
  /// e.g. "?param1=foo&param2=bar"
  static String buildQueryParameters(Map<String, String>? parameters) {
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

  /// Create a [RestResponse] object from the raw [Response] object
  RestResponse _createRestResponse(Response? response) {
    if (response == null) {
      logger?.logException(NoResponseError());
      throw NoResponseError();
    }

    JsonObject responseBody;

    try {
      responseBody = JsonObject.fromString(response.body);
    } on RestApiError catch (e) {
      logger?.logException(e);
      rethrow;
    }

    final headers = Set<Header>();
    if (response.headers != null) {
      response.headers.forEach(
        (key, value) => headers.add(Header(name: key, value: value)),
      );
    }

    final restResponse = RestResponse(
      statusCode: response.statusCode,
      body: responseBody,
      headers: headers,
    );

    /// call the subclass listener
    onResponse(restResponse);

    return restResponse;
  }

  /// A listener that a subclass can use to intercept responses.
  /// [response] is always non-null.
  void onResponse(RestResponse response) {}

  // subclasses can handle the thrown errors differently.
  // the default is just to throw it.
  // void handleError(RestApiError error) {
  //   logger?.logException(error);
  //   throw error;
  // }
}
