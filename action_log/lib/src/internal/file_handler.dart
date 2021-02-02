import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// This class' only purpose is to facilitate testing.
class FileHandler {
  Future<Directory> getCurrentDirectory() {
    return getApplicationDocumentsDirectory();
  }
}
