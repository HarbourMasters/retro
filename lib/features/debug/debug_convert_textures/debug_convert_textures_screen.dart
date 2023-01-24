import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Texture, Image;
import 'package:image/image.dart' hide Color;
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/types/background.dart';
import 'package:retro/otr/types/texture.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:path/path.dart' as path;

class DebugConvertTexturesScreen extends StatefulWidget {
  const DebugConvertTexturesScreen({super.key});

  @override
  State<DebugConvertTexturesScreen> createState() => _DebugConvertTexturesScreenState();
}

class _DebugConvertTexturesScreenState extends State<DebugConvertTexturesScreen> {

  TextureType selectedTextureType = TextureType.RGBA32bpp;
  Texture? textureData;
  File? textureFile;

  Uint8List? textureBytes;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Debug Convert Textures",
      subtitle: "Convert and preview textures",
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("PNG to N64 Viewer",
                    style: TextStyle(color: Colors.white, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF40aae8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton(
                      value: selectedTextureType,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      borderRadius: BorderRadius.circular(5),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
                      dropdownColor: const Color(0xFF40aae8),
                      underline: Container(),
                      items: TextureType.values.sublist(1).map<DropdownMenuItem>((e) => DropdownMenuItem(
                        value: e,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 17),
                          child: Text(e.name)
                        ),
                      )).toList(),
                      onChanged: (_){
                        setState(() {
                          selectedTextureType = _ as TextureType;
                        });
                      }
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(textureFile == null ? "Select Texture File" : textureFile!.path.split(path.separator).last,
                          maxLines: 1
                        )
                      )
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        allowMultiple: false, type: FileType.image
                      );
                      if (result != null) {
                        setState(() {
                          textureFile = File(result.files.single.path!);
                        });
                      }
                    }
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    child: const Text("Convert Texture"),
                    onPressed: (){
                      if (textureFile != null) {
                        setState(() {
                          textureData = Texture.empty();
                          textureData?.textureType = selectedTextureType;
                          Image image = decodePng(textureFile!.readAsBytesSync())!;
                          textureData!.fromPNGImage(image);
                          if(selectedTextureType.name.contains("Palette")){
                            textureData!.isPalette = true;
                          }
                          textureBytes = textureData!.toPNGBytes();
                        });
                      }
                    }
                  ),
                  if(textureData != null && textureData!.isPalette)
                  const SizedBox(height: 20.0),
                  if(textureData != null && textureData!.isPalette)
                  ElevatedButton(
                    child: const Text("Load TLUT"),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        allowMultiple: false, type: FileType.image
                      );
                      if (result != null) {
                        setState(() {
                          Texture tlut = Texture.empty();
                          tlut.textureType = TextureType.RGBA32bpp;
                          Image image = decodePng(File(result.files.single.path!).readAsBytesSync())!;
                          tlut.fromPNGImage(image);
                          textureData!.tlut = tlut;
                          textureBytes = textureData!.toPNGBytes();
                        });
                      }
                    }
                  ),
                  if(textureData != null && textureData!.tlut != null)
                  const SizedBox(height: 20.0),
                  if(textureData != null && textureData!.tlut != null)
                  ElevatedButton(
                    child: const Text("Save As"),
                    onPressed: () async {
                      String? result = await FilePicker.platform.saveFile(
                        type: FileType.image, allowedExtensions: ["png"], fileName: "converted.png"
                      );
                      if (result != null) {
                        setState(() {
                          File out = File(result);
                          out.writeAsBytesSync(textureBytes!);
                        });
                      }
                    }
                  ),
                  const SizedBox(height: 20.0),
                  const Text("OTR N64 Viewer",
                    style: TextStyle(color: Colors.white, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(textureFile == null ? "Select Texture File" : textureFile!.path.split(path.separator).last,
                          maxLines: 1
                        )
                      )
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        allowMultiple: false, type: FileType.any
                      );
                      if (result != null) {
                        setState(() {
                          textureFile = File(result.files.single.path!);
                        });
                      }
                    }
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    child: const Text("Load Texture"),
                    onPressed: (){
                      if (textureFile != null) {
                        Uint8List bytes = textureFile!.readAsBytesSync();

                        setState(() {
                          Resource resource = Resource.empty();
                          resource.rawLoad = true;
                          resource.open(bytes);

                          if(resource.resourceType == ResourceType.texture){
                            textureData = Texture.empty();
                            textureData?.open(bytes);
                            textureBytes = textureData!.toPNGBytes();
                          } else {
                            Background background = Background.empty();
                            background.open(bytes);
                            textureData = Texture.empty();
                            textureBytes = background.texData;
                          }
                        });
                      }
                    }
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 119,
                padding: const EdgeInsets.only( right: 20.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  image: textureData != null ? DecorationImage(
                    image: MemoryImage(textureBytes!),
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                  ) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}