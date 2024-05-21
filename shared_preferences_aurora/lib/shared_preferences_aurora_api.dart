// SPDX-FileCopyrightText: Copyright 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async';

import 'package:shared_preferences_aurora/shared_preferences_aurora_storage.dart';
import 'package:shared_preferences_aurora/mutex.dart';

class SharedPreferencesAuroraApi {
  final SharedPreferencesAuroraStorage storage;
  final updateStorageMutex = Mutex();

  SharedPreferencesAuroraApi(this.storage);

  /// Remove all data by prefix
  Future<bool> clearWithPrefix(String prefix) async =>
      updateStorageMutex.withMutex(() async {
        final map = await storage.read();
        final filtered = {
          for (final key in map.keys)
            if (!key.startsWith(prefix)) key: map[key]
        };
        await storage.save(filtered);
        return true;
      });

  /// Get all data by prefix
  Future<Map<Object?, Object?>> getAllWithPrefix(String prefix) async =>
      updateStorageMutex.withMutex(() async {
        final map = await storage.read();
        return {
          for (final key in map.keys)
            if (key.startsWith(prefix)) key: map[key]
        };
      });

  /// Remove one value
  Future<bool> remove(String key) async =>
      updateStorageMutex.withMutex(() async {
        final map = await storage.read();
        if (map.containsKey(key)) {
          map.remove(key);
          await storage.save(map);
          return true;
        }
        return false;
      });

  /// Add value and save data
  Future<bool> setData(String key, dynamic value) async =>
      updateStorageMutex.withMutex(() async {
        final map = await storage.read();
        map[key] = value;
        await storage.save(map);
        return true;
      });
}
