// ignore_for_file: constant_identifier_names
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';

class Background extends Resource {

  int texDataSize;
  Uint8List texData;

  Background(this.texDataSize, this.texData)
      : super(ResourceType.sohBackground, 0, Version.deckard);

  Background.empty() : this(0, Uint8List(0));

  @override
  void writeResourceData() {
    writeInt32(texDataSize);
    appendData(texData);
  }

  @override
  void readResourceData() {
    texDataSize = readInt32();
    texData = readBytes(texDataSize);
  }

  void fromBytes(Uint8List bytes) {
    texData = bytes;
    texDataSize = bytes.length;
  }

  Uint8List toPNGBytes(Image image) {
    Uint8List pngBytes = Uint8List(image.width * image.height * 4);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pos = ((y * image.width) + x) * 4;
        Pixel pixel = image.getPixel(x, y);
        pngBytes[pos + 0] = pixel.r.toInt();
        pngBytes[pos + 1] = pixel.g.toInt();
        pngBytes[pos + 2] = pixel.b.toInt();
        pngBytes[pos + 3] = 0xFF;
      }
    }
    return pngBytes;
  }
}
