import 'dart:io';

import 'package:retro/models/texture_manifest_entry.dart';
import 'package:tuple/tuple.dart';

abstract class StageEntry {
  abstract final List<File> iterables;
}

class CustomStageEntry extends StageEntry {
  final List<File> files;
  CustomStageEntry(this.files);

  @override
  List<File> get iterables => files;
}

class CustomSequencesEntry extends StageEntry {
  final List<Tuple2<File, File>> pairs;
  CustomSequencesEntry(this.pairs);

  @override
  List<File> get iterables => pairs.map((e) => e.item1).toList();
}

class CustomTexturesEntry extends StageEntry {
  final List<Tuple2<File, TextureManifestEntry>> pairs;
  CustomTexturesEntry(this.pairs);

  @override
  List<File> get iterables => pairs.map((e) => e.item1).toList();
}
