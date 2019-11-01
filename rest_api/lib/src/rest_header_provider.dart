import 'package:meta/meta.dart';

/// Provides a headers for a request. To be used with dynamic data that may
/// change throughout the app's lifecycle. One example is the authentication
/// token: a [List<Header>] will retain the data staticly, whereas a
/// [List<HeaderProvider>] allows developers to implement fetching the data from
/// a local storage provider (or elsewhere).
abstract class HeaderProvider {
  const HeaderProvider();

  /// Return a future containting the [Header] that you want to add to the call.
  /// can return null from that future to add no header.
  Future<Header> getHeader();
}

/// Just a wrapper object containing our header.
class Header {
  final String name;
  final String value;

  Header({
    @required this.name,
    @required this.value,
  })  : assert(name != null),
        assert(value != null);

  @override
  String toString() {
    return "$name : $value";
  }

  bool operator ==(o) => o is Header && o.name == this.name && o.value == this.value;

  int get hashCode {
    int hash = 17; // prime number
    hash = 31 * hash + name.hashCode;
    hash = 31 * hash + value.hashCode;
    return hash;
  }
}

/// Convert a list of header providers into a map where each key corresponds to a header [name],
/// and each value corresponds to a header [value].
Future<Map<String, String>> createHeaderMap(List<HeaderProvider> headerProviders) async {
  final headers = Map<String, String>();

  for (HeaderProvider headerProvider in headerProviders) {
    final header = await headerProvider.getHeader();
    if (header != null) {
      headers[header.name] = header.value;
    }
  }

  return headers;
}
