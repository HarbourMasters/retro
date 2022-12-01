import 'dart:io';
import 'dart:typed_data';

import 'package:retro/otr/endianness.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';

class Resource {
  static int headerSize = 0x40;

  static Uint8List generateLUSCompatibleResourceData(File file, Endianness endianness, ResourceType type, Version resourceVersion, int gameVersion) {
    final Uint8List data = file.readAsBytesSync();
    final Uint8List header = generateHeader(endianness, type, resourceVersion, gameVersion);
    final Uint8List resourceData = Uint8List(header.length + data.length);
    resourceData.setRange(0, header.length, header);
    resourceData.setRange(header.length, resourceData.length, data);
    return resourceData;
  }

  static Uint8List generateHeader(Endianness endianness, ResourceType resourceType, Version resourceVersion, int gameVersion) {
    final Uint8List header = Uint8List(headerSize);
    header[0] = endianness.value;
    header[4] = resourceType.value;
    header[8] = gameVersion;
    header[0x0C] = 0xDEADBEEFDEADBEEF;
    header[0x10] = resourceVersion.value;

    return header;
  }
}