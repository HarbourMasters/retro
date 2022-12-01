import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/bridge/flags.dart';

enum AppState { none, creation, creationFinalization, inspection }

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, List<File>> files = HashMap();
  late BuildContext context;
  bool isGenerating = false;

  void bindGlobalContext(BuildContext ctx) {
    context = ctx;
  }

  void onCreationState() {
    currentState = AppState.creation;
    notifyListeners();
  }

  void onInspectState() {
    currentState = AppState.inspection;
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

  void onGenerateOTR() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'generated.otr',
    );

    if (outputFile == null) {
      return;
    }

    String? mpqHandle = await SFileCreateArchive(
        outputFile, MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4, 1024);

    if (mpqHandle == null) {
      // TODO: Show some kind of error
      return;
    }

    isGenerating = true;
    notifyListeners();
    // iterate over files and add them to the archive
    for (String path in files.keys) {
      List<File> files = this.files[path]!;
      for (var file in files) {
        String fileName = "$path/${file.path.split('/').last}";
        String? fileHandle = await SFileCreateFile(
            mpqHandle, fileName, file.lengthSync(), MPQ_FILE_COMPRESS);
        await SFileWriteFile(fileHandle!, file.readAsBytesSync(),
            file.lengthSync(), MPQ_COMPRESSION_ZLIB);
        await SFileFinishFile(fileHandle);
      }
    }

    await SFileCloseArchive(mpqHandle);
    isGenerating = false;
    notifyListeners();
  }
}
