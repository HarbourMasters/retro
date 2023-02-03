import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_bindings.dart';
import 'package:flutter_storm/flutter_storm_defines.dart';
import 'package:image/image.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/types/background.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/utils/path.dart' as p;
import 'package:path/path.dart' as path;

enum CreateReplacementTexturesStep { question, selectFolder, selectOTR }
typedef ProcessedFilesInFolder = List<Tuple2<File, TextureManifestEntry>>;

class CreateReplaceTexturesViewModel extends ChangeNotifier {
  CreateReplacementTexturesStep currentStep =
      CreateReplacementTexturesStep.question;
  String? selectedFolderPath;
  String? selectedOTRPath;
  bool isProcessing = false;
  HashMap<String, dynamic> processedFiles = HashMap();
  String fontData = "assets/FontData";
  String fontTLUT = "assets/FontTLUT[%d].png";

  reset() {
    currentStep = CreateReplacementTexturesStep.question;
    selectedFolderPath = null;
    selectedOTRPath = null;
    isProcessing = false;
    processedFiles = HashMap();
    notifyListeners();
  }

  onUpdateStep(CreateReplacementTexturesStep step) {
    currentStep = step;
    notifyListeners();
  }

  onSelectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      selectedFolderPath = p.normalize(selectedDirectory);
      isProcessing = true;
      notifyListeners();

      HashMap<String, ProcessedFilesInFolder>? processedFiles = await compute(processFolder, selectedFolderPath!);
      if (processedFiles == null) {
      // TODO: Handle this error.
    } else {
      this.processedFiles = processedFiles;
    }
      isProcessing = false;
      notifyListeners();
    }
  }

  onSelectOTR() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['otr']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      notifyListeners();
    }
  }

  onProcessOTR() async {
    if (selectedOTRPath == null) {
      // TODO: Handle this error
      return;
    }

    // Ask for output folder
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    isProcessing = true;
    notifyListeners();

    HashMap<String, TextureManifestEntry>? processedFiles = await compute(processOTR, Tuple2(selectedOTRPath!, selectedDirectory));
    if (processedFiles == null) {
      // TODO: Handle this error.
    } else {
      this.processedFiles = processedFiles;
    }

    String otrName = selectedOTRPath!.split(Platform.pathSeparator).last.split(".").first;
    await dumpFont(path.join(selectedDirectory, otrName), (TextureManifestEntry entry) {
      this.processedFiles["textures/fonts"] = entry;
    });

    isProcessing = false;
    notifyListeners();
  }

  dumpFont(String outputPath, Function onProcessed) async {
    Image fontImage = Image(width: 16 * 4, height: 256, numChannels: 4, withPalette: false);

    Texture tex = Texture.empty();
    tex.open((await rootBundle.load(fontData)).buffer.asUint8List());
    for(int id = 0; id < 4; id++){
      Texture tlut = Texture.empty();
      tex.tlut = tlut;
      tlut.textureType = TextureType.RGBA32bpp;
      tlut.fromPNGImage(decodePng((await rootBundle.load(fontTLUT.replaceAll('%d', id.toString()))).buffer.asUint8List())!);
      compositeImage(fontImage, decodePng(tex.toPNGBytes())!, dstX: id * 16, dstY: 0);
    }

    String fileName = "textures/font/sGfxPrintFontData";
    File textureFile = File(path.join(outputPath, "$fileName.png"));
    Uint8List pngBytes = encodePng(fontImage);
    textureFile.createSync(recursive: true);
    textureFile.writeAsBytesSync(pngBytes);
    String hash = sha256.convert(pngBytes).toString();
    onProcessed(fileName, TextureManifestEntry(hash, tex.textureType, fontImage.width, fontImage.height));
  }
}

Future<HashMap<String, ProcessedFilesInFolder>?> processFolder(String folderPath) async {
  HashMap<String, ProcessedFilesInFolder> processedFiles = HashMap();

  // search for and load manifest.json
  String manifestPath = p.normalize("$folderPath/manifest.json");
  File manifestFile = File(manifestPath);
  if (!manifestFile.existsSync()) {
    return null;
  }

  String manifestContents = await manifestFile.readAsString();
  Map<String, dynamic> manifest = jsonDecode(manifestContents);

  // find all pngs in folder
  List<FileSystemEntity> files = Directory(folderPath).listSync(recursive: true);

  // for each png, check if it's in the manifest
  for (FileSystemEntity rawFile in files) {
    File texFile = File(p.normalize(rawFile.path));
    String texPathRelativeToFolder = p.normalize(texFile.path.split("$folderPath/").last.split('.').first);
    if (manifest.containsKey(texPathRelativeToFolder)) {
      TextureManifestEntry manifestEntry = TextureManifestEntry.fromJson(manifest[texPathRelativeToFolder]);
      // if it is, check if the file has changed
      Uint8List texFileBytes = await texFile.readAsBytes();
      String texFileHash = sha256.convert(texFileBytes).toString();
      if (manifestEntry.hash != texFileHash) {
        // if it has, add it to the processed files list
        log("Found file with changed hash: $texPathRelativeToFolder");

        String pathWithoutFilename = p.normalize(texPathRelativeToFolder.split("/").sublist(0, texPathRelativeToFolder.split("/").length - 1).join("/"));
        if(processedFiles.containsKey(pathWithoutFilename)){
          processedFiles[pathWithoutFilename]!.add(Tuple2(texFile, manifestEntry));
        } else {
          processedFiles[pathWithoutFilename] = [Tuple2(texFile, manifestEntry)];
        }
      }
    } else {
      log("Found file not present in manifest: $texPathRelativeToFolder");
    }
  }

  return processedFiles;
}

Future<HashMap<String, TextureManifestEntry>?> processOTR(Tuple2<String, String> params) async {
  try {
    bool fileFound = false;
    HashMap<String, TextureManifestEntry> processedFiles = HashMap();

    log("Processing OTR: ${params.item1}");
    MPQArchive? mpqArchive = MPQArchive.open(params.item1, 0, MPQ_OPEN_READ_ONLY);

    FileFindResource hFind = FileFindResource();
    mpqArchive.findFirstFile("*", hFind, null);

    // if folder we'll export to exists, delete it
    String otrName = params.item1.split(Platform.pathSeparator).last.split(".").first;
    Directory dir = Directory("${params.item2}/$otrName");
    if (dir.existsSync()) {
      log("Deleting existing folder: ${params.item2}/$otrName");
      await dir.delete(recursive: true);
    }

    // process first file
    String? fileName = hFind.fileName();
    await processFile(fileName!, mpqArchive, "${params.item2}/$otrName/$fileName.png", (TextureManifestEntry entry) {
      processedFiles[fileName] = entry;
    });

    do {
      try {
        mpqArchive.findNextFile(hFind);
        fileFound = true;

        String? fileName = hFind.fileName();
        if (fileName == null || fileName == "(signature)" || fileName == "(listfile)" || fileName == "(attributes)") {
          continue;
        }

        log("Processing file: $fileName");
        bool processed = await processFile(fileName, mpqArchive, "${params.item2}/$otrName/$fileName.png", (TextureManifestEntry entry) {
          processedFiles[fileName] = entry;
        });

        if (!processed) {
          continue;
        }
      } on StormLibException catch (e) {
        log("Got a StormLib error: ${e.message}");
        fileFound = false;
      } on Exception catch (e) {
        log("Got an error: $e");
        fileFound = false;
      }
    } while (fileFound);

    // Write out the processed files to disk
    String? manifestOutputPath = "${params.item2}/$otrName/manifest.json";
    File manifestFile = File(manifestOutputPath);
    await manifestFile.create(recursive: true);
    String dataToWrite = jsonEncode(processedFiles);
    await manifestFile.writeAsString(dataToWrite);

    hFind.close();
    return processedFiles;
  } on StormLibException catch (e) {
    log("Failed to find next file: ${e.message}");
    return null;
  }
}

Future<bool> processFile(String fileName, MPQArchive mpqArchive, String outputPath, Function onProcessed) async {
  try {
    FileResource file = mpqArchive.openFileEx(fileName, 0);
    int fileSize = file.size();
    Uint8List fileData = file.read(fileSize);

    Resource resource = Resource.empty();
    resource.rawLoad = true;
    resource.open(fileData);

    if(![ResourceType.texture, ResourceType.sohBackground].contains(resource.resourceType)){
      return false;
    }

    String? hash;

    switch(resource.resourceType) {
      case ResourceType.texture:
        Texture texture = Texture.empty();
        texture.open(fileData);

        Uint8List pngBytes = texture.toPNGBytes();
        File textureFile = File(outputPath);
        await textureFile.create(recursive: true);
        await textureFile.writeAsBytes(pngBytes);
        Uint8List textureBytes = await textureFile.readAsBytes();
        hash = sha256.convert(textureBytes).toString();
        onProcessed(TextureManifestEntry(hash, texture.textureType, texture.width, texture.height));
        break;
      case ResourceType.sohBackground:
        Background background = Background.empty();
        background.open(fileData);

        log("Found JPEG background: $fileName!");
        File textureFile = File("$outputPath.jpg");
        Image image = decodeJpg(background.texData)!;
        await textureFile.create(recursive: true);
        await textureFile.writeAsBytes(background.texData);
        hash = sha256.convert(background.texData).toString();
        onProcessed(TextureManifestEntry(hash, TextureType.JPEG32bpp, image.width, image.height));
        break;
      default:
        return false;
    }

    return true;
  } on StormLibException catch (e) {
    log("Failed to find next file: ${e.message}");
    return false;
  } catch (e) {
    // Not a texture
    print(e);
    return false;
  }
}
