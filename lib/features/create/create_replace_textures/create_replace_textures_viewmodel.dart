import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:flutter_storm/flutter_storm_bindings_generated.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/types/texture.dart' as soh;
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/utils/path.dart' as p;

enum CreateReplacementTexturesStep { question, selectFolder, selectOTR }
typedef ProcessedFilesInFolder = List<Tuple2<File, TextureType>>;

class CreateReplaceTexturesViewModel extends ChangeNotifier {
  CreateReplacementTexturesStep currentStep =
      CreateReplacementTexturesStep.question;
  String? selectedFolderPath;
  String? selectedOTRPath;
  bool isProcessing = false;
  HashMap<String, dynamic> processedFiles = HashMap();

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
    isProcessing = false;
    notifyListeners();    
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
  List<FileSystemEntity> pngFiles = files.where((file) => file.path.endsWith('.png')).toList();

  // for each png, check if it's in the manifest
  for (FileSystemEntity rawFile in pngFiles) {
    File pngFile = File(p.normalize(rawFile.path));
    String pngPathRelativeToFolder = p.normalize(pngFile.path.split("${folderPath!}/").last.split('.').first);
    if (manifest.containsKey(pngPathRelativeToFolder)) {
      TextureManifestEntry manifestEntry = TextureManifestEntry.fromJson(manifest[pngPathRelativeToFolder]);
      // if it is, check if the file has changed
      Uint8List pngFileBytes = await pngFile.readAsBytes();
      String pngFileHash = sha256.convert(pngFileBytes).toString();
      if (manifestEntry.hash != pngFileHash) {
        // if it has, add it to the processed files list
        log("Found file with changed hash: $pngPathRelativeToFolder");

        String pathWithoutFilename = p.normalize(pngPathRelativeToFolder.split("/").sublist(0, pngPathRelativeToFolder.split("/").length - 1).join("/"));
        if(processedFiles.containsKey(pathWithoutFilename)){
          processedFiles[pathWithoutFilename]!.add(Tuple2(pngFile, manifestEntry.textureType));
        } else {
          processedFiles[pathWithoutFilename] = [Tuple2(pngFile, manifestEntry.textureType)];
        }
      }
    } else {
      log("Found file not present in manifest: $pngPathRelativeToFolder");
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

    soh.Texture texture = soh.Texture.empty();
    texture.open(fileData);

    if(!texture.isValid){
      return false;
    }

    log("Found texture: $fileName! with type: ${texture.textureType} and size: ${texture.width}x${texture.height}");

    // Write to disk using the same path we found it in
    File textureFile = File(outputPath);
    await textureFile.create(recursive: true);
    Uint8List pngBytes = texture.toPNGBytes();
    await textureFile.writeAsBytes(pngBytes);

    // Track file path and hash
    Uint8List textureBytes = await textureFile.readAsBytes();
    String fileHash = sha256.convert(textureBytes).toString();
    onProcessed(TextureManifestEntry(fileHash, texture.textureType));
    return true;
  } on StormLibException catch (e) {
    log("Failed to find next file: ${e.message}");
    return false;
  } catch (e) {
    // Not a texture
    return false;
  }
}
