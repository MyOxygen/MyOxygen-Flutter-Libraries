import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_downloader/media_downloader.dart';

import 'package:mockito/mockito.dart';

const _fileName = "file-loader-123";
const _diskId = 222;
final _url = Uri.http("i.imgur.com", "7SByB.jpg");

void main() {
  _TestFileSystem fileSystem;
  _TestFileDownloader fileDownloader;
  _FileLoader fileLoader;

  setUp(() {
    fileSystem = _TestFileSystem();
    fileDownloader = _TestFileDownloader(fileSystem);
    fileLoader = _FileLoader(fileDownloader: fileDownloader);
  });

  test("FileLoader returns system file when present", () async {
    when(fileSystem.getExistingFileFor(_fileName))
        .thenAnswer((_) async => _TestFile(_diskId, _url));

    final loaderResult = await fileLoader.getFile(_TestFile(123, _url));
    expect(loaderResult.isPresent, true);

    final file = loaderResult.value as _TestFile;
    expect(file.id, equals(_diskId));
  });

  test("FileLoader returns empty optional when file not preent", () async {
    when(fileSystem.getExistingFileFor(_fileName)).thenAnswer((_) async => null);

    final loaderResult = await fileLoader.getFile(_TestFile(123, _url));
    expect(loaderResult.isPresent, false);
  });
}

class _TestFileDownloader extends Mock implements FileDownloader {
  final FileSystem fileSystem;

  _TestFileDownloader(this.fileSystem);
}

class _TestFileSystem extends Mock implements FileSystem {}

class _TestFile extends Mock implements File {
  final int id;
  final Uri url;

  _TestFile(this.id, this.url);
}

class _FileLoader extends BaseFileLoader<_TestFile> {
  /// Want this to be sufficiently unique.
  static const _fileNamePrefix = "file-loader";

  _FileLoader({
    @required FileDownloader fileDownloader,
  }) : super(fileDownloader);

  @override
  ContentFileData dataForContent(_TestFile file) =>
      ContentFileData(fileName: _makeFileName(file), dataUrl: file.url);

  String _makeFileName(_TestFile file) {
    return "$_fileNamePrefix-${file.id}";
  }

  Future deleteAllFiles() {
    return deleteWhere((fileName) => fileName.startsWith(_fileNamePrefix));
  }
}
