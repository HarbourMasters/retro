import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:retro/arc/arc.dart';
import 'package:retro/games/bk64/bk64_conventions.dart';
import 'package:retro/games/game_texture_conventions.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/types/background.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:retro/utils/path.dart' as p;
import 'package:tuple/tuple.dart';

enum CreateReplacementTexturesStep { question, selectFolder, selectOTR }

typedef ProcessedFilesInFolder = List<Tuple2<File, TextureManifestEntry>>;

class CreateReplaceTexturesViewModel extends ChangeNotifier {
  CreateReplacementTexturesStep currentStep =
      CreateReplacementTexturesStep.question;
  String? selectedFolderPath;
  List<String> selectedOTRPaths = [];
  bool isProcessing = false;
  HashMap<String, dynamic> processedFiles = HashMap();

  String fontData = 'assets/FontData';
  String fontTLUT = 'assets/FontTLUT[%d].png';
  String fontTextureName = 'textures/font/sGfxPrintFontData';

  void reset() {
    currentStep = CreateReplacementTexturesStep.question;
    selectedFolderPath = null;
    selectedOTRPaths = [];
    isProcessing = false;
    processedFiles = HashMap();
    notifyListeners();
  }

  void onUpdateStep(CreateReplacementTexturesStep step) {
    currentStep = step;
    notifyListeners();
  }

  Future<void> onSelectFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = p.normalize(selectedDirectory);
      isProcessing = true;
      notifyListeners();

      final processedFiles = await compute(processFolder, selectedFolderPath!);
      if (processedFiles == null) {
        log('Error processing folder: $selectedFolderPath');
      } else {
        this.processedFiles = processedFiles;
      }

      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> onSelectOTR() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['otr', 'o2r'],);
    if (result != null && result.files.isNotEmpty) {
      // save paths filtering out nulls
      selectedOTRPaths = result.paths.whereType<String>().toList();
      if (selectedOTRPaths.isEmpty) {
        return;
      }

      notifyListeners();
    }
  }

  Future<void> onProcessOTR() async {
    if (selectedOTRPaths.isEmpty) {
      return;
    }
    final otrNameForOutputDirectory =
        selectedOTRPaths[0].split(Platform.pathSeparator).last.split('.').first;

    // Ask for output folder
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    isProcessing = true;
    notifyListeners();

    // Process OTR
    final otrFiles =
        await compute(processOTR, Tuple2(selectedOTRPaths, selectedDirectory));
    if (otrFiles == null) {
    } else {
      processedFiles = otrFiles;
    }

    // Dump font
    await dumpFont('$selectedDirectory/$otrNameForOutputDirectory',
        (TextureManifestEntry entry) {
      processedFiles[fontTextureName] = entry;
    });

    // Write out the processed files to disk
    final manifestOutputPath =
        '$selectedDirectory/$otrNameForOutputDirectory/manifest.json';
    final manifestFile = File(manifestOutputPath);
    await manifestFile.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    final dataToWrite = encoder.convert(processedFiles);
    await manifestFile.writeAsString(dataToWrite);

    isProcessing = false;
    notifyListeners();
  }

  Future<void> dumpFont(String outputPath, Function onProcessed) async {
    final fontImage = Image(width: 16 * 4, height: 256, numChannels: 4);

    final tex = Texture.empty();
    final data = await rootBundle.load(fontData);
    tex.open(data.buffer.asUint8List());
    for (var id = 0; id < 4; id++) {
      final tlut = Texture.empty();
      tex.tlut = tlut;
      tlut.textureType = TextureType.RGBA32bpp;
      final data =
          await rootBundle.load(fontTLUT.replaceAll('%d', id.toString()));
      final pngImage = decodePng(data.buffer.asUint8List())!;
      tlut.fromRawImage(pngImage);
      compositeImage(fontImage, decodePng(tex.toPNGBytes())!,
        dstX: id * 16, dstY: 0,
      );
    }

    final textureFile = File(path.join(outputPath, '$fontTextureName.png'));
    final pngBytes = encodePng(fontImage);
    await textureFile.create(recursive: true);
    await textureFile.writeAsBytes(pngBytes);
    final hash = sha256.convert(pngBytes).toString();
    onProcessed(TextureManifestEntry(
        hash, tex.textureType, fontImage.width, fontImage.height));
  }
}

Future<HashMap<String, ProcessedFilesInFolder>?> processFolder(
    String folderPath) async {
  final processedFiles = HashMap<String, ProcessedFilesInFolder>();

  // search for and load manifest.json
  final manifestPath = p.normalize('$folderPath/manifest.json');
  final manifestFile = File(manifestPath);
  if (!manifestFile.existsSync()) {
    return null;
  }

  final manifestContents = await manifestFile.readAsString();
  final manifest = json.decode(manifestContents) as Map<String, dynamic>;

  // Optional aliases.json: maps source image paths (relative to the folder,
  // extension included) onto archive texture paths, so externally-named packs
  // can be repacked without renaming thousands of files.
  final aliases = <String, List<String>>{};
  final aliasFile = File(p.normalize('$folderPath/aliases.json'));
  if (aliasFile.existsSync()) {
    final aliasJson =
        json.decode(await aliasFile.readAsString()) as Map<String, dynamic>;
    for (final alias in aliasJson.entries) {
      final targets = alias.value is List
          ? (alias.value as List).cast<String>()
          : <String>[alias.value as String];
      aliases[p.normalize(alias.key)] = targets
          .map((target) => p.normalize(
              target.startsWith('alt/') ? target.substring(4) : target,),)
          .toList();
    }
    log('Loaded aliases.json with ${aliases.length} source images');
  }

  // find all images in folder
  final supportedExtensions = <String>['.png', '.jpeg', '.jpg'];
  final files = Directory(folderPath).listSync(recursive: true);
  final texFiles = files
      .where((file) => supportedExtensions.contains(path.extension(file.path)))
      .toList();

  for (final rawFile in texFiles) {
    final texFile = File(p.normalize(rawFile.path));
    final relativePath = p.normalize(path.relative(texFile.path, from: folderPath));
    final texPathRelativeToFolder = p.normalize(path.withoutExtension(relativePath));
    final targets = aliases[relativePath] ?? [texPathRelativeToFolder];

    for (final target in targets) {
      final manifestEntry = resolveTextureEntry(manifest, target);
      if (manifestEntry == null) {
        log('Found file not present in manifest: $target');
        continue;
      }

      if (manifestEntry.kind == TextureEntryKind.replacement) {
        final texFileBytes = await texFile.readAsBytes();
        final texFileHash = sha256.convert(texFileBytes).toString();
        if (manifestEntry.hash == texFileHash) {
          continue;
        }
        log('Found file with changed hash: $target');
      } else {
        log('Staging additive texture: $target');
      }

      manifestEntry.targetName = target;
      final pathWithoutFilename = path.dirname(target);

      if (processedFiles.containsKey(pathWithoutFilename)) {
        processedFiles[pathWithoutFilename]!.add(Tuple2(texFile, manifestEntry));
      } else {
        processedFiles[pathWithoutFilename] = [Tuple2(texFile, manifestEntry)];
      }
    }
  }

  return processedFiles;
}

// Game ports whose extra texture conventions the shared flow consults
const List<GameTextureConventions> gameTextureConventions = [
  Bk64TextureConventions(),
];

// Look a target path up in the manifest; on a miss, let each game's
// conventions try to resolve it as an additive path with a template
// entry describing how to convert it.
TextureManifestEntry? resolveTextureEntry(
    Map<String, dynamic> manifest, String target) {
  if (manifest.containsKey(target)) {
    return TextureManifestEntry.fromJson(
        manifest[target] as Map<String, dynamic>);
  }
  for (final game in gameTextureConventions) {
    final entry = game.resolveAdditiveEntry(manifest, target);
    if (entry != null) {
      return entry;
    }
  }
  return null;
}

Future<HashMap<String, TextureManifestEntry>?> processOTR(
    Tuple2<List<String>, String> params) async {
  final processedFiles = HashMap<String, TextureManifestEntry>();

  // just use the first otr in the list for the  directory name
  final otrNameForOutputDirectory =
      params.item1[0].split(Platform.pathSeparator).last.split('.').first;

  // if folder we'll export to exists, delete it
  final dir = Directory('${params.item2}/$otrNameForOutputDirectory');
  if (dir.existsSync()) {
    log('Deleting existing folder: ${params.item2}/$otrNameForOutputDirectory');
    await dir.delete(recursive: true);
  }

  for (final otrPath in params.item1) {
    log('Processing OTR: $otrPath');
    final arcFile = Arc(otrPath);

    await arcFile.listItems(onFile: (String fileName, Uint8List data) async {
      await processFile(fileName, data, '${params.item2}/$otrNameForOutputDirectory/$fileName', (TextureManifestEntry entry) {
        processedFiles[fileName] = entry;
      });
    },);
    arcFile.close();
  }

  for (final game in gameTextureConventions) {
    await game.recordExtractionMetadata(params.item1, processedFiles);
  }

  return processedFiles.isEmpty ? null : processedFiles;
}

Future<bool> processFile(String fileName, Uint8List data, String outputPath, Function onProcessed) async {
  final resource = Resource.empty()
    ..rawLoad = true
    ..open(data);

  if (![ResourceType.texture, ResourceType.sohBackground]
      .contains(resource.resourceType)) {
    return false;
  }

  String? hash;

  switch (resource.resourceType) {
    case ResourceType.texture:
      final texture = Texture.empty();
      texture.open(data);
      final pngBytes = texture.toPNGBytes();
      final textureFile = File('$outputPath.png');
      await textureFile.create(recursive: true);
      await textureFile.writeAsBytes(pngBytes);
      final textureBytes = await textureFile.readAsBytes();
      hash = sha256.convert(textureBytes).toString();
      onProcessed(TextureManifestEntry(
          hash, texture.textureType, texture.width, texture.height));
      break;
    case ResourceType.sohBackground:
      final background = Background.empty();
      background.open(data);

      log('Found JPEG background: $fileName!');
      final textureFile = File('$outputPath.jpg');
      final image = decodeJpg(background.texData)!;
      await textureFile.create(recursive: true);
      await textureFile.writeAsBytes(background.texData);
      hash = sha256.convert(background.texData).toString();
      onProcessed(TextureManifestEntry(
          hash, TextureType.JPEG32bpp, image.width, image.height));
      break;
    default:
      return false;
  }

  return true;
}
