import 'package:retro/otr/types/texture.dart';

class TextureManifestEntry {
  String hash;
  TextureType textureType;

  TextureManifestEntry(this.hash, this.textureType);

  TextureManifestEntry.fromJson(Map<String, dynamic> json): hash = json['hash'], textureType = TextureType.fromValue(json['textureType']);

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'textureType': textureType.value,
  };
}
