import 'dart:io';

import 'package:retro/models/texture_manifest_entry.dart';
import 'package:tuple/tuple.dart';

abstract class StageEntry {
  abstract final List<File> iterables;
}

class CustomStageEntry extends StageEntry {
  CustomStageEntry(this.files);
  final List<File> files;

  @override
  List<File> get iterables => files;
}

class CustomSequencesEntry extends StageEntry {
  CustomSequencesEntry(this.pairs);
  final List<Tuple2<File, File>> pairs;

  @override
  List<File> get iterables => pairs.map((e) => e.item1).toList();
}

class CustomTexturesEntry extends StageEntry {
  CustomTexturesEntry(this.pairs);
  final List<Tuple2<File, TextureManifestEntry>> pairs;

  @override
  List<File> get iterables => pairs.map((e) => e.item1).toList();
}
