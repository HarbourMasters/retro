import 'dart:io';

/// Normalizes a path by unifying OS path separators.
String normalize(String path) {
  return path.replaceAll(Platform.pathSeparator, '/');
}