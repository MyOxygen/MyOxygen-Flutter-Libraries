import 'dart:io';

import 'package:flutter/material.dart';

import 'internal/file_handler.dart';

class ActionLogHelper {
  static const _logDirectory = "logs";
  static String? _actualLogDirectory;
  static late FileHandler? _fileHandler;

  static void setFileHandler(final FileHandler? fileHandler) {
    _fileHandler = fileHandler ?? FileHandler();
  }

  /// Retrieves the app's directory where the logs will be stored. Returns the
  /// directory path as a [String].
  static Future<String> getLogFilePath({String? logDirectory}) async {
    assert(_fileHandler != null);
    final localDirectory = await _fileHandler!.getCurrentDirectory();

    final _actualLogDirectory = logDirectory ?? _logDirectory;

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
  static Future<List<FileSystemEntity>> getListOfLogs([final String logDirectory = _logDirectory]) {
    return getLogFilePath().then((filePath) {
      final listOfFiles = Directory(filePath).listSync();
      return listOfFiles.where((element) => element is File).toList();
    });
  }

  static void displaySnackBar(final ScaffoldMessengerState messengerState, final String message,
      {final Widget? withAction}) {
    messengerState.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Expanded(child: Text(message)),
          withAction ?? const SizedBox(),
        ],
      ),
    );
    messengerState.showSnackBar(snackBar);
  }
}
