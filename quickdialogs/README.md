# QuickDialogs

This package is designed to simplify the boilerplate required to create a basic dialog. Creating a simple information dialog takes about 30 lines of code. In multiple Flutter projects, there will come a need to create dialogs, for whatever reason (confirmation, information, warning etc). It is worth having a quick way of writing a simple dialog, so that we can speed development up by a long shot for future projects.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
quickdialogs:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: quickdialogs
    ref: QuickDialogs-v0.0.2 # Use the latest QuickDialogs tag!!
```

### QuickDialogs' APIs

- `QuickDialogs.dialogTheme`
  - Sets up the platform theme of the dialogs. By default, this will be `QuickDialogsTheme.platformSpecific`, where it will automatically determine the platform it is running on to show the right theme. For example, it will use the Material Design theme for Android devices, and the Cupertino theme for iOS.
  - Available options:
    - `.platformSpecific` - Automatically determines the platform to show the right theme for the right platform.
    - `.cupertinoOnly` - No matter which platform, use the Cupertino style.
    - `.materialOnly` - No matter which platform, use the Material style.
- `QuickDialogs.infoDialog`
  - Create a standard dialog that has a title, message, and "close dialog" button. All styling is set to default.
  - Example use cases: information, errors, warnings.
  - Parameters
    - `context` - This is the build context for which the builder needs access to.
    - `title` - The string title of the dialog box.
    - `message` - The message of the dialog box. For example, what information should be shown to the user?
    - `okButton` - [Optional] The string for closing the dialog box. This defaults to `OK`.
    - `onOkClicked` - [Optional] Any additional computation that needs to happen on closing the dialog.
  - Returns: `void`. 
- `QuickDialogs.confirmation`
  - Creates a dialog that gives the user two options to select from
  - Example use cases: "Continue?", yes/no questions, etc.
  - Parameters
    - `context` - This is the build context for which the builder needs access to.
    - `title` - The string title of the dialog box.
    - `message` - The message of the dialog box. For example, what information should be shown to the user?
    - `positiveButtonText` - The string that will be shown on the button that answers the question positively, for example "Yes".
    - `negativeButtonText` - The string that will be shown on the button that answers the question negatively, for example "No".
  - Returns: `Future<bool>`, where `true` means the positive button was pressed, and `false` means the negative button was pressed.
- `QuickDialogs.destructive`
  - Similar to the `confirmation` dialog, this creates a dialog that contains one option to clear data in red, and an option to stop that from happening. The red option is used to signify that some risky operation will happen if you select it, and it is generally not advised to use it unless you know what you are doing.
  - Example use cases: deleting confirmation, removing data confirmation.
  - Parameters
    - `context` - This is the build context for which the builder needs access to.
    - `title` - The string title of the dialog box.
    - `message` - The message of the dialog box. For example, what information should be shown to the user?
    - `constructiveActionName` - The string that will be shown on the button that prevents the dangerous action from happening.
    - `destructiveActionName` - The string that will be shown on the button that will execute the dangerous action.
    - `destructiveActionCallback` - [Optional] The callback when the user presses the destructive (red) action button.
  - Returns: `void`.

### Example use

```dart
    // Get confirmation from the user.
    final userConfirmed = await QuickDialogs.confirmationDialogAsync(
        event.context,
        title: "Confirmation",
        message: "Are you sure?",
        negativeButtonText: "No",
        positiveButtonText: "Yes",
    );

    // Warn user they are about to delete all their data.
    QuickDialogs.destructive(
      context,
      title: "Delete",
      message: "Are you absolutely sure you wish to delete everything?",
      constructiveActionName: "Cancel",
      destructiveActionName: "Delete",
      destructiveActionCallback: () {
        deleteEverything();
      },
    );

    QuickDialogs.infoDialog(
      context,
      "Information",
      "Everything has been successfully deleted.",
    );
```