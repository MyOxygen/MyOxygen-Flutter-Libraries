import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'rest_api_errors.dart';

export 'rest_api_errors.dart';

/// A wrapper around a json string to handle parsing.
/// It throws a nice error if you give it any invalid json.
class JsonObject {
  static const Converter<List<int>, String> _decoder = Utf8Decoder();

  /// All types are stored as a string, and then converted back to another
  /// format when required.
  final String jsonString;

  JsonObject._(this.jsonString) : assert(jsonString != null) {
    // If this gets constructed with an invalid json, throw an exception sooner
    // rather than later.
    if (!_validateJson()) {
      throw InvalidJsonError();
    }
  }

  // Factory constructors.

  factory JsonObject.fromMap(Map<String, dynamic> map) => JsonObject._(jsonEncode(map));

  factory JsonObject.fromList(List<dynamic> list) => JsonObject._(jsonEncode(list));

  factory JsonObject.fromResponse(Response response) {
    final jsonString = _decoder.convert(response.bodyBytes);
    return JsonObject._(jsonString);
  }

  factory JsonObject.fromString(String string) => JsonObject._(string);

  // Converting back to more useful formats.

  List<T> toList<T>({@required T Function(Map<String, dynamic>) converter}) {
    final decodedJson = jsonDecode(jsonString) as List<dynamic>;
    assert(converter != null);
    return decodedJson.cast<Map<String, dynamic>>().map(converter).toList();
  }

  Map<String, dynamic> toMap() => jsonDecode(jsonString) as Map<String, dynamic>;

  @override
  String toString() => jsonString;

  /// Check our [jsonString] is valid.
  bool _validateJson() {
    try {
      dynamic decoded = jsonString;
      if (jsonString != null && jsonString.isNotEmpty) {
        // jsonDecode requires the input string to be non-null at a minimum,
        // otherwise a NoSuchMethodError (aka a null exception) occurs. Empty
        // strings, whilst valid will throw a FormatException.
        decoded = jsonDecode(jsonString);
      }
      return decoded != null;
    } on FormatException catch (_) {
      return false;
    }
  }
}
