import 'dart:io';

import 'package:action_log/src/action_log_helper.dart';
import 'package:action_log/src/internal/file_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'action_log_helper_test.mocks.dart';

const dynamicDirectoryPath = "./test/resources/";
const existingLogEntry = "This is a test log.";

@GenerateMocks([FileHandler])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FileHandler fileHandler;

  setUpAll(() {
    fileHandler = MockFileHandler();
    when(fileHandler.getCurrentDirectory())
        .thenAnswer((_) async => Directory(dynamicDirectoryPath));
    ActionLogHelper.setFileHandler(fileHandler);
  });

  // Tests
  // - Ensure getting log files
  // - Ensure reading from log file
  // - Ensure writing to log file

  Future<List<FileSystemEntity>> _getLogFiles() async {
    final logFiles = await ActionLogHelper.getListOfLogs("");
    expect(logFiles, isNotNull);
    expect(logFiles, isNotEmpty);
    expect(logFiles.length, 1);
    return logFiles;
  }

  test("Logs directory is correct.", () async {
    final logFilePath = await ActionLogHelper.getLogFilePath(logDirectory: "");
    expect(logFilePath, dynamicDirectoryPath);
  });
}
