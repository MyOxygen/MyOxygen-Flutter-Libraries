import 'package:flutter/material.dart';

import 'package:action_log/action_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ActionLog.initialise(isPublicRelease: false);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ActionLog - Demonstration'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed,
          child: Icon(Icons.plus_one),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Counter: $counter',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Builder(
                  builder: (context) => RaisedButton(
                    child: Text("View logs"),
                    onPressed: () => ActionLog.navigateToLogsListView(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFabPressed() {
    final lastValue = counter;
    setState(() {
      counter += 1;
      ActionLog.i("Incremented counter from $lastValue to $counter.");
    });
  }
}
