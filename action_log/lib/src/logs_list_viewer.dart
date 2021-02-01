import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'action_log_helper.dart';
import 'internal/error_display.dart';
import 'log_file_viewer.dart';

/// Simple list view of the log files saved.
class LogsListViewer extends StatelessWidget {
  const LogsListViewer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logs List"),
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
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogFileViewer(
                          title: formattedString,
                          fileSystemEntity: fileList[index],
                        ),
                      ),
                    ),
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
