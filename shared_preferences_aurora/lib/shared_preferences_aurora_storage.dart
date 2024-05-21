// SPDX-FileCopyrightText: Copyright 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class SharedPreferencesAuroraStorage {
  Future<Map<String, dynamic>> read();

  Future<void> save(Map<String, dynamic> data);
}

class SharedPreferencesAuroraStorageFile
    implements SharedPreferencesAuroraStorage {
  final JsonDecoder decoder = const JsonDecoder();
  final String fileName;

  SharedPreferencesAuroraStorageFile(this.fileName);

  /// Get file with data
  Future<File> _getFile() async {
    return File(p.join(
      (await getApplicationSupportDirectory()).path,
      fileName,
    )).create(recursive: true);
  }

  @override
  Future<Map<String, dynamic>> read() async {
    final file = await _getFile();
    final value = await file.readAsString();
    return value.isEmpty ? {} : decoder.convert(value);
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    final file = await _getFile();
    final value = json.encode(data);
    await file.writeAsString(value);
  }
}
