import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:retro/models/stage_entry.dart';
import 'package:tuple/tuple.dart';

enum AppState { none, creation, creationFinalization, inspection }

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, StageEntry> entries = HashMap();
  late BuildContext context;
  bool isGenerating = false;

  void bindGlobalContext(BuildContext ctx) {
    context = ctx;
  }

  // State Management
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
    bool hasStagedFiles = entries.isNotEmpty;
    return "${currentState.name}${hasStagedFiles && currentState != AppState.creationFinalization ? ' (staged)' : ''}";
  }

  // Stage Management
  void onAddCustomStageEntry(List<File> files, String path) {
    if (entries.containsKey(path) && entries[path] is CustomStageEntry) {
      (entries[path] as CustomStageEntry).files.addAll(files);
    } else if (entries.containsKey(path)) {
      throw Exception("Cannot add custom stage entry to existing entry");
    } else {
      entries[path] = CustomStageEntry(files);
    }

    notifyListeners();
  }

  void onAddCustomSequenceEntry(List<Tuple2<File, File>> pairs, String path) {
    if (entries.containsKey(path) && entries[path] is CustomSequencesEntry) {
      (entries[path] as CustomSequencesEntry).pairs.addAll(pairs);
    } else if (entries.containsKey(path)) {
      throw Exception("Cannot add custom sequence entry to existing entry");
    } else {
      entries[path] = CustomSequencesEntry(pairs);
    }

    notifyListeners();
  }

  void onRemoveFile(File file, String path) {
    if (entries.containsKey(path) && entries[path] is CustomStageEntry) {
      (entries[path] as CustomStageEntry).files.remove(file);
    } else if (entries.containsKey(path) &&
        entries[path] is CustomSequencesEntry) {
      (entries[path] as CustomSequencesEntry).pairs.removeWhere((pair) =>
          pair.item1.path == file.path || pair.item2.path == file.path);
    } else {
      throw Exception("Cannot remove file from non-existent entry");
    }

    if (entries[path]?.iterables.isEmpty == true) {
      entries.remove(path);
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

    for (var entry in entries.entries) {
      if (entry.value is CustomStageEntry) {
        for (var file in (entry.value as CustomStageEntry).files) {
          String fileName = "${entry.key}/${file.path.split('/').last}";
          String? fileHandle = await SFileCreateFile(
              mpqHandle, fileName, file.lengthSync(), MPQ_FILE_COMPRESS);
          await SFileWriteFile(fileHandle!, file.readAsBytesSync(),
              file.lengthSync(), MPQ_COMPRESSION_ZLIB);
          await SFileFinishFile(fileHandle);
        }
      } else if (entry.value is CustomSequencesEntry) {
        for (var pair in (entry.value as CustomSequencesEntry).pairs) {
          // TODO: Handle sequences
        }
      }
    }

    await SFileCloseArchive(mpqHandle);
    isGenerating = false;
    notifyListeners();
  }
}
