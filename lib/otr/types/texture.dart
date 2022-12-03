// ignore_for_file: constant_identifier_names
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';
import 'package:retro/otr/utils/tex_utils.dart';

enum TextureType {
  Error (0, 0),
  RGBA32bpp (1, 4),
  RGBA16bpp (2, 2),
  Palette4bpp (3, 0.5),
  Palette8bpp (4, 1),
  Grayscale4bpp (5, 0.5),
  Grayscale8bpp (6, 1),
  GrayscaleAlpha4bpp (7, 0.5),
  GrayscaleAlpha8bpp (8, 1),
  GrayscaleAlpha16bpp (9, 2);

  final int value;
  final double pixelMultiplier;
  const TextureType(this.value, this.pixelMultiplier);

  int getBufferSize(int width, int height) {
    return (width * height * pixelMultiplier).toInt();
  }

  static TextureType fromValue(int value) {
    return TextureType.values.firstWhere((TextureType type) => type.value == value);
  }
}

class Texture extends Resource {

  TextureType textureType;
  int width, height;
  int texDataSize;
  Uint8List texData;

  Texture(this.textureType, this.width, this.height, this.texDataSize, this.texData) : super(ResourceType.texture, 0, Version.deckard);

  Texture.empty() : this(TextureType.Error, 0, 0, 0, Uint8List(0));

  @override
  void writeResourceData() {
    writeInt32(textureType.value);
    writeInt32(width);
    writeInt32(height);
    writeInt32(texDataSize);
    appendData(texData);
  }

  @override
  void readResourceData() {
    textureType = TextureType.fromValue(readInt32());
    width = readInt32();
    height = readInt32();
    texDataSize = readInt32();
    texData = readBytes(texDataSize);
  }

  void fromPNGImage(Uint8List png){
    convertPNGToN64(png);
  }

  Uint8List toPNGBytes(){
    return convertN64ToPNG()!;
  }
}