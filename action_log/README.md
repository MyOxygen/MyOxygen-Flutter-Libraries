# ActionLog

This package is designed to simplify logging various user actions and/or catching specific error messages, and saving these actions and messages to a log file. These log files are then accessible in a list of log files, where each log file can be viewed and then copied or deleted as and when necessary. All these log entries are automatically visible in the console.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
action_log:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: action_log
    ref: ActionLog-v0.0.1 # Use the latest ActionLog tag!!
```

### SnackBarPresenter's APIs

- `ActionLog.initialise`
  - Initialises `ActionLog` and prepares the necessary log files and configurations for logging entries. If this is specified that it is a production release (`isPublicRelease: true`), nothing is set up and nothing is logged, thus not affecting performance on the production release.
  - Available options:
    - `isPublicRelease` - The flag to determine whether the build will be released to the public app stores, and therefore should not have logging initialised.
    - `logFolderName` - [Optional] The name of the folder in which the log files will be stored in. If not set, this is automatically set within the `ActionLog` initialiser.
    - `fileName` - [Optional] The name of the file to store log entries in. If not set, this is automatically set within the `ActionLog` initialiser.
  - Returns: `Future<void>`.
- `ActionLog.i`
  - Adds an information entry to both the console and the log file.
  - Available options:
    - `message` - A custom message describing the entry.
    - `ex` - [Optional] The exception from a `try/catch` block.
  - Returns: `void`.
- `ActionLog.e`
  - Adds an error entry to both the console and the log file.
  - Available options:
    - `message` - A custom message describing the entry.
    - `ex` - [Optional] The exception from a `try/catch` block.
  - Returns: `void`.
- `ActionLog.w`
  - Adds a warning entry to both the console and the log file.
  - Available options:
    - `message` - A custom message describing the entry.
    - `ex` - [Optional] The exception from a `try/catch` block.
  - Returns: `void`.
- `ActionLog.navigateToLogsListView`
  - Takes the user to the list of available logs stored on the device.
  - Available options:
    - `context` - The `BuildContext` where the `Navigator` will be obtained from.
  - Returns: `void`.

### Example use

```dart
    // Import the package
    import 'package:action_log/action_log.dart';

    // At start of app (right at the start)
    await ActionLog.initialise(isPublicRelease: false);
    
    // In code
    int divideXbyY(int x, int y) {
        ActionLog.i("Dividing $x by $y.");
        if (y == 0) {
            ActionLog.w("About to divide by 0. This may go wrong.");
            // Do custom handling
        }

        try {
            return x ~/ y;
        } catch (e) {
            ActionLog.e("Failed to do division.", ex: e);
            return 0; // Or rethrow?
        }
    }

    // Elsewhere in the code...
    // Navigate to the logs list
    ActionLog.navigateToLogsListView(context);
```
