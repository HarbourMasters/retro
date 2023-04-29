import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

class CreateCustomViewModel extends ChangeNotifier {
  List<File> files = [];
  String path = "";

  onSelectedFiles(List<File> files) {
    this.files = files;
    notifyListeners();
  }

  onDiscardFiles() {
    files = [];
    notifyListeners();
  }

  onSelectedDirectory(String path) {
    this.path = path;
    notifyListeners();
  }

  onSelectFiles() async {
    String? selectedBaseDirectoryPath = await FilePicker.platform.getDirectoryPath();
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   allowMultiple: true, type: FileType.any
    // );
    onSelectedDirectory(selectedBaseDirectoryPath ?? "");
    if (selectedBaseDirectoryPath != null) {
      var directory = Directory(selectedBaseDirectoryPath);
      var dirList = directory.list(recursive: true).where((fsEntry) => fsEntry is File);
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
