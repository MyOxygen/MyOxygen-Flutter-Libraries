import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'action_log_helper.dart';
import 'internal/error_display.dart';
import 'log_file_viewer.dart';

/// Simple list view of the log files saved.
class LogsListViewer extends StatefulWidget {
  const LogsListViewer();

  @override
  State<StatefulWidget> createState() {
    return _LogsListViewerState();
  }
}

class _LogsListViewerState extends State<LogsListViewer> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<FileSystemEntity> listOfFiles;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: ActionLogHelper().getListOfLogs(),
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasError) {
          body = ErrorDisplay(snapshot.error);
        } else if (!snapshot.hasData) {
          body = Center(child: CircularProgressIndicator());
        } else {
          listOfFiles = snapshot.data;
          if (listOfFiles.isEmpty) {
            body = Center(child: Text("No files to show."));
          } else {
            body = ListView.builder(
              itemCount: listOfFiles.length,
              itemBuilder: (BuildContext context, int index) {
                final fileName = basenameWithoutExtension(listOfFiles[index].path);
                final formattedString = _formatFileName(fileName);
                if (formattedString == null) {
                  return const SizedBox();
                }
                return ListTile(
                  title: Text(formattedString),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue[300],
                  ),
                  onTap: () async {
                    final fileDeleted = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogFileViewer(
                          title: formattedString,
                          fileSystemEntity: listOfFiles[index],
                        ),
                      ),
                    );

                    // `fileDeleted` could be null when the user presses the
                    // back button. We only want to delete if the user actually
                    // presses the delete button.
                    if (fileDeleted == true) {
                      // We need to reload the page to stop displaying the
                      // non-existing file.
                      setState(() {});
                      ActionLogHelper.displaySnackBar(
                        _scaffoldKey.currentState,
                        "Log file delete successfully.",
                      );
                    }
                  },
                );
              },
            );
          }
        }

        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Logs List"),
              centerTitle: true,
              actions: [
                // Delete this log file
                if (listOfFiles != null && listOfFiles.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: _onDeletePressed,
                  ),
              ],
            ),
            body: body);
      },
    );
  }

  String _formatFileName(final String fileName) {
    final timeStamp = int.tryParse(fileName);
    if (timeStamp == null) {
      return null;
    }

    final dateTime = DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    return DateFormat("dd MMM yyyy - HH:mm:ss").format(dateTime);
  }

  Future<void> _onDeletePressed() async {
    ActionLogHelper.displaySnackBar(
      _scaffoldKey.currentState,
      "Are you sure you wish to delete all log files?",
      withAction: FlatButton(
        child: Text("Delete all"),
        textColor: Colors.red,
        onPressed: () async {
          String snackBarMessage = "Log files deleted.";
          for (final file in listOfFiles) {
            try {
              await file.delete();
            } catch (e) {
              snackBarMessage = "Some log files could not be deleted. $e";
            }
          }

          // Whether errors occur or not, we need to reload the page.
          setState(() {});
          ActionLogHelper.displaySnackBar(_scaffoldKey.currentState, snackBarMessage);
        },
      ),
    );
  }
}
