import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_bindings_generated.dart';
import 'package:retro/utils/log.dart';

class InspectOTRViewModel extends ChangeNotifier {
  String? selectedOTRPath;
  List<String> filesInOTR = [];
  List<String> filteredFilesInOTR = [];
  bool isProcessing = false;

  reset() {
    selectedOTRPath = null;
    filesInOTR = [];
    filteredFilesInOTR = [];
    isProcessing = false;
  }

  Future<void> onSelectOTR() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['otr']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      isProcessing = true;
      notifyListeners();
      final list = await compute(listOTRItems, selectedOTRPath!);
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

Future<List<String>?> listOTRItems(String path) async {
  try {
    var fileFound = false;
    final files = <String>[];

    final mpqArchive = MPQArchive.open(path, 0, MPQ_OPEN_READ_ONLY);
    final hFind = FileFindResource();
    mpqArchive.findFirstFile('*', hFind, null);

    final fileName = hFind.fileName();
    if (fileName != null && fileName != '(signature)' && fileName != '(listfile)' && fileName != '(attributes)') {
      files.add(fileName);
    }

    do {
      try {
        mpqArchive.findNextFile(hFind);
        fileFound = true;
        final fileName = hFind.fileName();
        log('File name: $fileName');
        if (fileName != null && fileName != '(signature)' && fileName != '(listfile)' && fileName != '(attributes)') {
          files.add(fileName);
        }
      } on StormLibException catch (e) {
        log('Failed to find next file: ${e.message}');
        fileFound = false;
      }
    } while (fileFound);

    hFind.close();
    mpqArchive.close();
    return files;
  } on StormLibException catch (e) {
    log('Failed to set locale: ${e.message}');
    return null;
  }
}
