import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image hide Texture;
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_defines.dart';
import 'package:image/image.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/types/sequence.dart';
import 'package:retro/models/app_state.dart';
import 'package:retro/models/stage_entry.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/utils/path.dart' as p;
import 'package:retro/utils/async.dart';

class CreateFinishViewModel with ChangeNotifier {
  late BuildContext context;
  AppState currentState = AppState.none;
  HashMap<String, StageEntry> entries = HashMap();
  bool isEphemeralBarExpanded = false;
  bool isGenerating = false;
  int totalFiles = 0;
  int filesProcessed = 0;

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
    totalFiles = 0;
    filesProcessed = 0;
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

    totalFiles += files.length;
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

    totalFiles += pairs.length;
    currentState = AppState.changesStaged;
    notifyListeners();
  }

  onAddCustomTextureEntry(
      HashMap<String, List<Tuple2<File, TextureManifestEntry>>>
          replacementMap) {
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

    totalFiles += replacementMap.values.fold<int>(0, (previousValue, element) => previousValue + element.length);
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
      (entries[path] as CustomTexturesEntry)
          .pairs
          .removeWhere((pair) => pair.item1.path == file.path);
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
    await createGenerationIsolate(entries, outputFile);
    // await compute(generateOTR, Tuple2(entries, outputFile));
    isGenerating = false;
    notifyListeners();

    reset();
    onCompletion();
  }

  Future createGenerationIsolate(HashMap<String, StageEntry> entries, String outputFile) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(
      generateOTR,
      Tuple3(entries, outputFile, receivePort.sendPort),
      onExit: receivePort.sendPort,
      onError: receivePort.sendPort,
    );

    await for (var message in receivePort) {
      if (message is int) {
        filesProcessed = filesProcessed + message;
        notifyListeners();
      } else if (message is String) {
        presentErrorSnackbar(message);
      } else {
        receivePort.close();
        break;
      }
    }
  }

  void presentErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }
}

void generateOTR(Tuple3<HashMap<String, StageEntry>, String, SendPort> params) async {
  try {
    MPQArchive? mpqArchive = MPQArchive.create(params.item2, MPQ_CREATE_SIGNATURE | MPQ_CREATE_ARCHIVE_V2, 12288);
    for (var entry in params.item1.entries) {
      if (entry.value is CustomStageEntry) {
        for (var file in (entry.value as CustomStageEntry).files) {
          int fileLength = await file.length();
          Uint8List fileData = await file.readAsBytes();
          String fileName = "${entry.key}/${p.normalize(file.path).split("/").last}";

          CreateFileResource mpqFile = mpqArchive.createFile(fileName, DateTime.now().millisecondsSinceEpoch ~/ 1000, fileLength, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(fileData, fileLength, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
          params.item3.send(1);
        }
      } else if (entry.value is CustomSequencesEntry) {
        for (var pair in (entry.value as CustomSequencesEntry).pairs) {
          Sequence sequence = await compute(Sequence.fromSeqFile, pair);
          String fileName = "${entry.key}/${sequence.path}";
          Uint8List data = sequence.build();
          CreateFileResource mpqFile = mpqArchive.createFile(fileName, DateTime.now().millisecondsSinceEpoch ~/ 1000, data.length, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(data, data.length, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
          params.item3.send(1);
        }
      } else if (entry.value is CustomTexturesEntry) {
        final processes = (entry.value as CustomTexturesEntry).pairs.map(
          (pair) => compute(processTextureEntry, Tuple2(entry.key, pair))
        );

        List<Tuple2<String, Uint8List?>> textures = await FutureExtensions.progressWait(processes, () =>  params.item3.send(1));

        for (var texture in textures) {
          if (texture.item2 == null) {
            params.item3.send("Failed to process texture ${texture.item1}");
            continue;
          }

          CreateFileResource mpqFile = mpqArchive.createFile(texture.item1, DateTime.now().millisecondsSinceEpoch ~/ 1000, texture.item2!.length, 0, MPQ_FILE_COMPRESS);
          mpqFile.write(texture.item2!, texture.item2!.length, MPQ_COMPRESSION_ZLIB);
          mpqFile.finish();
        }
      }
    }

    params.item3.send(true);
    mpqArchive.close();
  } on StormLibException catch (e) {
    log(e.message);
  }

  Isolate.exit();
}

Future<Tuple2<String, Uint8List?>> processTextureEntry(Tuple2<String, Tuple2<File, TextureManifestEntry>> params) async {
  final pair = params.item2;
  String textureName = pair.item1.path.split("/").last.split(".").first;
  String fileName = "${params.item1}/$textureName";

  Uint8List? data = await (pair.item2.textureType == TextureType.JPEG32bpp ? processJPEG : processPNG)(pair, textureName);
  return Tuple2(fileName, data);
}

Future<Uint8List?> processJPEG(pair, String textureName) async {
  Uint8List imageData = await pair.item1.readAsBytes();
  Image? image = decodeJpg(imageData);

  if (image == null) {
    log("Failed to decode image data for JPEG: $textureName");
    return null;
  }

  Texture texture = Texture.empty();
  texture.textureType = TextureType.RGBA32bpp;
  texture.setTextureFlags(LOAD_AS_RAW);
  double hByteScale = (image.width / pair.item2.textureWidth) * (texture.textureType.pixelMultiplier / TextureType.RGBA16bpp.pixelMultiplier);
  double vPixelScale = (image.height / pair.item2.textureHeight);
  texture.setTextureScale(hByteScale, vPixelScale);
  texture.fromRawImage(image);
  return texture.build();
}

Future<Uint8List?> processPNG(
    Tuple2<File, TextureManifestEntry> pair, String textureName) async {
  Texture texture = Texture.empty();
  Uint8List imageData = await pair.item1.readAsBytes();
  Image? image = decodePng(imageData);

  if (image == null) {
    log("Failed to decode image data for PNG: $textureName");
    return null;
  }

  texture.textureType = pair.item2.textureType;
  texture.isPalette = image.hasPalette && (texture.textureType == TextureType.Palette4bpp || texture.textureType == TextureType.Palette8bpp);

  bool isNotOriginalSize = pair.item2.textureWidth != image.width || pair.item2.textureHeight != image.height;
  if (isNotOriginalSize) {
    texture.setTextureFlags(LOAD_AS_RAW);
    if (!image.hasPalette || !texture.isPalette) {
      texture.textureType = TextureType.RGBA32bpp;
    }

    double hByteScale = (image.width / pair.item2.textureWidth) * (texture.textureType.pixelMultiplier / pair.item2.textureType.pixelMultiplier);
    double vPixelScale = (image.height / pair.item2.textureHeight);
    texture.setTextureScale(hByteScale, vPixelScale);
  }

  texture.fromRawImage(image);

  if (pair.item2.textureType == TextureType.Palette8bpp || pair.item2.textureType == TextureType.Palette4bpp) {
    if (texture.isPalette) {
      texture.textureType = pair.item2.textureType;
    } else if (!isNotOriginalSize){
      print("Skipping $textureName because it is not a palette texture");
      return null;
    }
  } else {
    texture.textureType = pair.item2.textureType;
  }

  return texture.build();
}
