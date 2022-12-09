import 'package:retro/otr/types/texture.dart';

class TextureManifestEntry {
  String hash;
  Texture texture;

  TextureManifestEntry(this.hash, this.texture);

  TextureManifestEntry.fromJson(Map<String, dynamic> json): hash = json['hash'],
    texture = Texture.empty()..
      textureType = TextureType.fromValue(json['textureType'])..
      width = json['width']..
      height = json['height'];

  Map<String, dynamic> toJson() => {
    'hash': hash,
    'textureType': texture.textureType.value,
    'width': texture.width,
    'height': texture.height
  };
}
