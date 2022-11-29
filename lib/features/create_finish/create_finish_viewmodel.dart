import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';

enum AppState { none, creation, creationFinalization }

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, List<File>> files = HashMap();
  late BuildContext context;
  bool isFormValid = false;

  void bindGlobalContext(BuildContext ctx) {
    context = ctx;
  }

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

  void onRemoveFile(File file, String path) {
    files[path]!.remove(file);
    if (files[path]!.isEmpty) {
      files.remove(path);
    }
    
    notifyListeners();
  }

  void onOTRNameChanged(String name) {
    isFormValid = name.isNotEmpty;
    notifyListeners();
  }

  void onGenerateOTR() {

  }
}
