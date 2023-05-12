import 'dart:io';
import 'dart:typed_data';

import 'package:retro/otr/resource.dart';
import 'package:retro/otr/resource_type.dart';
import 'package:retro/otr/version.dart';
import 'package:tuple/tuple.dart';

class Sequence extends Resource {

  Sequence(this.size, this.rawBinary, this.cachePolicy, this.medium, this.sequenceNum, this.numFonts, this.fontIndices, this.path) : super(ResourceType.sohAudioSequence, 0, Version.rachael);

  int size;
  Uint8List rawBinary;
  int sequenceNum;
  int medium;
  int cachePolicy;
  int numFonts;
  Uint8List fontIndices;
  String path;

  static Future<Sequence> fromSeqFile(Tuple2<File, File> sequence ) async {
    final metadata = (await sequence.item2.readAsString()).split('\n');
    final rawData = await sequence.item1.readAsBytes();
    final fontIdx = int.parse(metadata[1].toLowerCase().replaceAll('0x', ''), radix: 16);
    final type = metadata.length > 2 && metadata[2].isNotEmpty ? metadata[2].toLowerCase().trim() : 'bgm';
    final metaname = metadata[0].trim().replaceAll('/', '|');

    return Sequence(
      rawData.length, rawData,
      type == 'bgm' ? 2 : 1,
      2, 0, 1,
      Uint8List(1)..[0] = fontIdx,
      '${metaname}_$type',
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
    for (var i = 0; i < numFonts; i++) {
      writeInt8(fontIndices[i]);
    }
  }
}