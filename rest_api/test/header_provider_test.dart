import 'package:flutter_test/flutter_test.dart';
import 'package:rest_api/src/rest_header_provider.dart';

class _TestHeaderProvider extends HeaderProvider {
  final Header header;

  @override
  List<Object> get props => [header];

  _TestHeaderProvider(this.header);

  @override
  Future<Header> getHeader() {
    return Future.value(header);
  }
}

void main() {
  test("createHeaderMap handles nulls", () async {
    final headerA = Header(name: "Name A", value: "Value A");
    final headerB = Header(name: "Name B", value: "Value B");

    final providerA = _TestHeaderProvider(headerA);
    final providerB = _TestHeaderProvider(headerB);
    final providerNull = _TestHeaderProvider(null);

    final map = await createHeaderMap([providerA, providerB, providerNull]);

    expect(map.length, equals(2));
    expect(map["Name A"], equals("Value A"));
    expect(map["Name B"], equals("Value B"));
  });
}
