import 'dart:collection';

import 'package:retro/models/texture_manifest_entry.dart';

abstract class GameTextureConventions {
  TextureManifestEntry? resolveAdditiveEntry(
      Map<String, dynamic> manifest, String target,);
  Future<void> recordExtractionMetadata(
      List<String> otrPaths, HashMap<String, TextureManifestEntry> entries,);
}
