import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateCustomViewModel extends ChangeNotifier {
  List<File> files = [];
  String path = "";

  reset() {
    files = [];
    path = "";
  }

  onSelectedFiles(List<File> files) {
    this.files = files;
    notifyListeners();
  }

  onSelectedDirectory(String path) {
    this.path = path;
    notifyListeners();
  }

  onSelectFiles() async {
    String? selectedBaseDirectoryPath =
        await FilePicker.platform.getDirectoryPath();
    onSelectedDirectory(selectedBaseDirectoryPath ?? "");
    if (selectedBaseDirectoryPath != null) {
      var directory = Directory(selectedBaseDirectoryPath);
      var dirList =
          directory.list(recursive: true).where((fsEntry) => fsEntry is File);
      List<File> selectedFileList = [];
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
