import 'package:retro/otr/types/texture.dart';

class TextureManifestEntry {

  TextureManifestEntry(this.hash, this.textureType, this.textureWidth, this.textureHeight);

  TextureManifestEntry.fromJson(Map<String, dynamic> json):
    hash = json['hash'],
    textureType = TextureType.fromValue(json['textureType']),
    textureWidth = json['textureWidth'],
    textureHeight = json['textureHeight'];
  String hash;
  TextureType textureType;
  int textureWidth, textureHeight;

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'textureType': textureType.value,
    'textureWidth': textureWidth,
    'textureHeight': textureHeight,
  };
}
