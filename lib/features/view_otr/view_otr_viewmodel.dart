import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ViewOTRViewModel extends ChangeNotifier {
  String? selectedOTRPath;

  onSelectOTR() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.custom, allowedExtensions: ['otr']
    );
    if (result != null) {
      selectedOTRPath = result.paths.first;
      notifyListeners();
    }
  }
}
