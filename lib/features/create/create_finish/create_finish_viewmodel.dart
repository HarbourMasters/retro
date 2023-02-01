import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_bindings_generated.dart';
import 'package:retro/otr/types/sequence.dart';
import 'package:retro/models/app_state.dart';
import 'package:retro/models/stage_entry.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/otr/types/texture.dart' as soh;
import 'package:retro/utils/path.dart' as p;

class CreateFinishViewModel with ChangeNotifier {
  AppState currentState = AppState.none;
  HashMap<String, StageEntry> entries = HashMap();
  late BuildContext context;
  bool isEphemeralBarExpanded = false;
  bool isGenerating = false;

  void bindGlobalContext(BuildContext ctx) {
    context = ctx;
  }

  String displayState() {
    bool hasStagedFiles = entries.isNotEmpty;
    return "${currentState.name}${hasStagedFiles && currentState != AppState.changesStaged ? ' (staged)' : ''}";
  }

  void toggleEphemeralBar() {
    isEphemeralBarExpanded = !isEphemeralBarExpanded;
    notifyListeners();
  }

  void reset() {
    currentState = AppState.none;
    entries.clear();
    notifyListeners();
  }

  // Stage Management
  void onAddCustomStageEntry(List<File> files, String path) {
    if (entries.containsKey(path) && entries[path] is CustomStageEntry) {
      (entries[path] as CustomStageEntry).files.addAll(files);
    } else if (entries.containsKey(path)) {
      throw Exception("Cannot add custom stage entry to existing entry");
    } else {
      entries[path] = CustomStageEntry(files);
    }

    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onAddCustomSequenceEntry(List<Tuple2<File, File>> pairs, String path) {
    if (entries.containsKey(path) && entries[path] is CustomSequencesEntry) {
      (entries[path] as CustomSequencesEntry).pairs.addAll(pairs);
    } else if (entries.containsKey(path)) {
      throw Exception("Cannot add custom sequence entry to existing entry");
    } else {
      entries[path] = CustomSequencesEntry(pairs);
    }

    currentState = AppState.changesStaged;
    notifyListeners();
  }

  onAddCustomTextureEntry(HashMap<String, List<Tuple2<File, TextureType>>> replacementMap) {
    for (var entry in replacementMap.entries) {
      if (entries.containsKey(entry.key) &&
          entries[entry.key] is CustomTexturesEntry) {
        (entries[entry.key] as CustomTexturesEntry).pairs.addAll(entry.value);
      } else if (entries.containsKey(entry.key)) {
        throw Exception("Cannot add custom texture entry to existing entry");
      } else {
        entries[entry.key] = CustomTexturesEntry(entry.value);
      }
    }

    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onRemoveFile(File file, String path) {
    if (entries.containsKey(path) && entries[path] is CustomStageEntry) {
      (entries[path] as CustomStageEntry).files.remove(file);
    } else if (entries.containsKey(path) &&
        entries[path] is CustomSequencesEntry) {
      (entries[path] as CustomSequencesEntry).pairs.removeWhere((pair) =>
          pair.item1.path == file.path || pair.item2.path == file.path);
    } else if (entries.containsKey(path) &&
        entries[path] is CustomTexturesEntry) {
      (entries[path] as CustomTexturesEntry).pairs.removeWhere((pair) =>
          pair.item1.path == file.path);
    } else {
      throw Exception("Cannot remove file from non-existent entry");
    }

    if (entries[path]?.iterables.isEmpty == true) {
      entries.remove(path);
    }

    if (entries.isEmpty) {
      currentState = AppState.none;
    }

    notifyListeners();
  }

  void onGenerateOTR(Function onCompletion) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'generated.otr',
    );

    if (outputFile == null) {
      return;
    }

    File mpqOut = File(outputFile);
    if (mpqOut.existsSync()) {
      await mpqOut.delete();
    }

    isGenerating = true;
    notifyListeners();
    await compute(generateOTR, Tuple2(entries, outputFile));
    isGenerating = false;
    notifyListeners();

    reset();
    onCompletion();
  }
}

void generateOTR(Tuple2<HashMap<String, StageEntry>, String> params) async {
  try {
    MPQArchive? mpqArchive = MPQArchive.create(params.item2, MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V2, 1024);
    for (var entry in params.item1.entries) {
      if (entry.value is CustomStageEntry) {
        for (var file in (entry.value as CustomStageEntry).files) {
          int fileLength = await file.length();
          Uint8List fileData = await file.readAsBytes();
          String fileName = "${entry.key}/${p.normalize(file.path).split("/").last}";

          CreateFileResource mpqFile = mpqArchive.createFile(fileName, DateTime.now().millisecondsSinceEpoch ~/ 1000, fileLength, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(fileData, fileLength, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
        }
      } else if (entry.value is CustomSequencesEntry) {
        for (var pair in (entry.value as CustomSequencesEntry).pairs) {
          Sequence sequence = await compute(Sequence.fromSeqFile, pair);
          String fileName = "${entry.key}/${sequence.path}";
          Uint8List data = sequence.build();
          CreateFileResource mpqFile = mpqArchive.createFile(fileName, DateTime.now().millisecondsSinceEpoch ~/ 1000, data.length, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(data, data.length, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
        }
      } else if (entry.value is CustomTexturesEntry) {
        List<Tuple2<String, Uint8List?>> textures = await Future.wait((entry.value as CustomTexturesEntry).pairs.map(
          (pair) => compute(processTextureEntry, Tuple2(entry.key, pair))
        ));

        for (var texture in textures) {
          if (texture.item2 == null) {
            continue;
          }

          CreateFileResource mpqFile = mpqArchive.createFile(texture.item1, DateTime.now().millisecondsSinceEpoch ~/ 1000, texture.item2!.length, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(texture.item2!, texture.item2!.length, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
        }
      }
    }

    mpqArchive.close();
  } on StormLibException catch (e) {
    log(e.message);
  }
}

Future<Tuple2<String, Uint8List?>> processTextureEntry(Tuple2<String, Tuple2<File, TextureType>> params) async {
  final pair = params.item2;
  soh.Texture texture = soh.Texture.empty();
  texture.textureType = pair.item2;
  Uint8List pngData = await pair.item1.readAsBytes();
  await compute(texture.fromPNGImage, pngData);

  String fileName = "${params.item1}/${pair.item1.path.split("/").last.split(".").first}";
  if (texture.width > 256 || texture.height > 256) {
    log("Texture ${pair.item1.path} is too large. Maximum dimensions are 256x256. Skipping.");
    return Tuple2(fileName, null);
  }

  return Tuple2(fileName, texture.build());
}
