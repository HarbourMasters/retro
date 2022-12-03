import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/bridge/errors.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:retro/otr/types/texture.dart' as soh;

enum CreateReplacementTexturesStep { question, selectFolder, selectOTR }

class CreateReplaceTexturesViewModel extends ChangeNotifier {
  CreateReplacementTexturesStep currentStep = CreateReplacementTexturesStep.question;
  String? selectedFolderPath;
  String? selectedOTRPath;
  bool isProcessing = false;
  List<String> processedFiles = [];

  reset() {
    currentStep = CreateReplacementTexturesStep.question;
    selectedFolderPath = null;
    selectedOTRPath = null;
    isProcessing = false;
    processedFiles = [];
    notifyListeners();
  }

  onUpdateStep(CreateReplacementTexturesStep step) {
    currentStep = step;
    notifyListeners();
  }

  onSelectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = selectedDirectory;
      notifyListeners();
    }
  }

  processFolder() async {
    isProcessing = true;
    notifyListeners();

    // TODO: Walk folder check if file has changed and send to creation view model.
  }

  onSelectOTR() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['otr']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      notifyListeners();
    }
  }

  processOTR() async {
    if (selectedOTRPath == null) {
      // TODO: Handle this error
      return;
    }

    // Ask for output folder
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    try {
      String? otrHandle = await SFileOpenArchive(selectedOTRPath!, MPQ_OPEN_READ_ONLY);
      String? findData = await SFileFindCreateDataPointer();
      String? hFind = await SFileFindFirstFile(otrHandle!, "*", findData!);

      bool fileFound = false;
      isProcessing = true;
      List<String> files = [];
      notifyListeners();


      // if folder we'll export to exists, delete it
      String otrNameWithoutExtension = selectedOTRPath!.split("/").last.split(".").first;
      Directory dir = Directory("$selectedDirectory/$otrNameWithoutExtension");
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }

      do {
        try {
          await SFileFindNextFile(hFind!, findData);
          fileFound = true;

          String? fileName = await SFileFindGetDataForDataPointer(findData);
          if (fileName == null || fileName == "(signature)") {
            continue;
          }

          String? fileHandle = await SFileOpenFileEx(otrHandle, fileName!, 0);
          int? fileSize = await SFileGetFileSize(fileHandle!);
          Uint8List? fileData = await SFileReadFile(fileHandle, fileSize!);

          try {
            soh.Texture texture = soh.Texture.empty();
            texture.open(fileData!);
            print("Found texture: $fileName! with type: ${texture.textureType}");
            print("Width: ${texture.width} Height: ${texture.height}");

            // // Write to disk using the same path we found it in
            String? filePath = "$selectedDirectory/$otrNameWithoutExtension/$fileName.png";
            print("Writing to: $filePath");

            File file = File(filePath);
            file.createSync(recursive: true);
            file.writeAsBytesSync(texture.toPNGBytes());
            files.add(filePath);
          } catch (e) { /* Not a texture */ }
        } on StormException catch (e) {
          fileFound = false;
        }
      } while (fileFound);

      SFileFindClose(hFind!);
      isProcessing = false;
      processedFiles = files;
      notifyListeners();
    } on StormException catch (e) {
      print("Failed to find next file: ${e.message}");
    }

    // TOOD: Walk OTR and write PNs to disk at right pa
  }
}
