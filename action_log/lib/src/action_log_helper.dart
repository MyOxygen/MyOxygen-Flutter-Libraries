import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ActionLogConstants {
  static const _logDirectory = "logs";

  static Future<String> getLogFilePath() async {
    final localDirectory = await getApplicationDocumentsDirectory();
    if (localDirectory == null) {
      throw "Application directory was NULL";
    }

    Directory logsDirectory;
    try {
      logsDirectory = await Directory("${localDirectory.path}/$_logDirectory").create();
    } catch (e) {
      throw "Failed to create logs directory\n$e";
    }

    return logsDirectory.path;
  }

  static Future<List<FileSystemEntity>> getListOfLogs() {
    return getLogFilePath().then((filePath) {
      final listOfFiles = Directory(filePath).listSync();
      if (listOfFiles == null) {
        return <FileSystemEntity>[];
      }

      return listOfFiles;
    });
  }
}
