# environment_switcher

This package is designed to simplify the boilerplate required to create an environment selector. The idea is that tester (whether internal or external) should be able to easily and quickly switch between app environments/flavours. For example, testers should be able to switch from a mock server to a live server. In this case, a banner is used in the top right corner of the app to allow switching environments. It does assume that the default "Debug banner" is disabled.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
environment_switcher:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: environment_switcher
    ref: EnvironmentSwitcher-v0.0.1 # Use the latest EnvironmentSwitcher tag!!
```

### Constructor Arguments

- `builder` - This is the builder for the child on which the `EnvironmentSwitcher` will be built on top of.
- `environments` - This is a list of `Environment` objects that will be displayed in the switcher for the tester to choose from. This cannot be empty.
- `environmentStore` - [Optional] This is preferences storage extension that can be used. The default `EnvironmentStorage` object uses the [MyOxygen Store package](https://github.com/MyOxygen/MyOxygen-Flutter-Libraries/tree/Environment-Switcher/store) to store the last used `Environment`.
- `showBanner` - [Optional] This simply hides the banner from view. The idea is that on a Production release, developers can simply toggle this flag to disable the switcher. Default: `true`.
- `defaultEnvironment` - [Optional] This sets the environment to use when the banner is not show (`showBanner: false`). This is an optional parameter, but **must** be set when `showBanner` is `true`.

### Example Use

In this package, there is an example project that shows the `EnvironmentSwitcher` in action.

The code below is simply a simplified copy of the example project.

```dart

final environments = [
    Environment(
        name: "Mock Blue",
        description: "A blue mock environment",
        bannerColor: Colors.blue,
        databaseName: "mockB",
    ),
    Environment(
        name: "Mock Green",
        description: "A green mock environment",
        bannerColor: Colors.green,
        databaseName: "mockG",
    ),
    ...
    // Add more environments if you so wish
    ),

    Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, // Important!!
        title: 'EnvironmentSwitcher Demo',
        home: MyHomePage(title: 'EnvironmentSwitcher Home Page'),
    );
    }
];

class MyHomePage extends StatefulWidget {
    final String title;

    MyHomePage({Key key, this.title}) : super(key: key);

    @override
    _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    int _counter = 0;

    void _incrementCounter() {
        setState(() {
        _counter++;
        });
    }

    @override
    Widget build(BuildContext context) {
        // The EnvironmentSwitcher is placed at the top of every page so that every
        // page has its own EnvironmentSwitcher.
        return EnvironmentSwitcher(
            environments: environments,
            builder: (environment) => 
                Scaffold(
                    appBar: AppBar(title: Text(widget.title)),
                    body: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Text(
                                '${environment.name}',
                                style: TextStyle(color: environment.bannerColor),
                                ),
                                const SizedBox(height: 200),
                                Text('You have pushed the button this many times:'),
                                Text(
                                '$_counter',
                                style: Theme.of(context).textTheme.display1,
                                ),
                            ],
                        ),
                    ),
                    floatingActionButton: FloatingActionButton(
                        onPressed: _incrementCounter,
                        tooltip: 'Increment',
                        child: Icon(Icons.add),
                    ),
                ),
        );
    }
}
```

**Important**

> Repeatedly putting `EnvironmentSwitcher` at the top of each page is really annoying. I'll just put it in the `MaterialApp` builder/home properties. Better yet I'll put it above the `MaterialApp` so it covers all the app!

NO! The `EnvironmentSwitcher` makes use of the modal bottom sheet, which in turn utilises instances of `MediaQuery`, `MaterialLocalizations`, and `Navigator`. The `MaterialApp` widget initialises instances of `MediaQuery` and `MaterialLocalizations` in its build, so that subsequent widgets can call `MediaQuery.of(context)` to access properties like screen size. Putting `EnvironmentSwitcher` above `MaterialApp` simply means the widget will not be able to access those instances, which will result in no modal sheet, and a multitude of error messages in the console.

```dart
Widget build(BuildContext context) {
    // This will fail, because EnvironmentSwitcher needs access to MediaQuery,
    // MaterialLocalizations, and Navigator, which are initialised in the
    // MaterialApp widget.
    return EnvironmentSwitcher(
        builder: (environment) => 
            MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'EnvironmentSwitcher Demo',
                home: MyHomePage(title: 'EnvironmentSwitcher Demo Home Page'),
            ),
    );
}
```

Similarly, `MaterialApp` creates an instance of `Navigator`, meaning it is only accessible from a child of the `MaterialApp`. In addtition, `EnvironmentSwitcher` should not be built using the same `BuildContext` used to build the `MaterialApp` widget, as that `BuildContext` does not have an instance of `Navigator`. For example:

```dart
Widget build(BuildContext context) {
    // This will fail, because EnvironmentSwitcher needs access to a BuildContext
    // that contains an instance of the Navigator. In this case, the BuildContext
    // used to create the EnvironmentSwitcher does not have an instance of
    // MaterialApp, which means it will not have an instance of Navigator for
    // the EnvironmentSwitcher to use.
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EnvironmentSwitcher Demo',
        home: EnvironmentSwitcher(
            builder: (environment) => 
                MyHomePage(title: 'EnvironmentSwitcher Demo Home Page'),
        ),
    );
}
```

With the above in mind, the following works:


```dart
Widget build(BuildContext context) {
    // It works!
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EnvironmentSwitcher Demo',
        home: MyHomePage(title: 'EnvironmentSwitcher Demo Home Page'),
    );
}

class MyHomePage extends StatelessWidget {
    ...
    @override
    Widget build(BuildContext context) {
        return EnvironmentSwitcher(
            builder: (environment) => 
                Scaffold(
                    body: Center(
                        child: Text("Current environment: ${environment.name}"),
                    ),
                ),
        );
    }
}
```
