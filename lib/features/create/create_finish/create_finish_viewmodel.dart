import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storm/bridge/errors.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/types/sequence.dart';
import 'package:retro/models/app_state.dart';
import 'package:retro/models/stage_entry.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/otr/types/texture.dart' as soh;

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

  onAddCustomTextureEntry(HashMap<String, List<Tuple2<File, TextureManifestEntry>>> replacementMap) {
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
      mpqOut.deleteSync();
    }

    try {
      String? mpqHandle = await SFileCreateArchive(
          outputFile, MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V4, 4096);

      isGenerating = true;
      notifyListeners();

      for (var entry in entries.entries) {
        if (entry.value is CustomStageEntry) {
          for (var file in (entry.value as CustomStageEntry).files) {
            String fileName = "${entry.key}/${file.path.split("/").last}";
            String? fileHandle = await SFileCreateFile(mpqHandle!, fileName, file.lengthSync(), MPQ_FILE_COMPRESS);
            await SFileWriteFile(fileHandle!, file.readAsBytesSync(), file.lengthSync(), MPQ_COMPRESSION_ZLIB);
            await SFileFinishFile(fileHandle);
          }
        } else if (entry.value is CustomSequencesEntry) {
          for (var pair in (entry.value as CustomSequencesEntry).pairs) {
            Sequence sequence = Sequence.fromSeqFile(pair);
            String fileName = "${entry.key}/${sequence.path}";
            Uint8List data = sequence.build();

            if((await SFileHasFile(mpqHandle!, fileName, 0, 0))!){
              continue;
            }

            String? fileHandle = await SFileCreateFile(mpqHandle, fileName, data.length, MPQ_FILE_COMPRESS);
            await SFileWriteFile(fileHandle!, data, data.length, MPQ_COMPRESSION_ZLIB);
            await SFileFinishFile(fileHandle);
          }
        } else if (entry.value is CustomTexturesEntry) {
          for (var pair in (entry.value as CustomTexturesEntry).pairs) {
            log("Processing texture ${pair.item1.path} as ${pair.item2.textureType}");
            // TODO: Write a proper otr file because this is awful

            // soh.Texture texture = soh.Texture.empty(TextureType.RGBA32bpp);
            // bool isHDTexture = pair.item2.textureWidth != texture.width || pair.item2.textureHeight != texture.height;

            // if (isHDTexture) {
            //   log("Texture ${pair.item1.path} is not the same size as the original. Writing it as rgba32.");
            //   texture.setTextureFlags(TextureFlags.LOAD_AS_RAW);
            //   if(!texture.isPalette) {
            //     texture.textureType = TextureType.RGBA32bpp;
            //   }
            // }

            // try {
            //   texture.fromPNGImage(pair.item1.readAsBytesSync());
            // } catch (e) {
            //   log("Failed to convert texture ${pair.item1.path} from PNG. Error: $e");
            //   continue;
            // }

            // if(texture.isPalette && isHDTexture){
            //   texture.changeTextureFormat(TextureType.RGBA32bpp);
            // }

            Uint8List data = pair.item1.readAsBytesSync();
            String fileName = "raw/${entry.key}/${pair.item1.path.split("/").last.split(".").first}";
            String? fileHandle = await SFileCreateFile(mpqHandle!, fileName, data.length, MPQ_FILE_COMPRESS);
            await SFileWriteFile(fileHandle!, data, data.length, MPQ_COMPRESSION_ZLIB);
            await SFileFinishFile(fileHandle);
          }
        }
      }

      await SFileCloseArchive(mpqHandle!);
      isGenerating = false;
      notifyListeners();

      reset();
      onCompletion();
    } on StormException catch (e) {
      log(e.message);
    }
  }
}
