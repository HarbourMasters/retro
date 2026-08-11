import 'dart:collection';
import 'dart:typed_data';

import 'package:retro/arc/arc.dart';
import 'package:retro/games/game_texture_conventions.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:tuple/tuple.dart';

class Bk64TextureConventions implements GameTextureConventions {
  const Bk64TextureConventions();

  static final RegExp _colorVariantPattern =
      RegExp(r'^(.+_\d+_\d+)_(BLUE|GREEN|ORANGE|PURPLE|YELLOW)$');
  static final RegExp _boldFontPattern =
      RegExp(r'^(.*)boldfont/(.+_\d+_\d+)_[0-9A-Fa-f]+$');
  static final RegExp _langScopedPattern = RegExp(r'^(.*)lang/[^/]+/(.+)$');
  static final RegExp _spriteChunkPattern = RegExp(r'^(.+)_(\d+)_(\d+)$');

  @override
  TextureManifestEntry? resolveAdditiveEntry(
      Map<String, dynamic> manifest, String target,) {
    TextureManifestEntry? lookup(String key) => manifest.containsKey(key)
        ? TextureManifestEntry.fromJson(manifest[key] as Map<String, dynamic>)
        : null;

    final colorMatch = _colorVariantPattern.firstMatch(target);
    if (colorMatch != null) {
      final template = lookup(colorMatch.group(1)!);
      if (template != null) {
        return _additiveFrom(template, TextureEntryKind.additive);
      }
    }

    final boldMatch = _boldFontPattern.firstMatch(target);
    if (boldMatch != null) {
      final template =
          lookup('${boldMatch.group(1)!}sprite/${boldMatch.group(2)!}');
      if (template != null) {
        return _additiveFrom(template, TextureEntryKind.additiveFontGlyph);
      }
    }

    final langMatch = _langScopedPattern.firstMatch(target);
    if (langMatch != null) {
      final template = lookup('${langMatch.group(1)!}${langMatch.group(2)!}');
      if (template != null) {
        return _additiveFrom(template, TextureEntryKind.additive);
      }
    }

    return null;
  }

  TextureManifestEntry _additiveFrom(
      TextureManifestEntry template, TextureEntryKind kind,) {
    return TextureManifestEntry(
      '',
      template.textureType,
      template.textureWidth,
      template.textureHeight,
      tileWidth: template.tileWidth,
      tileHeight: template.tileHeight,
    )..kind = kind;
  }

  @override
  Future<void> recordExtractionMetadata(
    List<String> otrPaths,
    HashMap<String, TextureManifestEntry> entries,
  ) async {
    final wanted = <String, List<Tuple3<String, int, int>>>{};
    for (final key in entries.keys) {
      final match = _spriteChunkPattern.firstMatch(key);
      if (match == null) {
        continue;
      }
      wanted.putIfAbsent(match.group(1)!, () => []).add(Tuple3(
          key, int.parse(match.group(2)!), int.parse(match.group(3)!),),);
    }
    if (wanted.isEmpty) {
      return;
    }

    for (final otrPath in otrPaths) {
      final arcFile = Arc(otrPath);
      await arcFile.listItems(onFile: (String fileName, Uint8List data) async {
        final chunks = wanted[fileName];
        if (chunks == null) {
          return;
        }
        final tiles = parseSpriteTilePositions(data);
        if (tiles == null) {
          return;
        }
        for (final chunk in chunks) {
          final tile = tiles[Tuple2(chunk.item2, chunk.item3)];
          final entry = entries[chunk.item1];
          if (tile == null || entry == null) {
            continue;
          }
          final valid = tile.item1 > 0 &&
              tile.item2 > 0 &&
              tile.item1 <= entry.textureWidth &&
              tile.item2 <= entry.textureHeight &&
              (tile.item1 != entry.textureWidth ||
                  tile.item2 != entry.textureHeight);
          if (valid) {
            entry
              ..tileWidth = tile.item1
              ..tileHeight = tile.item2;
          }
        }
      },);
      arcFile.close();
    }
  }
}

Map<Tuple2<int, int>, Tuple2<int, int>>? parseSpriteTilePositions(
    Uint8List data) {
  final bytes = ByteData.sublistView(data);
  var offset = 0x40 + 10 + 4;
  if (data.length < offset + 4) {
    return null;
  }
  final positionCount = bytes.getUint32(offset, Endian.little);
  offset += 4;
  if (positionCount == 0 ||
      positionCount > 0x4000 ||
      data.length < offset + positionCount * 4 + 4) {
    return null;
  }
  final positions = <Tuple2<int, int>>[];
  for (var i = 0; i < positionCount; i++) {
    positions.add(Tuple2(
      bytes.getInt16(offset, Endian.little),
      bytes.getInt16(offset + 2, Endian.little),
    ),);
    offset += 4;
  }
  final frameCount = bytes.getUint32(offset, Endian.little);
  offset += 4;
  if (frameCount == 0 ||
      frameCount > 0x1000 ||
      data.length < offset + frameCount * 2) {
    return null;
  }
  final tiles = <Tuple2<int, int>, Tuple2<int, int>>{};
  var index = 0;
  for (var frame = 0; frame < frameCount; frame++) {
    final count = bytes.getUint16(offset + frame * 2, Endian.little);
    for (var chunk = 0; chunk < count; chunk++) {
      if (index < positions.length) {
        tiles[Tuple2(frame, chunk)] = positions[index];
      }
      index++;
    }
  }
  return tiles;
}
