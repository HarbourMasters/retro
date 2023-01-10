import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:retro/otr/types/texture.dart';

extension N64Graphics on Texture {

  Uint8List pixelsToPNG(Uint8List data){
    return encodePng(Image.fromBytes(width: width, height: height, bytes: data.buffer, numChannels: 4)).buffer.asUint8List();
  }

  void convertPNGToN64(Uint8List image) {
    Image pngImage = decodeImage(image)!;

    if (isPalette && !pngImage.hasPalette) {
      textureType = TextureType.RGBA32bpp;
    }

    width = pngImage.width;
    height = pngImage.height;
    switch(textureType){
      case TextureType.RGBA16bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            Pixel pixel = pngImage.getPixel(x, y);

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
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            Pixel pixel = pngImage.getPixel(x, y);
            int pos = ((y * width) + x) * 4;
            texData[pos]     = pixel.r.toInt();
            texData[pos + 1] = pixel.g.toInt();
            texData[pos + 2] = pixel.b.toInt();
            texData[pos + 3] = pixel.a.toInt();
          }
        }
        break;
      case TextureType.Palette4bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) ~/ 2;
            int r1 = pngImage.getPixel(x, y).index.toInt();
            int r2 = pngImage.getPixel(x + 1, y).index.toInt();

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
            texData[pos] = pngImage.getPixel(x, y).index.toInt();
          }
        }
        break;
      case TextureType.Grayscale4bpp:
        texDataSize = textureType.getBufferSize(width, height);
        texData = Uint8List(texDataSize);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            int pos = ((y * width) + x) ~/ 2;
            int r1 = pngImage.getPixel(x, y).r.toInt();
            int r2 = pngImage.getPixel(x + 1, y).r.toInt();

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
            texData[pos] = pngImage.getPixel(x, y).r.toInt();
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
              Pixel pixel = pngImage.getPixel(x + i, y);
              int cR = pixel.r.toInt();
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
            Pixel pixel = pngImage.getPixel(x, y);
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
            Pixel pixel = pngImage.getPixel(x, y);
            texData[pos]     = pixel.r.toInt();
            texData[pos + 1] = pixel.a.toInt();
          }
        }
        break;
      case TextureType.Error:
        throw Exception("Unknown texture type");
    }
  }

  Uint8List? convertN64ToPNG(){
    Image pngImage = Image(width: width, height: height, numChannels: hasAlpha ? 4 : 3, withPalette: isPalette);
    switch(internalTextureType){
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
            pngImage.setPixel(x, y, ColorInt8.rgba(r * 8, g * 8, b * 8, a * 255));
          }
        }
        break;
      case TextureType.Palette4bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            for (int i = 0; i < 2; i++) {
              int pos = ((y * width) + x) ~/ 2;
              int paletteIndex = i == 0 ? (texData[pos] & 0xF0) >> 4 : texData[pos] & 0x0F;
              pngImage.palette!.setRgba(paletteIndex, paletteIndex * 16, paletteIndex * 16, paletteIndex * 16, 255);
              pngImage.setPixel(x + i, y, ColorInt8.rgb(paletteIndex, 0, 0));
            }
          }
        }
        break;
      case TextureType.Palette8bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 1;
            int grayscale = texData[pos];
            pngImage.palette!.setRgba(grayscale, grayscale, grayscale, grayscale, 255);
            pngImage.setPixel(x, y, ColorInt8.rgb(grayscale, 0, 0));
          }
        }
        break;
      case TextureType.Grayscale4bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x += 2) {
            int pos = ((y * width) + x) ~/ 2;
            for(int i = 0; i < 2; i++){
              int v = i == 0 ? (texData[pos] & 0xF0) : texData[pos] & 0x0F << 4;
              pngImage.setPixel(x + i, y, ColorInt8.rgb(v, v, v));
            }
          }
        }
        break;
      case TextureType.Grayscale8bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = (y * width) + x;
            pngImage.setPixel(x, y, ColorInt8.rgb(texData[pos], texData[pos], texData[pos]));
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
              pngImage.setPixel(x + i, y, ColorInt8.rgba(grayscale, grayscale, grayscale, alpha));
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
            pngImage.setPixel(x, y, ColorInt8.rgba(grayscale, grayscale, grayscale, alpha));
          }
        }
        break;
      case TextureType.GrayscaleAlpha16bpp:
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            int pos = ((y * width) + x) * 2;
            int grayscale = texData[pos];
            int alpha     = texData[pos + 1];
            pngImage.setPixel(x, y, ColorInt8.rgba(grayscale, grayscale, grayscale, alpha));
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

          Pixel pixel = pal.getPixel(x, y);
          pngImage.palette!.setRgba(index, pixel.r, pixel.g, pixel.b, pixel.a);
        }
      }
    }

    return Uint8List.fromList(encodePng(pngImage).toList());
  }

  bool isValid(Uint8List data) {
    if (isPalette && !decodePng(data)!.hasPalette) {
      return false;
    }

    return true;
  }

  bool get hasAlpha =>
    isPalette || textureType == TextureType.RGBA32bpp || textureType == TextureType.RGBA16bpp || textureType == TextureType.GrayscaleAlpha16bpp || textureType == TextureType.GrayscaleAlpha8bpp || textureType == TextureType.GrayscaleAlpha4bpp;

}