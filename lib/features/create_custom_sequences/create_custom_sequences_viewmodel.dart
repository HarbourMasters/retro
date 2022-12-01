import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

class CreateCustomSequencesViewModel extends ChangeNotifier {
  String? selectedFolderPath;
  List<Tuple2<File, File>> sequenceMetaPairs = [];
  bool isProcessing = false;

  resetState() {
    selectedFolderPath = null;
    sequenceMetaPairs = [];
    isProcessing = false;
  }

  onSelectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = selectedDirectory;
      notifyListeners();
      listSequenceMetaPairs();
    }
  }

  listSequenceMetaPairs() {
    if (selectedFolderPath == null) {
      return;
    }

    isProcessing = true;
    notifyListeners();
    List<FileSystemEntity> files = Directory(selectedFolderPath!).listSync(recursive: true);
    List<FileSystemEntity> sequenceFiles = files.where((file) => file.path.endsWith('.seq')).toList();
    List<FileSystemEntity> metaFiles = files.where((file) => file.path.endsWith('.meta')).toList();

    List<Tuple2<File, File>> sequenceMetaPairs = [];
    for (FileSystemEntity sequenceFile in sequenceFiles) {
      String sequenceFileName = sequenceFile.path.split('/').last;
      String sequenceFileNameWithoutExtension = sequenceFileName.split('.').first;
      for (FileSystemEntity metaFile in metaFiles) {
        String metaFileName = metaFile.path.split('/').last;
        String metaFileNameWithoutExtension = metaFileName.split('.').first;
        if (sequenceFileNameWithoutExtension == metaFileNameWithoutExtension) {
          sequenceMetaPairs.add(Tuple2(sequenceFile as File, metaFile as File));
        }
      }
    }

    this.sequenceMetaPairs = sequenceMetaPairs;
    isProcessing = false;
    notifyListeners();
  }
}
