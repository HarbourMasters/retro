import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateCustomViewModel extends ChangeNotifier {
  List<File> files = [];
  bool isPathValid = false;

  onSelectedFiles(List<File> files) {
    this.files = files;
    notifyListeners();
  }

  onDiscardFiles() {
    files = [];
    notifyListeners();
  }

  onPathChanged(String path) {
    isPathValid = path.isNotEmpty;
    notifyListeners();
  }

  onSelectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.any
    );
    if (result != null) {
      onSelectedFiles(result.paths
        .map((path) => File(path!))
        .toList()
      );
    }
  }
}
