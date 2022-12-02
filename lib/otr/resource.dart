import 'dart:typed_data';

import 'package:retro/otr/endianness.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';

abstract class Resource {

  List<int> buffer = [];
  ResourceType resourceType;
  int resourceVersion;
  Version gameVersion;

  Resource(this.resourceType, this.resourceVersion, this.gameVersion);

  void _writeHeader() {
    writeBinary(Endianness.native.value); // 0x00
    writeInt32(resourceType.value);       // 0x04
    writeInt32(gameVersion.value);        // 0x08
    writeInt64(0xDEADBEEFDEADBEEF);       // 0x0C
    writeInt32(resourceVersion);          // 0x10
    writeInt64(0);                        // 0x14
    writeInt32(0);                        // 0x1C

    while (buffer.length < 0x40) {
      writeInt32(0);
    }
  }

  void writeResourceData();

  Uint8List build() {
    _writeHeader();
    writeResourceData();
    return Uint8List.fromList(buffer);
  }

  void appendData(Uint8List data) {
    buffer.addAll(data);
  }

  void writeBinary(int value) {
    buffer.addAll([value, 0, 0, 0]);
  }

  void writeInt8(int value) {
    buffer.addAll([value]);
  }

  void writeInt32(int value) {
    buffer.addAll(Uint8List(4)..buffer.asInt32List()[0] = value);
  }

  void writeInt64(int value) {
    buffer.addAll(Uint8List(8)..buffer.asInt64List()[0] = value);
  }

  void writeString(String value) {
    buffer.addAll(value.codeUnits);
  }
}