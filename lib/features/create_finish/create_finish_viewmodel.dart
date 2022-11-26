import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

enum AppState { none, creation, creationFinalization }

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, List<File>> files = HashMap();

  void onCreationState() {
    currentState = AppState.creation;
    notifyListeners();
  }

  void onCreationFinalizationState() {
    currentState = AppState.creationFinalization;
    notifyListeners();
  }

  String displayState() {
    bool hasStagedFiles = files.isNotEmpty;
    return "${currentState.name}${hasStagedFiles && currentState != AppState.creationFinalization ? ' (staged)' : ''}";
  }

  void onStageFiles(List<File> files, String path) {
    if (this.files.containsKey(path)) {
      this.files[path]!.addAll(files);
    } else {
      this.files[path] = files;
    }

    notifyListeners();
  }
}
