import 'dart:io';
import 'dart:typed_data';

import 'package:retro/otr/resource.dart';
import 'package:retro/otr/version.dart';
import 'package:tuple/tuple.dart';

import '../resource_type.dart';

class Sequence extends Resource {

  int size;
  Uint8List rawBinary;
  int sequenceNum;
  int medium;
  int cachePolicy;
  int numFonts;
  Uint8List fontIndices;
  String path;

  Sequence(this.size, this.rawBinary, this.cachePolicy, this.medium, this.sequenceNum, this.numFonts, this.fontIndices, this.path) : super(ResourceType.sohAudioSequence, 0, Version.rachael);

  static Sequence fromSeqFile(Tuple2<File, File> sequence ){
    List<String> metadata = sequence.item2.readAsStringSync().split('\n');
    Uint8List rawData = sequence.item1.readAsBytesSync();
    int fontIdx = int.parse(metadata[1].toLowerCase().replaceAll("0x", ""), radix: 16);
    String type = metadata.length > 2 ? metadata[2].toLowerCase().trim() : "bgm";
    String metaname = metadata[0].trim().replaceAll('/', '|').replaceAll(" ", "_");

    return Sequence(
      rawData.length, rawData,
      type == "bgm" ? 2 : 1,
      2, 0, 1,
      Uint8List(1)..[0] = fontIdx,
      "${metaname}_$type"
    );
  }

  @override
  void writeResourceData() {
    writeInt32(size);
    appendData(rawBinary);
    writeInt8(sequenceNum);
    writeInt8(medium);
    writeInt8(cachePolicy);
    writeInt32(numFonts);
    for (int i = 0; i < numFonts; i++) {
      writeInt8(fontIndices[i]);
    }
  }

}