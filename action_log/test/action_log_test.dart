import 'dart:io';

import 'package:action_log/action_log.dart';
import 'package:action_log/src/internal/error_display.dart';
import 'package:action_log/src/internal/file_handler.dart';
import 'package:action_log/src/logs_list_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

const dynamicDirectoryPath = "./test/resources/";
const buttonText = "Display logs";
const logFileName = "1612182198635";
const logFileNameWithExtension = "1612182198635.txt";
final logFileNameAsDateTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(logFileName));
final logFileNameDisplayed = "01 Feb 2021 - 12:23:18";
final mockObserver = MockNavigatorObserver();
final key = GlobalKey<ScaffoldMessengerState>();

FileHandler fileHandler;

Future<void> _createApp(WidgetTester tester) async {
  final app = MaterialApp(
    scaffoldMessengerKey: key,
    navigatorObservers: [mockObserver],
    home: Builder(
      builder: (BuildContext context) {
        return Scaffold(
          body: Center(
            child: ElevatedButton(
              child: const Text(buttonText),
              onPressed: () => ActionLog.navigateToLogsListView(context),
            ),
          ),
        );
      },
    ),
  );

  await tester.pumpWidget(app);
}

void main() {
  setUpAll(() {
    fileHandler = MockFileHandler();
    when(fileHandler.getCurrentDirectory())
        .thenAnswer((_) async => Directory(dynamicDirectoryPath));

    ActionLog.initialise(
      isPublicRelease: false,
      logFolderName: "",
      fileName: logFileNameWithExtension,
      fileHandler: fileHandler,
      scaffoldMessengerKey: key,
    );
  });

  testWidgets("App builds ok", (WidgetTester tester) async {
    await tester.runAsync(() async {
      await _createApp(tester);

      final buttonTextFinder = find.text(buttonText);
      expect(buttonTextFinder, findsOneWidget,
          reason: "The main app should be displaying a button to open the logs.");
    });
  });

  testWidgets("Display the list of logs", (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: LogsListViewer()));

      // Check the log file list is displaying
      final logFileListWidget = find.byType(LogsListViewer);
      expect(logFileListWidget, findsOneWidget, reason: "The log file list should be displayed.");

      // Check the single log file is displaying
      final errorDisplayFinder = find.byType(ErrorDisplay);
      expect(errorDisplayFinder, findsNothing, reason: "No errors should be displayed.");

      // On first loading, there should be a loading indicator
      final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(loadingIndicatorFinder, findsOneWidget,
          reason: "There shouldinitially be a loading indicator.");

      // Nothing seems to show afterwards. Maybe it's due to the FutureBuilder?
    });
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFileHandler extends Mock implements FileHandler {}
