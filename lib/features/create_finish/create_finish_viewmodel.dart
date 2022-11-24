import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

enum AppState {
  none,
  creation,
}

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, List<File>> files = HashMap();

  void onCreationState() {
    currentState = AppState.creation;
    notifyListeners();
  }

  void onStageFiles(List<File> files, String path) {
    this.files[path] = files;
    notifyListeners();
  }
}
