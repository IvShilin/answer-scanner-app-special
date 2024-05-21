// SPDX-FileCopyrightText: Copyright 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:async';

class Mutex {
  Future<dynamic> _prev = Future<dynamic>.value(null);

  Future<T> withMutex<T>(FutureOr<T> Function() action) {
    final completer = Completer<T>();
    _prev
        .onError((error, stackTrace) => null)
        .whenComplete(() => completer.complete(action()));
    _prev = completer.future;
    return completer.future;
  }
}
