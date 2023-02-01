import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:path/path.dart' as p;

typedef SequenceMetaPair = Tuple2<File, File>; 

class CreateCustomSequencesViewModel extends ChangeNotifier {
  String? selectedFolderPath;
  List<Tuple2<File, File>> sequenceMetaPairs = [];
  bool isProcessing = false;

  reset() {
    selectedFolderPath = null;
    sequenceMetaPairs = [];
    isProcessing = false;
  }

  onSelectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = selectedDirectory;
      isProcessing = true;
      notifyListeners();

      sequenceMetaPairs = await compute(listSequenceMetaPairs, selectedFolderPath!);
      isProcessing = false;
      notifyListeners();
    }
  }
}

List<SequenceMetaPair> listSequenceMetaPairs(String folderPath) {
  List<FileSystemEntity> files = Directory(folderPath).listSync(recursive: true);
  List<FileSystemEntity> sequenceFiles = files.where((file) => file.path.endsWith('.seq')).toList();

  List<Tuple2<File, File>> sequenceMetaPairs = [];
  for (FileSystemEntity sequenceFile in sequenceFiles) {
    String sequenceFileName = sequenceFile.path.split(Platform.pathSeparator).last;
    String sequenceFileNameWithoutExtension = p.basenameWithoutExtension(sequenceFileName);
    File metaFile = File(p.join(sequenceFile.parent.path, '$sequenceFileNameWithoutExtension.meta'));
    if(!metaFile.existsSync()) {
      log('Meta file not found for sequence file: $sequenceFileName! Skipping.', level: LogLevel.error);
      continue;
    }
    sequenceMetaPairs.add(Tuple2(sequenceFile as File, metaFile));
  }

  return sequenceMetaPairs;
}
