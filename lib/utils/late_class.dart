import 'dart:async';
import 'package:flutter/foundation.dart';

class Late<T> {
  final ValueNotifier<bool> _initialization = ValueNotifier(false);
  late T _val;
  
  Late([T? value]) {
    if (value != null) {
      val = value;
    }
  }

  get isInitialized {
    return _initialization.value;
  }

  T get val => _val;

  set val(T val) => this
    .._initialization.value = true
    .._val = val;
}

extension LateExtension<T> on T {
  Late<T> get late => Late<T>();
}

extension ExtLate on Late {
  Future<bool> get wait {
    Completer<bool> completer = Completer();
    _initialization.addListener(() async {
      completer.complete(_initialization.value);
    });

    return completer.future;
  }
}