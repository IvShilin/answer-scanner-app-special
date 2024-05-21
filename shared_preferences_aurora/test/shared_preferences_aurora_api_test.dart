// SPDX-FileCopyrightText: Copyright 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import "package:flutter_test/flutter_test.dart";
import 'package:shared_preferences_aurora/shared_preferences_aurora_api.dart';
import 'package:shared_preferences_aurora/shared_preferences_aurora_storage.dart';

class SharedPreferencesAuroraStorageMap
    implements SharedPreferencesAuroraStorage {
  Map<String, dynamic> map;

  bool saveError = false;

  SharedPreferencesAuroraStorageMap(this.map);

  @override
  Future<Map<String, dynamic>> read() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return Map.of(map);
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (saveError) throw Exception();
    map = data;
  }
}

void main() {
  test("getAllWithPrefix", () async {
    final storage = SharedPreferencesAuroraStorageMap(
      {
        "key0": 14,
        "key1": "some_value",
        "anth": true,
      },
    );
    final prefs = SharedPreferencesAuroraApi(storage);

    expect(
      await prefs.getAllWithPrefix(""),
      {
        "key0": 14,
        "key1": "some_value",
        "anth": true,
      },
    );

    expect(
      await prefs.getAllWithPrefix("key"),
      {
        "key0": 14,
        "key1": "some_value",
      },
    );
  });

  test("save new key", () async {
    final storage = SharedPreferencesAuroraStorageMap({});
    final prefs = SharedPreferencesAuroraApi(storage);

    await prefs.setData("key1", 42);
    expect(
      await prefs.getAllWithPrefix(""),
      {"key1": 42},
    );

    await prefs.setData("key2", 3.14);
    expect(
      await prefs.getAllWithPrefix(""),
      {"key1": 42, "key2": 3.14},
    );
  });

  test("save existing key", () async {
    final storage = SharedPreferencesAuroraStorageMap(
      {"key1": 42, "key2": 3.14},
    );
    final prefs = SharedPreferencesAuroraApi(storage);

    await prefs.setData("key1", 43);
    expect(
      await prefs.getAllWithPrefix(""),
      {"key1": 43, "key2": 3.14},
    );
  });

  test("remove existing key", () async {
    final storage = SharedPreferencesAuroraStorageMap(
      {"key1": 42, "key2": 3.14},
    );
    final prefs = SharedPreferencesAuroraApi(storage);

    expect(
      await prefs.remove("key1"),
      true,
    );
    expect(
      await prefs.getAllWithPrefix(""),
      {"key2": 3.14},
    );
  });

  test("remove non-existing key", () async {
    final storage = SharedPreferencesAuroraStorageMap(
      {"key1": 42, "key2": 3.14},
    );
    final prefs = SharedPreferencesAuroraApi(storage);

    expect(
      await prefs.remove("anth"),
      false,
    );
    expect(
      await prefs.getAllWithPrefix(""),
      {"key1": 42, "key2": 3.14},
    );
  });

  test("clearWithPrefix", () async {
    final storage = SharedPreferencesAuroraStorageMap(
      {
        "key0": 14,
        "key1": "some_value",
        "anth": true,
      },
    );
    final prefs = SharedPreferencesAuroraApi(storage);

    await prefs.clearWithPrefix("key");
    expect(
      await prefs.getAllWithPrefix(""),
      {"anth": true},
    );
  });

  test("write and read", () async {
    final storage = SharedPreferencesAuroraStorageMap({});
    final prefs = SharedPreferencesAuroraApi(storage);

    await prefs.setData("key1", 42);
    final all = await prefs.getAllWithPrefix("");
    expect(all, {"key1": 42});
  });

  test("multiple writes and read", () async {
    final storage = SharedPreferencesAuroraStorageMap({});
    final prefs = SharedPreferencesAuroraApi(storage);

    await Future.wait([
      prefs.setData("key1", 42),
      prefs.setData("key2", 43),
      prefs.setData("key3", 44),
    ]);
    final all = await prefs.getAllWithPrefix("");
    expect(all, {"key1": 42, "key2": 43, "key3": 44});
  });

  test("save error", () async {
    final storage = SharedPreferencesAuroraStorageMap({});
    final prefs = SharedPreferencesAuroraApi(storage);

    storage.saveError = true;
    await prefs.setData("key1", 42).onError((error, stackTrace) => false);
    expect(
      await prefs.getAllWithPrefix(""),
      {},
    );

    storage.saveError = false;
    await prefs.setData("key2", 3.14);
    expect(
      await prefs.getAllWithPrefix(""),
      {"key2": 3.14},
    );
  });
}
