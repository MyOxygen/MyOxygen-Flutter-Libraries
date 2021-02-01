import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ActionLogHelper {
  static const _logDirectory = "logs";

  /// Retrieves the app's directory where the logs will be stored. Returns the
  /// directory path as a [String].
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

  /// Retrieves the list of files from the logs directory. The returned list is
  /// a list of [FileSystemEntity] objects. These objects should contain all the
  /// necessary information for each file.
  static Future<List<FileSystemEntity>> getListOfLogs() {
    return getLogFilePath().then((filePath) {
      final listOfFiles = Directory(filePath).listSync();
      if (listOfFiles == null) {
        return <FileSystemEntity>[];
      }

      return listOfFiles;
    });
  }

  static void displaySnackBar(final ScaffoldState scaffoldState, final String message,
      {final Widget withAction}) {
    scaffoldState.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Expanded(child: Text(message)),
          withAction ?? const SizedBox(),
        ],
      ),
    );
    scaffoldState.showSnackBar(snackBar);
  }
}
