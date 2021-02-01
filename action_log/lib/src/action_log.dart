import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'action_log_helper.dart';

class ActionLog {
  static String _filePath;
  static String _lastFileName;
  static bool _isInitialised = false;

  /// Initialises the `ActionLog` class to be used throughout the code. Without
  /// this initialisation, no logging of any kind will occur. `isPublicRelease`
  /// also determines whether any logging should occur. Logging shouldn't be
  /// part of a production release, but during debugging and testing it is
  /// accepted (even encouraged).
  ///
  /// There is an optional `fileName` for specifying the filename to use when
  /// logging to a file.
  static Future<void> initialise({
    @required bool isPublicRelease,
    String fileName,
  }) async {
    assert(isPublicRelease != null);

    if (isPublicRelease) {
      // Don't log in public release mode.
      return;
    }

    // Enable console logging before all else, which will allow devs to see why
    // creating a directory could go wrong.
    Fimber.plantTree(DebugTree(useColors: true));

    _filePath = await ActionLogHelper.getLogFilePath();

    // Create a new file on every initialisation with the date/time (unix
    // format) as the file name. This helps determine when the app was
    // launched (or at least initialised).
    _lastFileName = fileName;
    if (fileName == null || fileName.isEmpty || fileName.trim().isEmpty) {
      _lastFileName = "${DateTime.now().millisecondsSinceEpoch}.txt";
    }

    // In the file, store each log in the format:
    // [Time]\t[Level]\t[Message]\t[Exception (if provided)]
    // For example:
    // 2020-09-24T14:54:31.292061  E  Failed to do something  Missing null-check
    Fimber.plantTree(FimberFileTree("$_filePath/$_lastFileName",
        logFormat: "${CustomFormatTree.timeStampToken}\t"
            "${CustomFormatTree.levelToken}\t"
            "${CustomFormatTree.messageToken}\t"
            "${CustomFormatTree.exceptionMsgToken}"));
    i("Logging initialised");

    _isInitialised = true;
  }

  /// Writes an "information" level message to the logs. This is denoted by the
  /// letter "I" in the logs.
  static void i(String message, {dynamic ex}) {
    Fimber.i(message, ex: ex);
  }

  /// Writes an "error" level message to the logs. This is denoted by the letter
  /// "E" in the logs.
  static void e(String message, {dynamic ex}) {
    Fimber.e(message, ex: ex);
  }

  /// Writes a "warning" level message to the logs. This is denoted by the
  /// letter "W" in the logs.
  static void w(String message, {dynamic ex}) {
    Fimber.w(message, ex: ex);
  }

  /// Reads the contents of the log files, and returns a `Map` containing the
  /// contents of the log files separated by the log file names. An example:
  /// ```
  /// {
  ///   "logFile1" : "Pressed button 1\nPressed button 2",
  ///   "logFile2" : "Typed \"some text\"\nPressed submit button",
  /// }
  /// ```
  static Future<Map<String, String>> readLogFiles() async {
    final logFileMap = <String, String>{};

    if (!_isInitialised) {
      // ActionLog has not been initialised, so don't do anything.
      logFileMap["NONE"] = "Uninitialised";
      return logFileMap;
    }

    final fileDirectory = Directory(_filePath);

    // Check that the folder containing the log files exists.
    if (!await fileDirectory.exists()) {
      logFileMap["NONE"] = "Log path does not exist";
      return logFileMap;
    }

    // At any point during reading the files, the OS could do a funny and remove
    // or change the files and/or directories. Wrap in a try/catch to prevent
    // any funny business.
    try {
      final files = fileDirectory.listSync();
      if (files == null || files.isEmpty) {
        logFileMap["FILES"] = "No log files to read";
        return logFileMap;
      }

      for (final fileEntity in files) {
        await _updateLogFileMapWithFile(logFileMap, fileEntity);
      }

      // Log files might have been removed (if successful). We need to
      // re-initialise, so that a new log file is assigned/created.
      Fimber.clearAll();
      // Set public release to false, as we shouldn't be at this point if it
      // were a public release.
      await initialise(isPublicRelease: false);

      return logFileMap;
    } catch (e) {
      logFileMap["FILES"] = "Failed to read log files:\n$e";
    }

    return logFileMap;
  }

  /// [Internal Function]
  /// Adds the file entity (defined by `entity`) to the `Map` of log files. Each
  /// log file is added by its basename *without extensions*, and its contents
  /// are written in one long string. Once a file has been read, it is deleted.
  ///
  /// This function handles missing files and unreadable files. It also handles
  /// if a file fails to be delete.
  static Future<void> _updateLogFileMapWithFile(
      Map<String, String> logFileMap, FileSystemEntity entity) async {
    final baseName = basenameWithoutExtension(entity.path);
    final file = File(entity.path);
    if (await file.exists()) {
      try {
        logFileMap[baseName] = await file.readAsString();
      } catch (e) {
        logFileMap[baseName] = "File was determined as 'existing', but could not be read\n$e";
      }
    } else {
      logFileMap[baseName] = "Log file ceased to exist.";
    }

    // File has been read (or tried to), delete the file.
    try {
      file.deleteSync();
    } catch (e) {
      logFileMap["$baseName-DELETE"] = "Failed to delete log file\n$e";
    }
  }
}
