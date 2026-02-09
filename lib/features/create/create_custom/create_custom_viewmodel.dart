import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateCustomViewModel extends ChangeNotifier {
  List<File> files = [];
  String path = '';

  void reset() {
    files = [];
    path = '';
  }

  void onSelectedFiles(List<File> files) {
    this.files = files;
    notifyListeners();
  }

  void onSelectedDirectory(String path) {
    this.path = path;
    notifyListeners();
  }

  Future<void> onSelectFiles() async {
    final selectedBaseDirectoryPath =
        await FilePicker.platform.getDirectoryPath();
    onSelectedDirectory(selectedBaseDirectoryPath ?? '');
    if (selectedBaseDirectoryPath != null) {
      final directory = Directory(selectedBaseDirectoryPath);
      final dirList =
          directory.list(recursive: true).where((fsEntry) => fsEntry is File);
      final selectedFileList = <File>[];
      await for (final FileSystemEntity fsEntry in dirList) {
        if (fsEntry is File) {
          selectedFileList.add(fsEntry);
        }
      }
      onSelectedFiles(selectedFileList);
    } else {
      onSelectedFiles([]);
    }
  }
}
