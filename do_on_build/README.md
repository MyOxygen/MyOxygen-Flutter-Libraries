# DoOnBuild

This package is designed to simplify the complexity and to clarify what is going on. Flutter provides the option to add a callback when the `build()` method has been executed, but it is not an obvious method to find or read. The `addPostFrameCallback()` method is found within the `instance` property of the `WidgetsBinding` class, which in turn is found in the `material.dart` file. Who would have thunk? It is worth having a quick way of adding a callback using a method name that is clear to read and understand.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
do_on_build:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: do_on_build
    ref: DoOnBuild-v0.0.1 # Use the latest DoOnBuild tag!!
```

### DoOnBuild's APIs

- `doOnBuild(Function callback)`
  - Adds the `callback` to a list of functions to call after the widget's `build()` method has been executed. When multiple callbacks are added, the callbacks are executed in a "first come, first executed" manner.
  - Parameters:
    - `callback` - The method to callback once the `build()` method has been executed. This can be an `async` method.
  - Returns: `void`.

### Example use

```dart
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget();

  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool hasTextChanged = false;
  String text = "Will change in 5 seconds";
  
  @override
  Widget build(BuildContext context) {
    if (!hasTextChanged) {
      doOnBuild(() async {
        await Future.delayed(const Duration(seconds: 5));
        setState(() {
          text = "Text has changed!";
          hasTextChanged = true;
        });
      });
    }
    
    return Container(
      child: Text(text),
    );
  }
}
```
