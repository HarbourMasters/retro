import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive.dart' show getCrc32;
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
        final pairs = (entry.value as CustomTexturesEntry).pairs;
        // Bands of one texture become a single archive entry.
        final work = <List<Tuple2<File, TextureManifestEntry>>>[];
        final bands = <String, List<Tuple2<File, TextureManifestEntry>>>{};
        for (final pair in pairs) {
          if (pair.item2.stripIndex == null) {
            work.add([pair]);
          } else {
            bands
                .putIfAbsent(pair.item2.targetName ?? pair.item1.path, () => [])
                .add(pair);
          }
        }
        work.addAll(bands.values);

        // A palette variant ("name@palette") is only drawn at its base's size.
        final targets = {
          for (final group in work) group.first.item2.targetName ?? '': group,
        };
        final baseSizes = <String, Tuple2<int, int>?>{};
        for (final group in work) {
          final target = group.first.item2.targetName ?? '';
          final at = target.indexOf('@');
          final base = at < 0 ? null : targets[target.substring(0, at)];
          if (base == null) {
            continue;
          }
          final size = baseSizes[base.first.item2.targetName!] ??= await packedSize(base);
          for (final pair in group) {
            pair.item2.fitWidth = size?.item1;
            pair.item2.fitHeight = size?.item2;
          }
        }

        // A few at a time; a whole pack of decoded art doesn't fit in memory. Each one
        // is written as it finishes, so a big texture doesn't hold up the others.
        final deflate = compress && arcFile.isZip;
        final inFlight = <Future<void>>{};
        for (final group in work) {
          while (inFlight.length >= Platform.numberOfProcessors) {
            await Future.any(inFlight);
          }
          late final Future<void> job;
          job = compute(
            processTextureDeflated,
            Tuple4(entry.key, group, params.item4, deflate),
          ).then((texture) {
            if (texture.item2 == null) {
              params.item3.send('Failed to process texture ${texture.item1}');
            } else if (deflate) {
              arcFile.addDeflated(texture.item1, texture.item2!, texture.item3, texture.item4);
            } else {
              arcFile.addFile(texture.item1, texture.item2!, compress: compress);
            }
            params.item3.send(1);
          }).whenComplete(() => inFlight.remove(job));
          inFlight.add(job);
        }
        await Future.wait(inFlight);
        // A grouped texture reported one step instead of one per image.
        if (pairs.length > work.length) {
          params.item3.send(pairs.length - work.length);
        }
      }
    }
    arcFile.close();
    params.item3.send(true);
  } on StormLibException catch (e) {
    log(e.message);
  }

  Isolate.exit();
}

// Deflated on the worker with native zlib.
Future<Tuple4<String, Uint8List?, int, int>> processTextureDeflated(
  Tuple4<String, List<Tuple2<File, TextureManifestEntry>>, bool, bool> params,
) async {
  final texture = await processTextureEntry(Tuple3(params.item1, params.item2, params.item3));
  final data = texture.item2;
  if (data == null || !params.item4) {
    return Tuple4(texture.item1, data, 0, 0);
  }
  final deflated = Uint8List.fromList(ZLibEncoder(raw: true).convert(data));
  return Tuple4(texture.item1, deflated, data.length, getCrc32(data));
}

Future<Tuple2<String, Uint8List?>> processTextureEntry(
  Tuple3<String, List<Tuple2<File, TextureManifestEntry>>, bool> params,
) async {
  final group = params.item2;
  final pair = group.first;
  final baseDir = params.item1;
  final isAlt = params.item3;
  final targetPath = pair.item2.targetName;
  final textureName = targetPath != null
      ? dartp.basename(targetPath)
      : dartp.basenameWithoutExtension(pair.item1.path);
  final fileName = targetPath ?? dartp.join(baseDir, textureName);

  final finalPath = p.normalize(isAlt ? dartp.join('alt', fileName) : fileName);
  Uint8List? data;
  try {
    if (pair.item2.stripIndex != null) {
      data = await processBands(group, textureName);
    } else {
      data = await (pair.item2.textureType == TextureType.JPEG32bpp
          ? processJPEG
          : processPNG)(pair, textureName);
    }
  } catch (e) {
    // One image failing shouldn't end the whole archive.
    log('Failed to process $textureName: $e');
  }
  return Tuple2(finalPath, data);
}

// Stack the images that supply a texture's bands. A band nobody supplied is
// left transparent.
Future<Uint8List?> processBands(
  List<Tuple2<File, TextureManifestEntry>> group,
  String textureName,
) async {
  final entry = group.first.item2;
  final strips = entry.strips;
  if (strips == null) {
    return null;
  }

  final supplied = <int, Image>{};
  for (final pair in group) {
    final index = pair.item2.stripIndex;
    if (index == null || index >= strips.length) {
      continue;
    }
    var image = decodePng(await pair.item1.readAsBytes());
    if (image == null) {
      log('Failed to decode band $index of $textureName');
      continue;
    }
    // The canvas is RGBA and bands get resized, so palette indices can't be blended.
    if (image.hasPalette) {
      image = image.convert(numChannels: 4);
    }
    if (supplied.containsKey(index)) {
      log('Band $index of $textureName is supplied more than once; '
          'using ${pair.item1.path}');
    }
    supplied[index] = image;
  }
  if (supplied.isEmpty) {
    return null;
  }

  // One scale for all bands, the largest, so none is shrunk.
  var scale = 1;
  final bandScales = <int>{};
  for (final band in supplied.entries) {
    final cols = strips[band.key].cols ?? entry.textureWidth;
    final bandScale = (band.value.width / cols).round();
    bandScales.add(bandScale < 1 ? 1 : bandScale);
    if (bandScale > scale) {
      scale = bandScale;
    }
  }
  if (bandScales.length > 1) {
    log('Bands of $textureName are not all the same scale; using ${scale}x');
  }
  if (entry.fitWidth != null) {
    scale = entry.fitWidth! ~/ entry.textureWidth;
  }

  final canvas = Image(
    width: entry.textureWidth * scale,
    height: entry.textureHeight * scale,
    numChannels: 4,
  );
  for (var i = 0; i < strips.length; i++) {
    var image = supplied[i];
    if (image == null) {
      continue;
    }
    final strip = strips[i];
    final width = (strip.cols ?? entry.textureWidth) * scale;
    // Sized to what the dump covered, then cropped back to what the band draws.
    if (image.width != width || image.height != strip.hashRows * scale) {
      image = copyResize(
        image,
        width: width,
        height: strip.hashRows * scale,
        interpolation: Interpolation.cubic,
      );
    }
    if (strip.hashRows != strip.rows) {
      image = copyCrop(
        image,
        x: 0,
        y: (strip.y - strip.hashY) * scale,
        width: width,
        height: strip.rows * scale,
      );
    }
    compositeImage(canvas, image,
        dstX: strip.x * scale, dstY: strip.y * scale, blend: BlendMode.direct,);
  }

  final composed = TextureManifestEntry(
    entry.hash,
    entry.textureType,
    entry.textureWidth,
    entry.textureHeight,
    tileWidth: entry.tileWidth,
    tileHeight: entry.tileHeight,
  )..targetName = entry.targetName;
  return buildTextureFromImage(canvas, composed, textureName);
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
  final imageData = await pair.item1.readAsBytes();
  var image = decodePng(imageData);

  if (image == null) {
    log('Failed to decode image data for PNG: $textureName');
    return null;
  }

  // A Rice dump can split a texture into an _rgb image and an _a image.
  final path = pair.item1.path;
  if (path.endsWith('_rgb.png')) {
    image = image.convert(numChannels: 3);
    final alphaFile = File('${path.substring(0, path.length - 8)}_a.png');
    if (await alphaFile.exists()) {
      final alpha = decodePng(await alphaFile.readAsBytes());
      if (alpha != null && alpha.width == image.width && alpha.height == image.height) {
        image = withAlphaFrom(image, alpha);
      } else {
        log('Ignoring ${alphaFile.path}: not the size of $textureName');
      }
    }
  }

  return buildTextureFromImage(image, pair.item2, textureName);
}

// The image with another's brightness as its alpha.
Image withAlphaFrom(Image image, Image alpha) {
  final out = image.convert(numChannels: 4);
  for (final pixel in out) {
    pixel.a = alpha.getPixel(pixel.x, pixel.y).luminance;
  }
  return out;
}

Uint8List? buildTextureFromImage(
  Image source,
  TextureManifestEntry entry,
  String textureName,
) {
  final texture = Texture.empty();
  var image = source;

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
  texture.isPalette = image.hasPalette && fitsPaletteFormat(image, texture.textureType);

  final isNotOriginalSize = entry.textureWidth != image.width ||
      entry.textureHeight != image.height;
  final isAdditive = entry.kind == TextureEntryKind.additive;
  if (isAdditive) {
    texture.isPalette = false;
  }
  final isCi = entry.textureType == TextureType.Palette8bpp ||
      entry.textureType == TextureType.Palette4bpp;
  // An I texture's alpha is its brightness. Art without alpha over one gets the same.
  final isIntensity = entry.textureType == TextureType.Grayscale4bpp ||
      entry.textureType == TextureType.Grayscale8bpp;
  if (isIntensity && image.numChannels.isOdd) {
    image = withAlphaFrom(image, image);
  }
  // Art without a palette over a CI original is packed raw at any size.
  final isRaw = isNotOriginalSize ||
      isAdditive ||
      (isCi && !texture.isPalette) ||
      !fitsIntensityFormat(image, entry.textureType);
  if (isRaw) {
    image = fitIntegerScale(image, entry, textureName);
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

  if (isCi) {
    if (texture.isPalette) {
      texture.textureType = entry.textureType;
    }
  } else if (!isRaw) {
    // A rescaled replacement is RGBA32 now, and the raw load flag makes the
    // renderer read it by the type recorded here.
    texture.textureType = entry.textureType;
  }

  return texture.build();
}

// The size a staged texture packs at, from its PNG headers.
Future<Tuple2<int, int>?> packedSize(List<Tuple2<File, TextureManifestEntry>> group) async {
  final entry = group.first.item2;
  if (group.length == 1) {
    final info = PngDecoder().startDecode(await group.first.item1.readAsBytes());
    return info == null ? null : wholeMultiple(info.width, info.height, entry);
  }
  // Bands take the largest band's scale, as processBands does.
  var scale = 1;
  for (final pair in group) {
    final info = PngDecoder().startDecode(await pair.item1.readAsBytes());
    final cols = entry.strips![pair.item2.stripIndex!].cols ?? entry.textureWidth;
    if (info != null) {
      scale = max(scale, (info.width / cols).round());
    }
  }
  return Tuple2(entry.textureWidth * scale, entry.textureHeight * scale);
}

// The whole multiple of the texture nearest a size.
Tuple2<int, int> wholeMultiple(int width, int height, TextureManifestEntry entry) {
  final kx = max(1, (width / entry.textureWidth).round());
  final ky = max(1, (height / entry.textureHeight).round());
  return Tuple2(kx * entry.textureWidth, ky * entry.textureHeight);
}

bool fitsPaletteFormat(Image image, TextureType type) {
  if (type != TextureType.Palette4bpp && type != TextureType.Palette8bpp) {
    return false;
  }
  final limit = type == TextureType.Palette4bpp ? 16 : 256;
  for (final pixel in image) {
    if (pixel.index >= limit) {
      return false;
    }
  }
  return true;
}

// I and IA hold grey only, and I draws its brightness as alpha.
bool fitsIntensityFormat(Image image, TextureType type) {
  final intensity = type == TextureType.Grayscale4bpp ||
      type == TextureType.Grayscale8bpp;
  final intensityAlpha = type == TextureType.GrayscaleAlpha4bpp ||
      type == TextureType.GrayscaleAlpha8bpp ||
      type == TextureType.GrayscaleAlpha16bpp;
  if (!intensity && !intensityAlpha) {
    return true;
  }
  for (final pixel in image.convert(numChannels: 4)) {
    if (pixel.r != pixel.g ||
        pixel.r != pixel.b ||
        (intensity && pixel.a != pixel.r)) {
      return false;
    }
  }
  return true;
}

// Fast3D truncates a fractional scale and the texture stops lining up, so snap
// to the nearest whole multiple.
Image fitIntegerScale(
  Image image,
  TextureManifestEntry entry,
  String textureName,
) {
  if (entry.textureWidth <= 0 || entry.textureHeight <= 0) {
    return image;
  }
  final multiple = wholeMultiple(image.width, image.height, entry);
  final width = entry.fitWidth ?? multiple.item1;
  final height = entry.fitHeight ?? multiple.item2;
  if (image.width == width && image.height == height) {
    return image;
  }
  log('Resampling $textureName from ${image.width}x${image.height} to '
      '${width}x$height, a whole multiple of '
      '${entry.textureWidth}x${entry.textureHeight}');
  return copyResize(
    image,
    width: width,
    height: height,
    // A palettized image holds indices. Blending them invents palette entries.
    interpolation:
        image.hasPalette ? Interpolation.nearest : Interpolation.cubic,
  );
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
