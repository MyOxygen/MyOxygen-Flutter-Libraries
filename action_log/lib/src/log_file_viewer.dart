import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'internal/error_display.dart';

class LogFileViewer extends StatefulWidget {
  final String title;
  final FileSystemEntity fileSystemEntity;

  const LogFileViewer({@required this.title, @required this.fileSystemEntity})
      : assert(title != null),
        assert(fileSystemEntity != null);

  @override
  _LogFileViewerState createState() => _LogFileViewerState();
}

class _LogFileViewerState extends State<LogFileViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<String>(
        future: _getFileContents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplay(snapshot.error);
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Text(
                snapshot.data,
                style: GoogleFonts.robotoMono(),
              ),
            ),
          );
        },
      ),
    );
  }

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
}
