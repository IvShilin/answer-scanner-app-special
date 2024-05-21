// SPDX-FileCopyrightText: Copyright 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'package:flutter/services.dart';
import 'package:shared_preferences_aurora/shared_preferences_aurora_api.dart';
import 'package:shared_preferences_aurora/shared_preferences_aurora_storage.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class SharedPreferencesAurora extends SharedPreferencesStorePlatform {
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesAurora();
  }

  static const String _defaultPrefix = 'flutter.';

  final SharedPreferencesAuroraApi _api = SharedPreferencesAuroraApi(
    SharedPreferencesAuroraStorageFile('.flutter_shared_preferences.json'),
  );

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    switch (valueType) {
      case 'String':
      case 'Bool':
      case 'Int':
      case 'Double':
      case 'StringList':
        return _api.setData(key, value);
    }
    throw PlatformException(
        code: 'InvalidOperation',
        message: '"$valueType" is not a supported type.');
  }

  @override
  Future<bool> remove(String key) async => _api.remove(key);

  @override
  Future<bool> clear() => clearWithPrefix(_defaultPrefix);

  @override
  Future<Map<String, Object>> getAll() => getAllWithPrefix(_defaultPrefix);

  @override
  Future<bool> clearWithPrefix(String prefix) async =>
      _api.clearWithPrefix(prefix);

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) async =>
      (await _api.getAllWithPrefix(prefix)).cast();
}
