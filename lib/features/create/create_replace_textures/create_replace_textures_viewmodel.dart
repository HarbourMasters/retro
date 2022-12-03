import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateReplaceTexturesViewModel extends ChangeNotifier {
  String? selectedFolderPath;
  
  onSelectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = selectedDirectory;
      notifyListeners();
    }
  }
}
