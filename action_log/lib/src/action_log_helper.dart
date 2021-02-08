import 'dart:io';

import 'package:flutter/material.dart';

import 'internal/file_handler.dart';

class ActionLogHelper {
  static const _logDirectory = "logs";
  static String _actualLogDirectory;
  static FileHandler _fileHandler;

  static void setFileHandler(final FileHandler fileHandler) {
    _fileHandler = fileHandler ?? FileHandler();
  }

  /// Retrieves the app's directory where the logs will be stored. Returns the
  /// directory path as a [String].
  static Future<String> getLogFilePath(final String logDirectory) async {
    final localDirectory = await _fileHandler.getCurrentDirectory();
    if (localDirectory == null) {
      throw "Application directory was NULL";
    }

    _actualLogDirectory = logDirectory;
    if (_actualLogDirectory == null) {
      _actualLogDirectory = _logDirectory;
    }

    final directoryPath =
        "${localDirectory.path}${_actualLogDirectory.trim().isEmpty ? "" : "/$_actualLogDirectory"}";

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
  static Future<List<FileSystemEntity>> getListOfLogs([final String logDirectory]) {
    return getLogFilePath(logDirectory ?? _actualLogDirectory).then((filePath) {
      final listOfFiles = Directory(filePath).listSync();
      if (listOfFiles == null) {
        return <FileSystemEntity>[];
      }

      return listOfFiles.where((element) => element is File).toList();
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
