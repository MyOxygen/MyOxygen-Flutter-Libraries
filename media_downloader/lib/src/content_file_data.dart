import 'package:flutter/foundation.dart';

/// Modeling Data used by [BaseFileLoader] to manage the file access
/// and caching.
class ContentFileData {
  final String fileName;
  final String dataUrl;

  /// [fileName] should be unique for each piece of content,
  /// otherwise it'll overwrite other content.
  /// [dataUrl] is where the data to go in the file is actually located.
  ContentFileData({
    @required this.fileName,
    @required this.dataUrl,
  });
}
