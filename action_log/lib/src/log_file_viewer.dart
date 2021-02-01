import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'internal/error_display.dart';

/// This widget displays the contents of the log file as if it were on the
/// console (horizontal and vertical scrolling, mon-spaced font).
class LogFileViewer extends StatelessWidget {
  final String title;
  final FileSystemEntity fileSystemEntity;

  /// This widget displays the contents of the log file as if it were on the
  /// console (horizontal and vertical scrolling, mon-spaced font).
  const LogFileViewer({@required this.title, @required this.fileSystemEntity})
      : assert(title != null),
        assert(fileSystemEntity != null);

  @override
  Widget build(BuildContext context) {
    final file = File(fileSystemEntity.path);
    if (!file.existsSync()) {
      return _buildBody(ErrorDisplay("File does not exist."));
    }

    String fileContents = "";
    try {
      fileContents = file.readAsStringSync();
    } catch (e) {
      return _buildBody(ErrorDisplay("Failed to read file\n$e"));
    }

    return _buildBody(
      SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Text(
            fileContents,
            style: GoogleFonts.robotoMono(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(final Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
    );
  }
}
