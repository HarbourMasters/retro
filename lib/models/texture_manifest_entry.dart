import 'package:retro/otr/types/texture.dart';

enum TextureEntryKind {
  replacement,
  additive,
  additiveFontGlyph,
}

// One row band of a texture too large for texture memory, so a dump has an image
// per band (Paper Mario's backgrounds). With cols it's one tile of a grid (its letters).
class TextureStrip {
  TextureStrip(this.y, this.rows, this.hashY, this.hashRows, {this.x = 0, this.cols});

  factory TextureStrip.fromJson(Map<String, dynamic> json) {
    final y = json['y'] as int;
    final rows = json['rows'] as int;
    return TextureStrip(
      y,
      rows,
      json['hashY'] as int? ?? y,
      json['hashRows'] as int? ?? rows,
      x: json['x'] as int? ?? 0,
      cols: json['cols'] as int?,
    );
  }

  final int y;
  final int rows;
  // What the dump covered, when the upload ran past the rows the band draws.
  final int hashY;
  final int hashRows;
  final int x;
  // Null for a band the full width of the texture.
  final int? cols;

  Map<String, dynamic> toJson() => {
    'y': y,
    'rows': rows,
    if (cols != null) 'x': x,
    if (cols != null) 'cols': cols,
    if (hashY != y) 'hashY': hashY,
    if (hashRows != rows) 'hashRows': hashRows,
  };
}

class TextureManifestEntry {

  TextureManifestEntry(this.hash, this.textureType, this.textureWidth, this.textureHeight, {this.tileWidth, this.tileHeight, this.strips});

  factory TextureManifestEntry.fromJson(Map<String, dynamic> json) {
    final strips = json['strips'] as List?;
    return TextureManifestEntry(
      json['hash'] as String,
      TextureType.values[json['textureType'] as int],
      json['textureWidth'] as int,
      json['textureHeight'] as int,
      tileWidth: json['tileWidth'] as int?,
      tileHeight: json['tileHeight'] as int?,
      strips: strips
          ?.map((strip) =>
              TextureStrip.fromJson(strip as Map<String, dynamic>),)
          .toList(),
    );
  }

  String hash;
  TextureType textureType;
  int textureWidth;
  int textureHeight;
  int? tileWidth;
  int? tileHeight;
  // Top to bottom, when the texture is uploaded in bands.
  List<TextureStrip>? strips;
  TextureEntryKind kind = TextureEntryKind.replacement;
  String? targetName;
  // Which band this staged image supplies, if it's only a band.
  int? stripIndex;
  // The size the base packs at. A palette variant is only drawn at that size.
  int? fitWidth;
  int? fitHeight;

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'textureType': textureType.value,
    'textureWidth': textureWidth,
    'textureHeight': textureHeight,
    if (tileWidth != null) 'tileWidth': tileWidth,
    if (tileHeight != null) 'tileHeight': tileHeight,
    if (strips != null)
      'strips': strips!.map((strip) => strip.toJson()).toList(),
  };
}
