import 'dart:io';

import 'package:optional/optional.dart';
import 'package:path/path.dart';

import 'content_file_data.dart';
import 'file_downloader.dart';
import 'file_system.dart';

export 'content_file_data.dart';
export 'file_downloader.dart';
export 'file_system.dart';
export 'package:optional/optional.dart';

/// Handles downloading data from [T] so that it's available offline.
/// Should be subclassed to provide more specific functionality, and
/// define [T]
abstract class BaseFileLoader<T> {
  final FileDownloader fileDownloader;

  /// [fileDownloader] is used to load the files from the disk/network.
  /// [localCache] keeps a copy in memory so that it doesn't have to hit the disk all the time.
  const BaseFileLoader(this.fileDownloader) : assert(fileDownloader != null);

  /// Quick access.
  FileSystem get _fileSystem => fileDownloader.fileSystem;

  /// This should be construced via the subclass.
  /// It defines the filename, and the id for the cache, for a given instance of [T]
  ContentFileData dataForContent(T content);

  /// Gets the existing file for [image].
  /// The optional will be empty if it doesn't exist.
  Future<Optional<File>> getFile(T content) {
    final data = dataForContent(content);

    return _fileSystem.getExistingFileFor(data.fileName).then((file) => Optional.ofNullable(file));
  }

  /// Downloads an image to the file system.
  Future<File> download(T content) {
    final data = dataForContent(content);
    return fileDownloader.download(url: data.dataUrl, fileName: data.fileName);
  }

  /// Deletes a cached image.
  Future delete(T content) {
    final data = dataForContent(content);
    return _fileSystem.deleteFile(data.fileName);
  }

  /// Delete all of the files that fulfil the test.
  /// i.e. For every file in the directory, if test returns
  /// true, delete it.
  Future deleteWhere(bool test(String fileName)) async {
    final allFileNames = await _fileSystem.getAllFiles().then(_mapToFileNames);
    final filesToDelete = allFileNames.where(test);

    await Future.forEach(filesToDelete, (fileName) async {
      await _fileSystem.deleteFile(fileName);
    });
  }

  /// Converts a list of files to a list of file names.
  Iterable<String> _mapToFileNames(Iterable<File> files) {
    return files.map(_getFileName);
  }

  /// Gets the file name of a file. Just the actual file name, ignores any directory data.
  String _getFileName(File file) {
    final path = file.path;
    return basename(path);
  }

  /// When saving the file, use the file extension from the url.
  /// May return null as the url may not contain a file extension.
  String getFileExtension(String dataUrl) {
    // Get the last part, and see if it ends in ".XXX"
    final lastPathParam = dataUrl.split("/").last;
    return lastPathParam.contains(".") ? lastPathParam.split(".").last : null;
  }
}
