import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Texture hide Image;
import 'package:flutter_storm/bridge/errors.dart';
import 'package:flutter_storm/bridge/flags.dart';
import 'package:flutter_storm/flutter_storm.dart';
import 'package:image/image.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/types/background.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/utils/log.dart';
import 'package:tuple/tuple.dart';
import 'package:retro/utils/path.dart' as pu;
import 'package:path/path.dart' as p;

enum CreateReplacementTexturesStep { question, selectFolder, selectOTR }

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
      notifyListeners();
      processFolder();
    }
  }

  processFolder() async {
    isProcessing = true;
    notifyListeners();

    HashMap<String, List<Tuple2<File, TextureManifestEntry>>> processedFiles = HashMap();

    // search for and load manifest.json
    String manifestPath = p.join(selectedFolderPath!, "manifest.json");
    File manifestFile = File(manifestPath);
    if (!manifestFile.existsSync()) {
      // TODO: Handle this error
      return;
    }

    String manifestContents = await manifestFile.readAsString();
    Map<String, dynamic> manifest = jsonDecode(manifestContents);

    // find all pngs in folder
    List<FileSystemEntity> files = Directory(selectedFolderPath!).listSync(recursive: true);

    // for each png, check if it's in the manifest
    for (FileSystemEntity rawFile in files) {
      File texFile = File(p.normalize(rawFile.path));
      String texPathRelativeToFolder = p.normalize(texFile.path.split("${selectedFolderPath!}/").last.split('.').first);
      if (manifest.containsKey(texPathRelativeToFolder)) {
        TextureManifestEntry manifestEntry = TextureManifestEntry.fromJson(manifest[texPathRelativeToFolder]);
        // if it is, check if the file has changed
        String pngFileHash = sha256.convert((texFile).readAsBytesSync()).toString();
        if (manifestEntry.hash != pngFileHash) {
          // if it has, add it to the processed files list
          log("Found file with changed hash: $texPathRelativeToFolder");

          String pathWithoutFilename = pu.normalize(texPathRelativeToFolder.split("/").sublist(0, texPathRelativeToFolder.split("/").length - 1).join("/"));
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

    isProcessing = false;
    this.processedFiles = processedFiles;
    notifyListeners();
  }

  onSelectOTR() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false, type: FileType.custom, allowedExtensions: ['otr']);
    if (result != null && result.files.isNotEmpty) {
      selectedOTRPath = result.paths.first;
      if (selectedOTRPath == null) {
        // TODO: Handle this error
        return;
      }

      notifyListeners();
    }
  }

  processOTR() async {
    if (selectedOTRPath == null) {
      // TODO: Handle this error
      return;
    }

    // Ask for output folder
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    try {
      bool fileFound = false;
      isProcessing = true;
      HashMap<String, TextureManifestEntry> processedFiles = HashMap();

      notifyListeners();

      String? otrHandle =
          await SFileOpenArchive(selectedOTRPath!, MPQ_OPEN_READ_ONLY);
      String? findData = await SFileFindCreateDataPointer();
      String? hFind = await SFileFindFirstFile(otrHandle!, "*", findData!);

      // if folder we'll export to exists, delete it
      String otrName = selectedOTRPath!.split(Platform.pathSeparator).last.split(".").first;
      Directory dir = Directory(p.join(selectedDirectory, otrName));
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }

      // process first file
      String? fileName = await SFileFindGetDataForDataPointer(findData);
      String filePath = p.join(selectedDirectory, otrName, fileName);
      await processFile(fileName!, otrHandle, filePath, (TextureManifestEntry entry) {
        processedFiles[fileName] = entry;
      });

      do {
        try {
          await SFileFindNextFile(hFind!, findData);
          fileFound = true;

          String? fileName = await SFileFindGetDataForDataPointer(findData);
          if (fileName == null || fileName == "(signature)" || fileName == "(listfile)" || fileName == "(attributes)") {
            continue;
          }

          String filePath = p.join(selectedDirectory, otrName, fileName);
          bool processed = await processFile(fileName, otrHandle, filePath, (TextureManifestEntry entry) {
            processedFiles[fileName] = entry;
          });

          if (!processed) {
            continue;
          }
        } on StormException catch (e) {
          log("Got a StormLib error: ${e.message}");
          fileFound = false;
        } on Exception catch (e) {
          log("Got an error: $e");
          fileFound = false;
        }
      } while (fileFound);

      // Write out the processed files to disk
      String? manifestOutputPath = p.join(selectedDirectory, otrName, "manifest.json");
      File manifestFile = File(manifestOutputPath);
      manifestFile.createSync(recursive: true);
      String dataToWrite = jsonEncode(processedFiles);
      manifestFile.writeAsStringSync(dataToWrite);

      SFileFindClose(hFind!);
      isProcessing = false;
      this.processedFiles = processedFiles;
      notifyListeners();
    } on StormException catch (e) {
      log("Failed to find next file: ${e.message}");
    }
  }
}

Future<bool> processFile(
  String fileName,
  String otrHandle,
  String outputPath,
  Function onProcessed
) async {
  String? fileHandle = await SFileOpenFileEx(otrHandle, fileName, 0);
  int? fileSize = await SFileGetFileSize(fileHandle!);
  Uint8List? fileData = await SFileReadFile(fileHandle, fileSize!);

  try {
    Resource resource = Resource.empty();
    resource.rawLoad = true;
    resource.open(fileData!);

    if(![ResourceType.texture, ResourceType.sohBackground].contains(resource.resourceType)){
      return false;
    }

    // Write to disk using the same path we found it in

    String? hash;

    switch(resource.resourceType){
      case ResourceType.texture:
        Texture texture = Texture.empty();
        texture.open(fileData);

        log("Found texture: $fileName! with type: ${texture.textureType} and size: ${texture.width}x${texture.height}");
        Uint8List pngBytes = texture.toPNGBytes();
        File textureFile = File("$outputPath.png");
        textureFile.createSync(recursive: true);
        textureFile.writeAsBytesSync(pngBytes);
        hash = sha256.convert(textureFile.readAsBytesSync()).toString();
        onProcessed(TextureManifestEntry(hash, texture.textureType, texture.width, texture.height));
        return true;
      case ResourceType.sohBackground:
        Background background = Background.empty();
        background.open(fileData);

        log("Found JPEG background: $fileName!");
        File textureFile = File("$outputPath.jpg");
        Image image = decodeJpg(background.texData)!;
        textureFile.createSync(recursive: true);
        textureFile.writeAsBytesSync(background.texData);
        hash = sha256.convert(background.texData).toString();
        onProcessed(TextureManifestEntry(hash, TextureType.JPEG32bpp, image.width, image.height));
        return true;
      default:
        return false;
    }
  } catch (e) {
    // Not a texture
    print(e);
    return false;
  }
}
