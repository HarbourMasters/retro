import 'dart:typed_data';

import 'package:retro/otr/endianness.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';

abstract class Resource {

  List<int> buffer = [];
  ResourceType resourceType;
  int resourceVersion;
  Version gameVersion;
  int magicID = 0xDEADBEEFDEADBEEF;
  Endianness endianness = Endianness.native;
  int _baseLength = 0;
  bool isValid = false;

  Resource(this.resourceType, this.resourceVersion, this.gameVersion);

  Resource.empty() : this(ResourceType.unknown, 0, Version.unknown);

  // Writer methods

  void _writeHeader() {
    writeBinary(Endianness.native.value);   // 0x00
    writeInt32(resourceType.value);  // 0x04
    writeInt32(gameVersion.value);   // 0x08
    writeInt64(magicID);             // 0x0C
    writeInt32(resourceVersion);     // 0x10
    writeInt64(0);                   // 0x14
    writeInt32(0);                   // 0x1C

    while (buffer.length < 0x40) {
      writeInt32(0);
    }
  }

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

  void writeFloat32(double value) {
    buffer.addAll(Uint8List(4)..buffer.asFloat32List()[0] = value);
  }

  void writeString(String value) {
    buffer.addAll(value.codeUnits);
  }

  void writeResourceData(){}

  // Reader methods

  void _readHeader() {

    if(buffer.length < 0x40) {
      isValid = false;
      return;
    }

    endianness = Endianness.fromValue(readBinary());

    if(endianness == Endianness.unknown) {
      isValid = false;
      return;
    }

    for (int i = 0; i < 3; i++) {
      readInt8();
    }

    isValid = ResourceType.fromValue(readInt32()) == resourceType;
    if(!isValid){
      return;
    }
    gameVersion     = Version.fromValue(readInt32());
    magicID         = readInt64();
    resourceVersion = readInt32(); // Resource minor version number
    readInt64();                   // ROM CRC
    readInt32();                   // ROM Enum

    // Reserved for future file format versions...

    seek(0x40, fromStart: true);
  }

  void open(Uint8List data) {
    buffer = data.toList();
    _baseLength = buffer.length;
    _readHeader();
    if(isValid) {
      readResourceData();
    }
  }

  void seek(int offset, { bool fromStart = false}) {
    buffer = buffer.sublist(fromStart ? (buffer.length - (_baseLength - offset)) : offset);
  }

  Uint8List readBytes(int length) {
    Uint8List data = Uint8List.fromList(buffer.sublist(0, length));
    buffer = buffer.sublist(length);
    return data;
  }

  int readBinary() {
    return readInt8();
  }

  int readInt8() {
    final int value = buffer[0];
    seek(1);
    return value;
  }

  int readInt32() {
    final int value = endianness == Endianness.little
        ? buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24
        : buffer[3] | buffer[2] << 8 | buffer[1] << 16 | buffer[0] << 24;
    seek(4);
    return value;
  }

  int readInt64() {
    final int value = endianness == Endianness.little
        ? buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24 | buffer[4] << 32 | buffer[5] << 40 | buffer[6] << 48 | buffer[7] << 56
        : buffer[7] | buffer[6] << 8 | buffer[5] << 16 | buffer[4] << 24 | buffer[3] << 32 | buffer[2] << 40 | buffer[1] << 48 | buffer[0] << 56;
    seek(8);
    return value;
  }

  void readResourceData(){}
}