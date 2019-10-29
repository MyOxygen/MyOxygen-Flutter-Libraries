# store

A wrapper around the [SharedPreferences library](https://pub.dev/packages/shared_preferences). This is to allow for easier mocking. 

## Tests

`SharedPreferences` relies on platform channels to access [SharedPreferences](https://developer.android.com/reference/android/content/SharedPreferences) on Android and [UserDefaults](https://developer.apple.com/documentation/foundation/nsuserdefaults?language=objc) on iOS. This means that it can't be tested in unit tests, because it requires a device. The tests verify that the correct methods are called, but cannot verify that the 3rd party SharedPreferences library is working as intended.