import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';

typedef SequenceMetaPair = Tuple2<File, File>; 

class CreateCustomSequencesViewModel extends ChangeNotifier {
  String? selectedFolderPath;
  List<Tuple2<File, File>> sequenceMetaPairs = [];
  bool isProcessing = false;

  void reset() {
    selectedFolderPath = null;
    sequenceMetaPairs = [];
    isProcessing = false;
  }

  Future<void> onSelectFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

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
  final files = Directory(folderPath).listSync(recursive: true);
  final sequenceFiles = files.where((file) => file.path.endsWith('.seq')).toList();

  final sequenceMetaPairs = <Tuple2<File, File>>[];
  for (final sequenceFile in sequenceFiles) {
    final sequenceFileName = sequenceFile.path.split(Platform.pathSeparator).last;
    final sequenceFileNameWithoutExtension = p.basenameWithoutExtension(sequenceFileName);
    final metaFile = File(p.join(sequenceFile.parent.path, '$sequenceFileNameWithoutExtension.meta'));
    if(!metaFile.existsSync()) {
      log('Meta file not found for sequence file: $sequenceFileName! Skipping.', level: LogLevel.error);
      continue;
    }
    sequenceMetaPairs.add(Tuple2(sequenceFile as File, metaFile));
  }

  return sequenceMetaPairs;
}
