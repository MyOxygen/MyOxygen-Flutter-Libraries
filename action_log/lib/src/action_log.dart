import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import 'action_log_helper.dart';
import 'internal/file_handler.dart';
import 'logs_list_viewer.dart';

class ActionLog {
  static String? _filePath;
  static String? _lastFileName;

  // Use a [Lock] to ensure that only one statements is written into the log
  // file at a time. This ensures that if the app sends two logs at the same
  // time, they are added into the log file one after the other. See link:
  // https://pub.dev/packages/synchronized#example
  static Lock _lock = Lock();

  /// Initialises the `ActionLog` class to be used throughout the code. Without
  /// this initialisation, no logging of any kind will occur. `isPublicRelease`
  /// also determines whether any logging should occur. Logging shouldn't be
  /// part of a production release, but during debugging and testing it is
  /// accepted (even encouraged).
  ///
  /// There is an optional `fileName` for specifying the filename to use when
  /// logging to a file.
  static Future<void> initialise({
    required bool isPublicRelease,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    String? logFolderName,
    String? fileName,
    FileHandler? fileHandler, // For testing
  }) async {
    if (isPublicRelease) {
      // Don't log in public release mode.
      return;
    }

    // Initialise the ScaffoldMessenger key
    ActionLogHelper.setScaffoldMessengerKey(scaffoldMessengerKey);

    // Enable console logging before all else, which will allow devs to see why
    // creating a directory could go wrong.
    Fimber.plantTree(DebugTree(useColors: true));
    ActionLogHelper.setFileHandler(fileHandler);

    _filePath = await ActionLogHelper.getLogFilePath(logFolderName);

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
  }

  /// Writes an "information" level message to the logs. This is denoted by the
  /// letter "I" in the logs.
  static void i(String message, {dynamic ex}) {
    _lock.synchronized(() => Fimber.i(message, ex: ex));
  }

  /// Writes an "error" level message to the logs. This is denoted by the letter
  /// "E" in the logs.
  static void e(String message, {dynamic ex}) {
    _lock.synchronized(() => Fimber.e(message, ex: ex));
  }

  /// Writes a "warning" level message to the logs. This is denoted by the
  /// letter "W" in the logs.
  static void w(String message, {dynamic ex}) {
    _lock.synchronized(() => Fimber.w(message, ex: ex));
  }

  // Automatically navigates to the list of logs.
  static void navigateToLogsListView(final BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogsListViewer(),
      ),
    );
  }
}
