import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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
  HashMap<String, String> processedFiles = HashMap();

  reset() {
    currentStep = CreateReplacementTexturesStep.question;
    selectedFolderPath = null;
    selectedOTRPath = null;
    isProcessing = false;
    processedFiles = HashMap();
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
      HashMap<String, String> processedFiles = HashMap();
      notifyListeners();

      // if folder we'll export to exists, delete it
      String otrName = selectedOTRPath!.split(Platform.pathSeparator).last.split(".").first;
      Directory dir = Directory("$selectedDirectory/$otrName");
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

            if(!texture.isValid){
              continue;
            }

            print("Found texture: $fileName! with type: ${texture.textureType} and size: ${texture.width}x${texture.height}");

            // Write to disk using the same path we found it in
            String? textureOutputPath = "$selectedDirectory/$otrName/$fileName.png";
            File textureFile = File(textureOutputPath);
            textureFile.createSync(recursive: true);
            Uint8List pngBytes = texture.toPNGBytes();
            textureFile.writeAsBytesSync(pngBytes);

            // Track file path and hash
            String fileHash = sha256.convert(fileData).toString();
            processedFiles[fileName] = fileHash;
          } catch (e) { /* Not a texture */ }
        } on StormException catch (e) {
          fileFound = false;
        }
      } while (fileFound);

      // Write out the processed files to disk
      String? manifestOutputPath = "$selectedDirectory/$otrName/manifest.json";
      File manifestFile = File(manifestOutputPath);
      manifestFile.createSync(recursive: true);
      String dataToWrite = jsonEncode(processedFiles);
      manifestFile.writeAsStringSync(dataToWrite);

      SFileFindClose(hFind!);
      isProcessing = false;
      this.processedFiles = processedFiles;
      notifyListeners();
    } on StormException catch (e) {
      print("Failed to find next file: ${e.message}");
    }

    // TOOD: Walk OTR and write PNs to disk at right pa
  }
}
