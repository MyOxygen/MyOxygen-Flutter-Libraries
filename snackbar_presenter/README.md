# SnackBarPresenter

This package is designed to simplify the boilerplate required to create a custom `SnackBar`. This custom `SnackBar` contains an icon to help the user distinguish the type of message they are seeing. The presenter has separate icons for information, success/confirmation, and error/denied messages.  The icons cannot be changed, but the icons' colour can.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
snackbar_presenter:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: snackbar_presenter
    ref: SnackBarPresenter-v0.0.1 # Use the latest SnackBarPresenter tag!!
```

### SnackBarPresenter's APIs

- `SnackBarPresenter.presentInformation`
  - Displays a `SnackBar` with an information icon ([infoCircle](https://fontawesome.com/icons/info-circle?style=solid)) on the left.
  - Available options:
    - `scaffoldKey` - The key pointing to the `Scaffold` onto which the `SnackBar` will be attached to.
    - `message` - A string of information text to display in the `SnackBar`.
    - `iconColor` - [Optional] Customise the colour of the icon. Default: `iconThemeData.color`.
  - Returns: `void`.
- `SnackBarPresenter.presentSuccess`
  - Displays a `SnackBar` with a success/confirmation icon ([solidCheckCircle](https://fontawesome.com/icons/check-circle?style=solid)) on the left.
  - Available options:
    - `scaffoldKey` - The key pointing to the `Scaffold` onto which the `SnackBar` will be attached to.
    - `message` - A string of success/confirmation text to display in the `SnackBar`.
    - `iconColor` - [Optional] Customise the colour of the icon. Default: `0xff4dd662`.
  - Returns: `void`.
- `SnackBarPresenter.presentError`
  - Displays a `SnackBar` with an error/denied icon ([exclamationCircle](https://fontawesome.com/icons/exclamation-circle?style=solid)) on the left.
  - Available options:
    - `scaffoldKey` - The key pointing to the `Scaffold` onto which the `SnackBar` will be attached to.
    - `error` - A string of error/denied text to display in the `SnackBar`.
    - `iconColor` - [Optional] Customise the colour of the icon. Default: `0xffed6e73`.
  - Returns: `void`.

### Example use

```dart
    // Class variable
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    
    // In build()
    return Scaffold(
        key: _scaffoldKey,
        body: ... ,
    );

    // Elsewhere in the code...
    // Show a general information SnackBar.
    SnackBarPresenter.presentInformation(
        _scaffoldKey,
        "Informative text",
    );
    
    // Show a general information SnackBar with different coloured icon
    SnackBarPresenter.presentInformation(
        _scaffoldKey,
        "Informative text",
        iconColor: Colors.blue,
    );
```
