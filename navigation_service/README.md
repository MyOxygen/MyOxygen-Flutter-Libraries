# NavigationService

This package is designed to simplify the boilerplate required to navigate from one screen to another. It also adds features and functionality to prevent type-dependent parameters.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
navigation_service:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: navigation_service
    ref: NavigationService-v0.0.1 # Use the latest NavigationService tag!!
```

### Configuration APIs

- `PageConfiguration`
  - An abstract class containing the base requirements to pass to the `NavigationService`. This should be extended to allow other pages to accept their own parameters.
- `StatelessPage`
  - A page that has no state and is cheap to rebuild. This should accept an extension of `PageConfiguration` for the current page.
- `StatefulPage`
  - A page that has a state and will be rebuilt internally for various reasons. This should accept an extension of `PageConfiguration` for the current page.

### NavigationService APIs

- `NavigationService.navigatorKey`
  - Type: read-only field.
  - The `GlobalKey` to the `NavigatorState`. This needs to be passed to the `navigatorKey` of the `MaterialApp` or `CupertinoApp`, so that the app can navigate.
- `NavigationService.overlayBuilder`
  - Type: field.
  - The function that builds the page with any additional overlay widgets. Leaving this as null will default to no overlay, and will display the page as normal.
  - Example: `overlayBuilder = (page) => EnvironmentBuilder(child: page);`
- `NavigationService.navigateTo`
  - Navigates to a page denoted by the `PageConfiguration` parameter.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.

- `NavigationService.navigate`
  - Type: method.
  - Returns: `void`
  - Navigates to a page denoted by the `PageConfiguration` parameter.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.
- `NavigationService.navigateSingleInstance`
  - Type: method.
  - Returns: `void`
  - Navigates to a page denoted by the `PageConfiguration` parameter, and pops any previous pages with the same route.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.
- `NavigationService.navigateReplacing`
  - Type: method.
  - Returns: `void`
  - Navigates to a page denoted by the `PageConfiguration` parameter, and replaces the navigation stack with the new page.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.
- `NavigationService.pop`
  - Type: method.
  - Returns: `dynamic`
  - Navigates back to the previous page, and carries the page's `result` (if any) to the previous page.
  - Parameters:
    - `result` - [Optional] Any data to be brought back to the previous page.
- `NavigationService.popToRoot`
  - Type: method.
  - Returns: `void`
  - Navigates to the first page in the navigation stack.
  - Parameters: none
- `NavigationService.popToNamed`
  - Type: method.
  - Returns: `void`
  - Navigates back to a page with a matching named route.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.
- `NavigationService.getRoute`
  - Type: method.
  - Returns: `Route`
  - Returns a `Route` to navigate to and use for the `MaterialApp` or `CupertinoApp` to navigate with named routes.
  - Parameters:
    - `configuration` - The page data that the `NavigationService` will use to navigate to and pass any data to.

### Example use

```dart
class MyPageConfiguration extends PageConfiguration {
    final String text;

    OnTapPageConfiguration(this.text);

    @override
    Widget createPage() {
        return OnTapPage(this);
    }

    @override
    List<Object> get props => [text];

    @override
    String get route => '/myPage';
}

class MyPage extends StatelessPage<MyPageConfiguration> {
    MyPage(MyPageConfiguration configuration) : super(configuration);

    @override
    build(BuildContext context) {
        return Center(child:
            Text(configuration.text),
        );
    }
}

...

MaterialApp(
    navigatorKey: NavigationService.navigatorKey,
    onGenerateRoute: (settings) => NavigationService.getRoute(settings),
    ...
);

...

final pageConfiguration = MyPageConfiguration("My text");
NavigationService.navigateTo(pageConfiguration);
```