import 'package:environment_switcher/environment_switcher.dart';
import 'package:flutter/material.dart';

final environments = <Environment<EnvData>>[
  Environment(
    name: "Mock Blue",
    description: "A blue mock environment",
    bannerColor: Colors.blue,
  ),
  Environment(
    name: "Mock Green",
    description: "A green mock environment",
    bannerColor: Colors.green,
  ),
  Environment(
    name: "Mock Red",
    description: "A red mock environment",
    bannerColor: Colors.red,
    data: EnvData("MyString", 1234),
  ),
];

class EnvData extends EnvironmentData {
  final String someString;
  final int someValue;

  const EnvData(this.someString, this.someValue);

  @override
  List<Object> get props => [someString, someValue];

  @override
  String toString() {
    return "$someString || $someValue";
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return EnvironmentSwitcher(
      environments: environments,
      defaultEnvironment: environments[0],
      childBuilder: (ctx) {
        // Obtain the current environment by calling the ancestor.
        final environment = EnvironmentSwitcher.of<EnvData>(ctx)?.currentEnvironment;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${environment?.name}' +
                      (environment?.data == null ? "" : " ${environment.data}"),
                  style: TextStyle(color: environment?.bannerColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
