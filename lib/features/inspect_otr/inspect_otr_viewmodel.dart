import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/bridge/errors.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:flutter_storm/flutter_storm.dart';

class InspectOTRViewModel extends ChangeNotifier {
  String? selectedOTRPath;
  List<String> filesInOTR = [];
  bool isProcessing = false;

  resetState() {
    selectedOTRPath = null;
    filesInOTR = [];
    isProcessing = false;
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

      listOTRItems();
      notifyListeners();
    }
  }

  listOTRItems() async {
    if (selectedOTRPath == null) {
      // TODO: Handle this error
      return;
    }

    String? otrHandle =
        await SFileOpenArchive(selectedOTRPath!, MPQ_OPEN_READ_ONLY);
    if (otrHandle == null) {
      // TODO: Handle this error
      return;
    }

    String? findData = await SFileFindCreateDataPointer();
    if (findData == null) {
      print("Failed to create find data");
      return;
    }

    String? hFind = await SFileFindFirstFile(otrHandle, "*", findData);
    if (hFind == null) {
      print("Failed to find first file");
      return;
    }

    bool fileFound = false;
    List<String> files = [];
    isProcessing = true;
    notifyListeners();

    do {
      try {
        await SFileFindNextFile(hFind, findData);
        String? fileName = await SFileFindGetDataForDataPointer(findData);
        if (fileName != null && fileName != "(signature)") {
          files.add(fileName);
        }
      } on StormException catch (e) {
        print("Failed to find next file: ${e.message}");
      }
    } while (fileFound);

    SFileFindClose(hFind);
    filesInOTR = files;
    isProcessing = false;
    notifyListeners();
  }
}
