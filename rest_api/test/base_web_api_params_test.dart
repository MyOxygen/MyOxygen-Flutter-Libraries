import 'package:flutter_test/flutter_test.dart';
import 'package:rest_api/rest_api.dart';

void main() {
  test("Test empty params returns empty string", () {
    expect(RestApi.buildQueryParameters(null), "");
    expect(RestApi.buildQueryParameters({}), "");
  });

  test("Test builds single param correclty", () {
    expect(RestApi.buildQueryParameters({"foo": "bar"}), "?foo=bar");
  });

  test("Test builds multiple params correctly", () {
    expect(
        RestApi.buildQueryParameters({"param1": "foo", "param2": "bar"}), "?param1=foo&param2=bar");
  });
}
