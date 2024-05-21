// SPDX-FileCopyrightText: Copyright 2024 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Keys form demo
enum ValueKeys { string, int, double, bool, list }

/// Main features of the plugin shared_preferences
class PluginImpl {
  /// Get instance shared preferences
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Stream for update values SharedPreferences
  /// from form
  StreamController<bool>? _streamController;

  /// Check save data to shared preferences
  /// All field required check fist key
  Stream<bool> isEmptyStream() {
    if (_streamController == null) {
      _streamController = StreamController<bool>(
          onListen: () async =>
              _streamController!.add((await getValue(ValueKeys.int)) == null));
    }
    return _streamController!.stream;
  }

  /// Get value from shared preferences
  Future<dynamic> getValue(ValueKeys key) async {
    switch (key) {
      case ValueKeys.int:
        return (await _prefs).getInt(key.name);
      case ValueKeys.bool:
        return (await _prefs).getBool(key.name);
      case ValueKeys.double:
        return (await _prefs).getDouble(key.name);
      case ValueKeys.string:
        return (await _prefs).getString(key.name);
      case ValueKeys.list:
        return (await _prefs).getStringList(key.name);
    }
  }

  /// Set value from shared preferences
  Future<void> setValue(ValueKeys key, dynamic value) async {
    switch (key) {
      case ValueKeys.int:
        (await _prefs).setInt(key.name, value);
      case ValueKeys.bool:
        (await _prefs).setBool(key.name, value);
      case ValueKeys.double:
        (await _prefs).setDouble(key.name, value);
      case ValueKeys.string:
        (await _prefs).setString(key.name, value);
      case ValueKeys.list:
        (await _prefs).setStringList(key.name, value);
    }
    // After save date SharedPreferences not empty
    _streamController!.add(false);
  }

  /// Clear all data
  Future<void> clear() async {
    await (await _prefs).clear();
    // After clear date SharedPreferences is empty
    _streamController!.add(true);
  }
}
