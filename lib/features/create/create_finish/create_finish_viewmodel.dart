import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image, Texture;
import 'package:flutter_storm/flutter_storm.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as dartp;
import 'package:retro/arc/arc.dart';
import 'package:retro/models/app_state.dart';
import 'package:retro/models/stage_entry.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/types/sequence.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/async.dart';
import 'package:retro/utils/log.dart';
import 'package:retro/utils/path.dart' as p;
import 'package:tuple/tuple.dart';

class CreateFinishViewModel with ChangeNotifier {
  late BuildContext context;
  AppState currentState = AppState.none;
  HashMap<String, StageEntry> entries = HashMap();
  bool isEphemeralBarExpanded = false;
  bool isGenerating = false;
  bool prependAlt = false;
  bool compressFiles = false;
  int totalFiles = 0;
  int filesProcessed = 0;

  String displayState() {
    final hasStagedFiles = entries.isNotEmpty;
    return "${currentState.name}${hasStagedFiles && currentState != AppState.changesStaged ? ' (staged)' : ''}";
  }

  void toggleEphemeralBar() {
    isEphemeralBarExpanded = !isEphemeralBarExpanded;
    notifyListeners();
  }

  Future<void> onTogglePrependAlt(bool newPrependAltValue) async {
    prependAlt = newPrependAltValue;
    notifyListeners();
  }

  Future<void> onToggleCompressFiles(bool newCompressFilesValue) async {
    compressFiles = newCompressFilesValue;
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
  void onAddCustomStageEntries(List<File> files, String basePath) {
    final Map<String, List<File>> customEntries = HashMap();
    for (final file in files) {
      final posixcontext = dartp.Context(style: dartp.Style.posix);
      final splitEntryPath =
          dartp.split(dartp.relative(file.parent.path, from: basePath));
      final entryPath = posixcontext.joinAll(splitEntryPath);
      if (customEntries[entryPath] == null) {
        customEntries[entryPath] = [];
      }
      customEntries[entryPath]!.add(file);
    }
    for (final entry in customEntries.entries) {
      final entryPath = entry.key;
      final entryFiles = entry.value;
      if (entries.containsKey(entryPath) &&
          entries[entryPath] is CustomStageEntry) {
        (entries[entryPath]! as CustomStageEntry).files.addAll(entryFiles);
      } else if (entries.containsKey(entryPath)) {
        throw Exception('Cannot add custom stage entry to existing entry');
      } else {
        entries[entryPath] = CustomStageEntry(entryFiles);
      }
    }
    totalFiles += files.length;
    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onAddCustomSequenceEntry(List<Tuple2<File, File>> pairs, String path) {
    if (entries.containsKey(path) && entries[path] is CustomSequencesEntry) {
      (entries[path] as CustomSequencesEntry).pairs.addAll(pairs);
    } else if (entries.containsKey(path)) {
      throw Exception('Cannot add custom sequence entry to existing entry');
    } else {
      entries[path] = CustomSequencesEntry(pairs);
    }

    totalFiles += pairs.length;
    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onAddCustomTextureEntry(
    HashMap<String, List<Tuple2<File, TextureManifestEntry>>> replacementMap,
  ) {
    for (final entry in replacementMap.entries) {
      if (entries.containsKey(entry.key) &&
          entries[entry.key] is CustomTexturesEntry) {
        (entries[entry.key]! as CustomTexturesEntry).pairs.addAll(entry.value);
      } else if (entries.containsKey(entry.key)) {
        throw Exception('Cannot add custom texture entry to existing entry');
      } else {
        entries[entry.key] = CustomTexturesEntry(entry.value);
      }
    }

    totalFiles += replacementMap.values.fold<int>(
        0, (previousValue, element) => previousValue + element.length);
    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onAddFile(File file, String path) {
    entries[path] = CustomStageEntry([file]);
    totalFiles++;
    currentState = AppState.changesStaged;
    notifyListeners();
  }

  void onRemoveFile(File file, String path) {
    if (entries.containsKey(path) && entries[path] is CustomStageEntry) {
      (entries[path]! as CustomStageEntry).files.remove(file);
    } else if (entries.containsKey(path) &&
        entries[path] is CustomSequencesEntry) {
      (entries[path]! as CustomSequencesEntry).pairs.removeWhere(
            (pair) =>
                pair.item1.path == file.path || pair.item2.path == file.path,
          );
    } else if (entries.containsKey(path) &&
        entries[path] is CustomTexturesEntry) {
      (entries[path]! as CustomTexturesEntry)
          .pairs
          .removeWhere((pair) => pair.item1.path == file.path);
    } else {
      throw Exception('Cannot remove file from non-existent entry');
    }

    if (entries[path]?.iterables.isEmpty == true) {
      entries.remove(path);
    }

    if (entries.isEmpty) {
      currentState = AppState.none;
    }

    notifyListeners();
  }

  Future<void> onGenerateOTR(Function onCompletion) async {
    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'generated.o2r',
      type: FileType.custom,
      allowedExtensions: ['otr', 'o2r'],
    );

    if (outputFile == null) {
      return;
    }

    final mpqOut = File(outputFile);
    if (mpqOut.existsSync()) {
      await mpqOut.delete();
    }

    isGenerating = true;
    notifyListeners();
    await createGenerationIsolate(entries, outputFile, prependAlt, compressFiles);
    // await compute(generateOTR, Tuple2(entries, outputFile));
    isGenerating = false;
    notifyListeners();

    reset();
    onCompletion();
  }

  Future<void> createGenerationIsolate(HashMap<String, StageEntry> entries,
      String outputFile, bool shouldPrependAlt, bool shouldCompress) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      generateOTR,
      Tuple5(entries, outputFile, receivePort.sendPort, shouldPrependAlt, shouldCompress),
      onExit: receivePort.sendPort,
      onError: receivePort.sendPort,
    );

    await for (final message in receivePort) {
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

Future<void> generateOTR(Tuple5<HashMap<String, StageEntry>, String, SendPort, bool, bool> params) async {
  try {
    final compress = params.item5;
    final arcFile = Arc(params.item2);

    for (final entry in params.item1.entries) {
      if (entry.value is CustomStageEntry) {
        for (final file in (entry.value as CustomStageEntry).files) {
          final fileData = await file.readAsBytes();
          final fileName =
              "${entry.key}/${p.normalize(file.path).split("/").last}";
          arcFile.addFile(fileName, fileData, compress: compress);
          params.item3.send(1);
        }
      } else if (entry.value is CustomSequencesEntry) {
        for (final pair in (entry.value as CustomSequencesEntry).pairs) {
          final sequence = await compute(Sequence.fromSeqFile, pair);
          final fileName = '${entry.key}/${sequence.path}';
          final data = sequence.build();
          arcFile.addFile(fileName, data, compress: compress);
          params.item3.send(1);
        }
      } else if (entry.value is CustomTexturesEntry) {
        final processes = (entry.value as CustomTexturesEntry).pairs.map(
              (pair) => compute(
                  processTextureEntry, Tuple3(entry.key, pair, params.item4)),
            );

        final textures = await FutureExtensions.progressWait(
            processes, () => params.item3.send(1));

        for (final texture in textures) {
          if (texture.item2 == null) {
            params.item3.send('Failed to process texture ${texture.item1}');
            continue;
          }

          arcFile.addFile(texture.item1, texture.item2!, compress: compress);
        }
      }
    }

    params.item3.send(true);
    arcFile.close();
  } on StormLibException catch (e) {
    log(e.message);
  }

  Isolate.exit();
}

Future<Tuple2<String, Uint8List?>> processTextureEntry(
    Tuple3<String, Tuple2<File, TextureManifestEntry>, bool> params) async {
  final pair = params.item2;
  final baseDir = params.item1;
  final isAlt = params.item3;
  final targetPath = pair.item2.targetName;
  final textureName = targetPath != null
      ? dartp.basename(targetPath)
      : dartp.basenameWithoutExtension(pair.item1.path);
  final fileName = targetPath ?? dartp.join(baseDir, textureName);

  final data = await (pair.item2.textureType == TextureType.JPEG32bpp
      ? processJPEG
      : processPNG)(pair, textureName);
  final finalPath = p.normalize(isAlt ? dartp.join('alt', fileName) : fileName);
  return Tuple2(finalPath, data);
}

Future<Uint8List?> processJPEG(Tuple2<File, TextureManifestEntry> pair, String textureName) async {
  final imageData = await pair.item1.readAsBytes();
  final image = decodeJpg(imageData);

  if (image == null) {
    log('Failed to decode image data for JPEG: $textureName');
    return null;
  }

  final texture = Texture.empty();
  texture.textureType = TextureType.RGBA32bpp;
  texture.setTextureFlags(LOAD_AS_RAW);
  final hByteScale = (image.width / pair.item2.textureWidth) *
      (texture.textureType.pixelMultiplier /
          TextureType.RGBA16bpp.pixelMultiplier);
  final vPixelScale = image.height / pair.item2.textureHeight;
  texture.setTextureScale(hByteScale, vPixelScale);
  texture.fromRawImage(image);
  return texture.build();
}

Future<Uint8List?> processPNG(
  Tuple2<File, TextureManifestEntry> pair,
  String textureName,
) async {
  final texture = Texture.empty();
  final entry = pair.item2;
  final imageData = await pair.item1.readAsBytes();
  var image = decodePng(imageData);

  if (image == null) {
    log('Failed to decode image data for PNG: $textureName');
    return null;
  }

  if (entry.kind == TextureEntryKind.additiveFontGlyph) {
    var k = exactMultiple(image, entry.textureWidth, entry.textureHeight);
    if (k == null && entry.tileWidth != null && entry.tileHeight != null) {
      k = exactMultiple(image, entry.tileWidth!, entry.tileHeight!);
    }
    if (k == null) {
      log('Skipping $textureName: ${image.width}x${image.height} is not an '
          'integer multiple of its ${entry.textureWidth}x${entry.textureHeight}'
          ' mask chunk or of its drawn tile');
      return null;
    }
    final alignedWidth = (entry.textureWidth + 3) & ~3;
    image = padCanvas(image, k * alignedWidth, k * entry.textureHeight);
    texture.textureType = TextureType.RGBA32bpp;
    texture.setTextureFlags(LOAD_AS_RAW);
    texture.setTextureScale(k.toDouble(), k.toDouble());
    texture.fromRawImage(image);
    return texture.build();
  }

  if (entry.tileWidth != null &&
      entry.tileHeight != null &&
      exactMultiple(image, entry.textureWidth, entry.textureHeight) == null) {
    final k = exactMultiple(image, entry.tileWidth!, entry.tileHeight!);
    if (k != null) {
      image = padCanvas(
          image, k * entry.textureWidth, k * entry.textureHeight,);
    }
  }

  texture.textureType = entry.textureType;
  texture.isPalette = image.hasPalette && (texture.textureType == TextureType.Palette4bpp || texture.textureType == TextureType.Palette8bpp);

  final isNotOriginalSize = entry.textureWidth != image.width ||
      entry.textureHeight != image.height;
  final isAdditive = entry.kind == TextureEntryKind.additive;
  if (isAdditive) {
    texture.isPalette = false;
  }
  if (isNotOriginalSize || isAdditive) {
    texture.setTextureFlags(LOAD_AS_RAW);
    if (!image.hasPalette || !texture.isPalette) {
      texture.textureType = TextureType.RGBA32bpp;
    }

    final hByteScale = (image.width / entry.textureWidth) *
        (texture.textureType.pixelMultiplier /
            entry.textureType.pixelMultiplier);
    final vPixelScale = image.height / entry.textureHeight;
    texture.setTextureScale(hByteScale, vPixelScale);
  }

  texture.fromRawImage(image);

  if (entry.textureType == TextureType.Palette8bpp ||
      entry.textureType == TextureType.Palette4bpp) {
    if (texture.isPalette) {
      texture.textureType = entry.textureType;
    } else if (!isNotOriginalSize && !isAdditive) {
      print('Skipping $textureName because it is not a palette texture');
      return null;
    }
  } else if (!isAdditive) {
    texture.textureType = entry.textureType;
  }

  return texture.build();
}

int? exactMultiple(Image image, int width, int height) {
  if (width <= 0 || height <= 0) {
    return null;
  }
  if (image.width % width != 0 || image.height % height != 0) {
    return null;
  }
  final k = image.width ~/ width;
  return (k > 0 && image.height ~/ height == k) ? k : null;
}

Image padCanvas(Image image, int width, int height) {
  if (image.width == width && image.height == height) {
    return image;
  }
  final canvas = Image(width: width, height: height, numChannels: 4);
  compositeImage(canvas, image, dstX: 0, dstY: 0, blend: BlendMode.direct);
  return canvas;
}
