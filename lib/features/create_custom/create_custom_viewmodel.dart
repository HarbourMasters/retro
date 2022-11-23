import 'dart:io';

import 'package:flutter/material.dart';

class CreateCustomViewModel extends ChangeNotifier {
  List<File> files = [];

  onSelectedFiles(List<File> files) {
    this.files = files;
    files.forEach((file) => print(file.path));
    notifyListeners();
  }

  onDiscardFiles() {
    files = [];
    notifyListeners();
  }
}
