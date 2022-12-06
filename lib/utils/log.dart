import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

log(dynamic output, { LogLevel level = LogLevel.debug }) {
  if (kDebugMode) {
    print("[${level.toString().split(".").last}] $output");
  }
}