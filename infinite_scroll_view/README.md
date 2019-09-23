# infinite_scroll_view

This package is designed to simplify the boilerplate required to create an infinite list view. The idea is that the user can scroll down a seemingly-neverending list. This package allows for some customisation.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
infinite_scroll_view:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: infinite_scroll_view
    ref: InfiniteScrollView-v0.0.1 # Use the latest InfiniteScrollView tag!!
```

### Constructor Arguments

- `builder` - This is the builder for each list item in the list view. It is designed in the same way as a `ListView`'s builder is used.
- `itemCount` - The total number of items expected to build in the current instance of the list. This number is expected to change as the user scrolls down the list.
- `onReachedEndCallback` - The function that is called when the user has scrolled to the bottom.
- `endOfScrollOffset` - [Optional] An offset to trigger the `onReachedEndCallback`. By default, this is set to 100 pixels, such that the `onReachedEndCallback` is triggered once the user has reached 100 pixels before the end of the list.
- `scrollController` - [Optional] The controller to add event listeners and drag detection to the scroll view.
- `separator` - [Optional] The widget used to separate items.
- `padding` - [Optional] The padding widget used to add some space around the list.

### Example Use

```dart
InfiniteScrollView(
    onReachedEndCallback: _handleInfiniteScroll,
    // Add 1 to the itemCount to add a loading indicator at the bottom.
    itemCount: state.listItems.length + 1,
    builder: (context, index) {
        if (index < state.listItems.length) {
            return MyItem(post: state.listItem[index]);
        } else {
            // Show loading indicator for loading more items, just in case user-scrolls faster than more items are retrieved.
            return const CircularProgressIndicator();
        }
    },
),
```