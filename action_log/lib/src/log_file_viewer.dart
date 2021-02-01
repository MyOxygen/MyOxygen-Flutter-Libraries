import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'action_log_helper.dart';
import 'internal/error_display.dart';

/// This widget displays the contents of the log file as if it were on the
/// console (horizontal and vertical scrolling, mon-spaced font).
class LogFileViewer extends StatefulWidget {
  final String title;
  final FileSystemEntity fileSystemEntity;

  /// This widget displays the contents of the log file as if it were on the
  /// console (horizontal and vertical scrolling, mon-spaced font).
  const LogFileViewer({@required this.title, @required this.fileSystemEntity})
      : assert(title != null),
        assert(fileSystemEntity != null);

  @override
  _LogFileViewerState createState() => _LogFileViewerState();
}

class _LogFileViewerState extends State<LogFileViewer> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String fileContents = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getFileContents(),
      builder: (_, snapshot) {
        Widget body;
        fileContents = snapshot.data ?? "";

        if (snapshot.hasError) {
          body = ErrorDisplay(snapshot.error);
        } else if (!snapshot.hasData) {
          body = Center(child: CircularProgressIndicator());
        } else {
          body = SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Text(
                fileContents,
                style: GoogleFonts.robotoMono(),
              ),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              // Only display the copy icon if there is text to copy.
              if (fileContents != null && fileContents.trim().isNotEmpty)
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: _onCopyPressed,
                ),

              // Delete this log file
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: _onDeletePressed,
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  /// Gets the contents of the file, and
  Future<String> _getFileContents() {
    final file = File(widget.fileSystemEntity.path);
    if (!file.existsSync()) {
      throw "File does not exist.";
    }

    String fileContents = "";
    try {
      fileContents = file.readAsStringSync();
    } catch (e) {
      throw "Failed to read file\n$e";
    }

    return Future.value(fileContents);
  }

  Future<void> _onCopyPressed() {
    return _doAction(
      widget.fileSystemEntity.delete(),
      "Log contents copied successfully.",
      "Failed to copy log contents.",
    );
  }

  Future<void> _onDeletePressed() async {
    ActionLogHelper.displaySnackBar(
      _scaffoldKey.currentState,
      "Are you sure you wish to delete?",
      withAction: FlatButton(
        child: Text("Delete"),
        textColor: Colors.red,
        onPressed: () async {
          final success = await _doAction(
            widget.fileSystemEntity.delete(),
            "Log file delete successfully.",
            "Failed to delete log file.",
          );

          if (success) {
            Navigator.pop(context, success);
          }
        },
      ),
    );
  }

  Future<bool> _doAction(
    final Future<dynamic> action,
    final String successMessage,
    final String failMessage, {
    bool showExceptionOnFail = true,
  }) async {
    bool success = true;
    String snackbarMessage = successMessage;

    try {
      await action;
    } catch (e) {
      snackbarMessage = "$failMessage${showExceptionOnFail ? " $e" : ""}";
      success = false;
    }

    ActionLogHelper.displaySnackBar(_scaffoldKey.currentState, snackbarMessage);

    return success;
  }
}
