import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// A wrapper around the file system. This is so it can be mocked.
class FileSystem {
  const FileSystem();

  /// Gets an existing fie for a [fileName].
  /// WARNING: May return null
  Future<File> getExistingFileFor(String fileName) async {
    final file = await getFile(fileName);
    if (file == null) {
      return null;
    }

    final exists = await file.exists();
    if (!exists) {
      return null;
    }

    final length = await file.length();
    return (length == 0) ? null : file;
  }

  /// Gets a file for a given name.
  /// [create] will create the file if it doesn't exist.
  Future<File> getFile(String fileName, {bool create = false}) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    final file = File(path);

    // Ensure it's created if that's required.
    if (create) {
      final bool exists = await file.exists();
      if (!exists) {
        return await file.create();
      }
    }

    return file;
  }

  /// Delete a file with the given [fileName]
  Future deleteFile(String fileName) async {
    final file = await getFile(fileName, create: false);
    final doesExist = await file.exists();
    if (doesExist) {
      await file.delete();
    }
  }

  /// Get all of the files within the documents directory
  Future<List<File>> getAllFiles() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return documentsDirectory.listSync().whereType<File>().toList();
  }
}
