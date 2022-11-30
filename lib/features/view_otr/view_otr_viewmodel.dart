import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:flutter_storm/flutter_storm.dart';

class ViewOTRViewModel extends ChangeNotifier {
  String? selectedOTRPath;
  String? openedOTRHandle;

  onSelectOTR() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['otr']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      openedOTRHandle = await SFileOpenArchive(selectedOTRPath!, MPQ_OPEN_READ_ONLY);

      listOTRItems();
      notifyListeners();
    }
  }

  listOTRItems() {
    if (openedOTRHandle == null) {
      // TODO: Handle this error
      return;
    }
  }
}
