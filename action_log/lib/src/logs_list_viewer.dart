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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Logs List"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: ActionLogHelper.getListOfLogs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplay(snapshot.error);
          } else if (snapshot.hasData) {
            final fileList = snapshot.data;
            if (fileList.isEmpty) {
              return Center(child: Text("No files to show."));
            } else {
              return ListView.builder(
                itemCount: fileList.length,
                itemBuilder: (BuildContext context, int index) {
                  final fileName = basenameWithoutExtension(fileList[index].path);
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
                            fileSystemEntity: fileList[index],
                          ),
                        ),
                      );

                      if (fileDeleted) {
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
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
}
