import 'package:retro/otr/types/texture.dart';

class TextureManifestEntry {

  TextureManifestEntry(this.hash, this.textureType, this.textureWidth, this.textureHeight);

  factory TextureManifestEntry.fromJson(dynamic json) {
    return TextureManifestEntry(
      json['hash'] as String,
      TextureType.values[json['textureType'] as int],
      json['textureWidth'] as int,
      json['textureHeight'] as int,
    );
  }

  String hash;
  TextureType textureType;
  int textureWidth;
  int textureHeight;

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'textureType': textureType.value,
    'textureWidth': textureWidth,
    'textureHeight': textureHeight,
  };
}
