import 'dart:io';

import 'package:flutter/material.dart';

import 'internal/file_handler.dart';

class ActionLogHelper {
  static const _logDirectory = "logs";
  static String? _actualLogDirectory;
  static late FileHandler _fileHandler;
  static late GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  static void setScaffoldMessengerKey(
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    _scaffoldMessengerKey = scaffoldMessengerKey;
  }

  static void setFileHandler(final FileHandler? fileHandler) {
    _fileHandler = fileHandler ?? FileHandler();
  }

  /// Retrieves the app's directory where the logs will be stored. Returns the
  /// directory path as a [String].
  static Future<String> getLogFilePath(final String? logDirectory) async {
    Directory localDirectory;
    try {
      localDirectory = await _fileHandler.getCurrentDirectory();
    } catch (e) {
      throw "Failed to get application documents directory\n$e";
    }

    _actualLogDirectory = logDirectory;
    if (_actualLogDirectory == null) {
      _actualLogDirectory = _logDirectory;
    }

    final directoryPath =
        "${localDirectory.path}${_actualLogDirectory!.trim().isEmpty ? "" : "/$_actualLogDirectory"}";

    Directory logsDirectory;
    try {
      logsDirectory = await Directory(directoryPath).create();
    } catch (e) {
      throw "Failed to create logs directory\n$e";
    }

    return logsDirectory.path;
  }

  /// Retrieves the list of files from the logs directory. The returned list is
  /// a list of [FileSystemEntity] objects. These objects should contain all the
  /// necessary information for each file. Note that any folders in the
  /// directory will *not* be returned.
  static Future<List<FileSystemEntity>> getListOfLogs([final String? logDirectory]) {
    return getLogFilePath(logDirectory ?? _actualLogDirectory).then((filePath) {
      final listOfFiles = Directory(filePath).listSync();
      return listOfFiles.where((element) => element is File).toList();
    });
  }

  static void displaySnackBar(final String message, {final Widget? withAction}) {
    _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Expanded(child: Text(message)),
          withAction ?? const SizedBox(),
        ],
      ),
    );
    _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }
}
