import 'package:retro/otr/types/texture.dart';

class TextureManifestEntry {

  TextureManifestEntry(this.hash, this.textureType, this.textureWidth, this.textureHeight);

  TextureManifestEntry.fromJson(Map<String, dynamic> json):
    hash = json['hash'] as String,
    textureType = TextureType.fromValue(json['textureType'] as int),
    textureWidth = json['textureWidth'] as int,
    textureHeight = json['textureHeight'] as int;
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
