import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'file_downloader_network_error.dart';
import 'file_system.dart';

export 'file_downloader_network_error.dart';
export 'file_system.dart';

/// only allow 2xx status codes.
const _minSuccessCode = 200;
const _maxSuccessCode = 299;

/// Can be used to download a file from the network.
class FileDownloader {
  final FileSystem fileSystem;
  final Client client;

  /// [fileSystem] allows for mocking of the file system
  /// [client] makes the network calls to download stuff.
  const FileDownloader({
    @required this.fileSystem,
    @required this.client,
  }) : assert(fileSystem != null);

  /// Downloads a file from a url and returns it's file.
  /// If it already exists in the [FileSystem] then it'll just return that.
  /// Beware: This can throw any exceptions that [Client] can throw - as well as
  /// any file-system exceptions.
  Future<File> download({@required Uri url, @required String fileName}) async {
    // if we've already downloaded this - just return it.
    final existingFile = await fileSystem.getExistingFileFor(fileName);
    if (existingFile != null) {
      return existingFile;
    }

    final request = await client.get(url);
    if (request.statusCode < _minSuccessCode || request.statusCode > _maxSuccessCode) {
      throw FileDownloaderNetworkError();
    }

    final bytes = request.bodyBytes;

    final file = await fileSystem.getFile(fileName, create: true);
    return await file.writeAsBytes(bytes);
  }
}
