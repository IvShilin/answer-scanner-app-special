# shared_preferences_aurora

The Aurora implementation of [`shared_preferences`](https://pub.dev/packages/shared_preferences).

## Usage

This package is not an _endorsed_ implementation of `shared_preferences`.
Therefore, you have to include `path_provider_aurora` alongside `shared_preferences` as dependencies in your `pubspec.yaml` file.

**pubspec.yaml**

```yaml
dependencies:
  shared_preferences: ^2.1.2
  shared_preferences_aurora:
    git:
      url: https://gitlab.com/omprussia/flutter/flutter-plugins.git
      ref: shared_preferences_aurora-0.5.0
      path: packages/shared_preferences/shared_preferences_aurora
```

***.dart**

```dart
import 'package:shared_preferences/shared_preferences.dart';

final SharedPreferences prefs = await SharedPreferences.getInstance();

// Save an integer value to 'counter' key.
await prefs.setInt('counter', 10);
// Save an boolean value to 'repeat' key.
await prefs.setBool('repeat', true);
// Save an double value to 'decimal' key.
await prefs.setDouble('decimal', 1.5);
// Save an String value to 'action' key.
await prefs.setString('action', 'Start');
// Save an list of strings to 'items' key.
await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);

// Try reading data from the 'counter' key. If it doesn't exist, returns null.
final int? counter = prefs.getInt('counter');
// Try reading data from the 'repeat' key. If it doesn't exist, returns null.
final bool? repeat = prefs.getBool('repeat');
// Try reading data from the 'decimal' key. If it doesn't exist, returns null.
final double? decimal = prefs.getDouble('decimal');
// Try reading data from the 'action' key. If it doesn't exist, returns null.
final String? action = prefs.getString('action');
// Try reading data from the 'items' key. If it doesn't exist, returns null.
final List<String>? items = prefs.getStringList('items');
```
