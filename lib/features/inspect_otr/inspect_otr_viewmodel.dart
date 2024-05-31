import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:retro/arc/arc.dart';

class InspectOTRViewModel extends ChangeNotifier {
  String? selectedOTRPath;
  List<String> filesInOTR = [];
  List<String> filteredFilesInOTR = [];
  bool isProcessing = false;

  void reset() {
    selectedOTRPath = null;
    filesInOTR = [];
    filteredFilesInOTR = [];
    isProcessing = false;
  }

  Future<void> onSelectOTR() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['otr', 'o2r']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      isProcessing = true;
      notifyListeners();
      final list = await compute(listFileItems, selectedOTRPath!);
      if (list != null) {
        filesInOTR = list;
        filteredFilesInOTR = list;
      }

      isProcessing = false;
      notifyListeners();
    }
  }

  onSearch(String query) {
    filteredFilesInOTR = filesInOTR
      .where((element) => element.toLowerCase().contains(query.toLowerCase()))
      .toList();
    notifyListeners();
  }
}

Future<List<String>?> listFileItems(String path) async {
  final arcFile = Arc(path);
  final files = arcFile.listItems();
  arcFile.close();
  return files;
}
