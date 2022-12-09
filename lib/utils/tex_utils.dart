import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:retro/otr/types/texture.dart';

class RGBAPixel {
  int r, g, b, a;
  RGBAPixel(this.r, this.g, this.b, this.a);
}

int scale5_8(val) => (((val) * 0xFF) / 0x1F);

extension N64Graphics on Texture {

  Uint8List pixelsToPNG(Uint8List data){
    return Uint8List.fromList(encodePng(Image.fromBytes(width, height, data)).toList());
  }

  void convertPNGToN64(Uint8List image) {
    Image pngImage = decodeImage(image)!;
    width = pngImage.width;
    height = pngImage.height;
    switch(textureType){
      case TextureType.RGBA16bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            RGBAPixel pixel = pngImage.getRGBPixel(y, x);

            int r = pixel.r ~/ 8;
            int g = pixel.g ~/ 8;
            int b = pixel.b ~/ 8;

            bool alphaBit = pixel.a != 0;

            int data = (r << 11) + (g << 6) + (b << 1) + (alphaBit ? 1 : 0);

            texData[pos + 0] = (data & 0xFF00) >> 8;
            texData[pos + 1] = (data & 0x00FF);
          }
        }
        break;
      case TextureType.RGBA32bpp:
        texData = Uint8List.fromList(pngImage.getBytes(format: Format.rgba));
        texDataSize = texData.length;
        break;
      case TextureType.Palette4bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) ~/ 2;
            int r1 = pngImage.getIndexedPixel(y, x);
            int r2 = pngImage.getIndexedPixel(y, x + 1);

            texData[pos] = (r1 << 4) | (r2);
          }
        }
        break;
      case TextureType.Palette8bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x);
            texData[pos] = pngImage.getIndexedPixel(y, x);
          }
        }
        break;
      case TextureType.Grayscale4bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            int pos = ((y * width) + x) ~/ 2;
            int r1 = pngImage.getRGBPixel(y, x).r;
            int r2 = pngImage.getRGBPixel(y, x + 1).r;

            texData[pos] = (((r1 ~/ 16) << 4) + (r2 / 16)).toInt();
          }
        }
        break;
      case TextureType.Grayscale8bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = (y * width) + x;
            texData[pos] = pngImage.getRGBPixel(y, x).r;
          }
        }
        break;
      case TextureType.GrayscaleAlpha4bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            int pos = ((y * width) + x) ~/ 2;
            int data = 0;

            for (int i = 0; i < 2; i++) {
              RGBAPixel pixel = pngImage.getRGBPixel(y, x + i);
              int cR = pixel.r;
              int alphaBit = pixel.a != 0 ? 1 : 0;
              data |= i == 0 ? (((cR ~/ 32) << 1) + alphaBit) << 4 : ((cR ~/ 32) << 1) + alphaBit;
            }
            texData[pos] = data;
          }
        }
        break;
      case TextureType.GrayscaleAlpha8bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 1;
            RGBAPixel pixel = pngImage.getRGBPixel(y, x);
            texData[pos] = ((pixel.r ~/ 16) << 4) + (pixel.a ~/ 16);
          }
        }
        break;
      case TextureType.GrayscaleAlpha16bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            RGBAPixel pixel = pngImage.getRGBPixel(y, x);
            texData[pos]     = pixel.r;
            texData[pos + 1] = pixel.a;
          }
        }
        break;
      case TextureType.Error:
        throw Exception("Unknown texture type");
    }
  }

  Uint8List? convertN64ToPNG(){
    Image pngImage = Image(width, height);
    switch(textureType){
      case TextureType.RGBA32bpp:
        return pixelsToPNG(texData);
      case TextureType.RGBA16bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            int data = texData[pos + 1] | (texData[pos] << 8);
            int r = (data & 0xF800) >> 11;
            int g = (data & 0x07C0) >> 6;
            int b = (data & 0x003E) >> 1;
            int a = (data & 0x01);
            pngImage.setPixel(x, y, getColor(r * 8, g * 8, b * 8, a * 255));
          }
        }
        break;
      case TextureType.Palette4bpp:
        pngImage = Image.palette(width, height);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            for (int i = 0; i < 2; i++) {
              int pos = ((y * width) + x) ~/ 2;
              int paletteIndex = i == 0 ? (texData[pos] & 0xF0) >> 4 : texData[pos] & 0x0F;
              pngImage.setIndexedPixel(x + i, y, paletteIndex, paletteIndex * 16);
            }
          }
        }
        break;
      case TextureType.Palette8bpp:
        pngImage = Image.palette(width, height);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 1;
            int grayscale = texData[pos];
            pngImage.setIndexedPixel(x, y, grayscale, grayscale);
          }
        }
        break;
      case TextureType.Grayscale4bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            int pos = ((y * width) + x) ~/ 2;
            for(int i = 0; i < 2; i++){
              int v = i == 0 ? (texData[pos] & 0xF0) : texData[pos] & 0x0F << 4;
              pngImage.setPixel(x + i, y, getColor(v, v, v));
            }
          }
        }
        break;
      case TextureType.Grayscale8bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = (y * width) + x;
            pngImage.setPixel(x, y, getColor(texData[pos], texData[pos], texData[pos]));
          }
        }
        break;
      case TextureType.GrayscaleAlpha4bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            for (int i = 0; i < 2; i++) {
              int pos = ((y * width) + x) ~/ 2;
              int data = i == 0 ? (texData[pos] & 0xF0) >> 4 : texData[pos] & 0x0F;

              int grayscale = ((data & 0x0E) >> 1) * 32;
				      int alpha = (data & 0x01) * 255;

              pngImage.setPixel(x + i, y, getColor(grayscale, grayscale, grayscale, alpha));
            }
          }
        }
        break;
      case TextureType.GrayscaleAlpha8bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 1;
            int grayscale = texData[pos] & 0xF0;
			      int alpha = (texData[pos] & 0x0F) << 4;
            pngImage.setPixel(x, y, getColor(grayscale, grayscale, grayscale, alpha));
          }
        }
        break;
      case TextureType.GrayscaleAlpha16bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            int grayscale = texData[pos];
            int alpha     = texData[pos + 1];
            pngImage.setPixel(x, y, getColor(grayscale, grayscale, grayscale, alpha));
          }
        }
        break;
      default:
        return null;
    }

    if(isPalette && tlut != null){
      Image pal = decodePng(tlut!.toPNGBytes())!;

      for (int y = 0; y < pal.height; y++) {
        for (int x = 0; x < pal.width; x++) {
          int index = y * pal.width + x;
          if (index >= 16 * 16) {
            continue;
          }

          RGBAPixel pixel = pal.getRGBPixel(y, x);
          pngImage.setPaletteIndex(index, pixel.r, pixel.g, pixel.b, pixel.a);
        }
      }
    }

    return Uint8List.fromList(encodePng(pngImage).toList());
  }
}

extension PixelUtils on Image {
  RGBAPixel getRGBPixel(int y, int x) {
    int pixel = getPixel(x, y);
    return RGBAPixel(
      getRed(pixel),
      getGreen(pixel),
      getBlue(pixel),
      getAlpha(pixel),
    );
  }

  int getIndexedPixel(int y, int x) {
    try {
      return getRed(getPixel(x, y));
    } catch (e) {
      return 0;
    }
  }
}