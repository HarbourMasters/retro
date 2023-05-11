import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:retro/otr/types/texture.dart';

extension N64Pixel on Image {
  void setGrayscalePixel(int x, int y, int grayscale, {int alpha = 0}) {
    if (numChannels == 4) {
      setPixelRgba(x, y, grayscale, grayscale, grayscale, alpha);
    } else {
      setPixelRgb(x, y, grayscale, grayscale, grayscale);
    }
  }
}

extension N64Graphics on Texture {
  Uint8List pixelsToPNG(Uint8List data) {
    return encodePng(
      Image.fromBytes(
        width: width,
        height: height,
        bytes: data.buffer,
        numChannels: 4,
      ),
    ).buffer.asUint8List();
  }

  void convertRawToN64(Image image) {
    width = image.width;
    height = image.height;
    texDataSize = textureType.getBufferSize(width, height);
    texData = Uint8List(texDataSize);

    switch (textureType) {
      case TextureType.RGBA16bpp:
        for (final pixel in image) {
          final pos = ((pixel.y * width) + pixel.x) * 2;
          final r = pixel.r ~/ 8;
          final g = pixel.g ~/ 8;
          final b = pixel.b ~/ 8;

          final alphaBit = pixel.a != 0;

          final data = (r << 11) + (g << 6) + (b << 1) + (alphaBit ? 1 : 0);

          texData[pos + 0] = (data & 0xFF00) >> 8;
          texData[pos + 1] = data & 0x00FF;
        }
        break;
      case TextureType.RGBA32bpp:
        final mod = (image.bitsPerChannel == 16 ? 256 : 1);
        switch (image.numChannels) {
          case 1:
            for (final pixel in image) {
              final pos = ((pixel.y * width) + pixel.x) * 4;
              final g = pixel.r ~/ mod;
              texData[pos + 0] = g;
              texData[pos + 1] = g;
              texData[pos + 2] = g;
              texData[pos + 3] = 0xFF;
            }
            break;
          case 2:
            for (final pixel in image) {
              final pos = ((pixel.y * width) + pixel.x) * 4;
              final g = pixel.r ~/ mod;
              texData[pos + 0] = g;
              texData[pos + 1] = g;
              texData[pos + 2] = g;
              texData[pos + 3] = pixel.g ~/ mod;
            }
            break;
          case 3:
            for (final pixel in image) {
              final pos = ((pixel.y * width) + pixel.x) * 4;
              texData[pos + 0] = pixel.r ~/ mod;
              texData[pos + 1] = pixel.g ~/ mod;
              texData[pos + 2] = pixel.b ~/ mod;
              texData[pos + 3] = 0xFF;
            }
            break;
          case 4:
            for (final pixel in image) {
              final pos = ((pixel.y * width) + pixel.x) * 4;
              texData[pos + 0] = pixel.r ~/ mod;
              texData[pos + 1] = pixel.g ~/ mod;
              texData[pos + 2] = pixel.b ~/ mod;
              texData[pos + 3] = pixel.a ~/ mod;
            }
            break;
        }
        break;
      case TextureType.Palette4bpp:
        for (final pixel in image) {
          final pos = ((pixel.y * width) + pixel.x) ~/ 2;
          final cr1 = pixel.index.toInt();
          final cr2 = image.getPixelSafe(pixel.x + 1, pixel.y).index.toInt();

          texData[pos] = (cr1 << 4) | cr2;
        }
        break;
      case TextureType.Palette8bpp:
        for (final pixel in image) {
          final pos = (pixel.y * width) + pixel.x;
          texData[pos] = pixel.index.toInt();
        }
        break;
      case TextureType.Grayscale4bpp:
        for (final pixel in image) {
          final pos = ((pixel.y * width) + pixel.x) ~/ 2;
          final r1 = pixel.r.toInt();
          final r2 = image.getPixelSafe(pixel.x + 1, pixel.y).r.toInt();

          texData[pos] = (((r1 ~/ 16) << 4) + (r2 / 16)).toInt();
        }
        break;
      case TextureType.Grayscale8bpp:
        for (final pixel in image) {
          final pos = (pixel.y * width) + pixel.x;
          texData[pos] = pixel.r.toInt();
        }
        break;
      case TextureType.GrayscaleAlpha4bpp:
        for (final pixel in image) {
          final pos = ((pixel.y * width) + pixel.x) ~/ 2;
          final nextPixel = image.getPixelSafe(pixel.x + 1, pixel.y);

          final cR1 = pixel.r.toInt();
          final cR2 = nextPixel.r.toInt();

          final alphaBit1 = pixel.a != 0 ? 1 : 0;
          final alphaBit2 = nextPixel.a != 0 ? 1 : 0;

          var data = (((cR1 ~/ 32) << 1) + alphaBit1) << 4;
          data |= ((cR2 ~/ 32) << 1) + alphaBit2;

          texData[pos] = data;
        }
        break;
      case TextureType.GrayscaleAlpha8bpp:
        for (final pixel in image) {
          final pos = (pixel.y * width) + pixel.x;
          texData[pos] = ((pixel.r ~/ 16) << 4) + (pixel.a ~/ 16);
        }
        break;
      case TextureType.GrayscaleAlpha16bpp:
        for (final pixel in image) {
          final pos = ((pixel.y * width) + pixel.x) * 2;
          texData[pos] = pixel.r.toInt();
          texData[pos + 1] = pixel.a.toInt();
        }
        break;
      case TextureType.Error:
        throw Exception('Unknown texture type');
    }
  }

  Uint8List? convertN64ToPNG() {
    var image = Image(
      width: width,
      height: height,
      numChannels: hasAlpha ? 4 : 3,
      withPalette: isPalette,
    );
    switch (textureType) {
      case TextureType.RGBA32bpp:
        image = Image.fromBytes(
          width: width,
          height: height,
          bytes: texData.buffer,
          numChannels: 4,
        );
        break;
      case TextureType.RGBA16bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            final pos = ((y * width) + x) * 2;
            final data = texData[pos + 1] | (texData[pos] << 8);
            final r = (data & 0xF800) >> 11;
            final g = (data & 0x07C0) >> 6;
            final b = (data & 0x003E) >> 1;
            final a = data & 0x01;
            image.setPixel(x, y, ColorInt8.rgba(r * 8, g * 8, b * 8, a * 255));
          }
        }
        break;
      case TextureType.Palette4bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x += 2) {
            for (var i = 0; i < 2; i++) {
              final pos = ((y * width) + x) ~/ 2;
              final paletteIndex =
                  i == 0 ? (texData[pos] & 0xF0) >> 4 : texData[pos] & 0x0F;
              image.setPixelR(x + i, y, paletteIndex);
              image.palette!.setRgba(
                paletteIndex,
                paletteIndex * 16,
                paletteIndex * 16,
                paletteIndex * 16,
                255,
              );
            }
          }
        }
        break;
      case TextureType.Palette8bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            final pos = (y * width) + x;
            final grayscale = texData[pos];
            image.setPixelR(x, y, grayscale);
            image.palette!
                .setRgba(grayscale, grayscale, grayscale, grayscale, 255);
          }
        }
        break;
      case TextureType.Grayscale4bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x += 2) {
            for (var i = 0; i < 2; i++) {
              final pos = ((y * width) + x) ~/ 2;
              final grayscale =
                  i == 0 ? (texData[pos] & 0xF0) : (texData[pos] & 0x0F) << 4;
              image.setGrayscalePixel(x + i, y, grayscale);
            }
          }
        }
        break;
      case TextureType.Grayscale8bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            final pos = (y * width) + x;
            image.setGrayscalePixel(x, y, texData[pos]);
          }
        }
        break;
      case TextureType.GrayscaleAlpha4bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x += 2) {
            for (var i = 0; i < 2; i++) {
              final pos = ((y * width) + x) ~/ 2;
              final data =
                  i == 0 ? (texData[pos] & 0xF0) >> 4 : texData[pos] & 0x0F;

              final grayscale = ((data & 0x0E) >> 1) * 32;
              final alpha = (data & 0x01) * 255;

              image.setGrayscalePixel(x + i, y, grayscale, alpha: alpha);
            }
          }
        }
        break;
      case TextureType.GrayscaleAlpha8bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            final pos = ((y * width) + x) * 1;
            final grayscale = texData[pos] & 0xF0;
            final alpha = (texData[pos] & 0x0F) << 4;
            image.setGrayscalePixel(x, y, grayscale, alpha: alpha);
          }
        }
        break;
      case TextureType.GrayscaleAlpha16bpp:
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            final pos = ((y * width) + x) * 2;
            final grayscale = texData[pos];
            final alpha = texData[pos + 1];
            image.setGrayscalePixel(x, y, grayscale, alpha: alpha);
          }
        }
        break;
      default:
        return null;
    }

    if (isPalette && tlut != null) {
      final pal = decodePng(tlut!.toPNGBytesSync())!;

      for (var y = 0; y < pal.height; y++) {
        for (var x = 0; x < pal.width; x++) {
          final index = y * pal.width + x;
          if (index >= 16 * 16) {
            continue;
          }

          final pixel = pal.getPixel(x, y);
          image.palette!.setRgba(index, pixel.r, pixel.g, pixel.b, pixel.a);
        }
      }
    }

    return encodePng(image);
  }

  bool get hasAlpha =>
      isPalette ||
      textureType == TextureType.RGBA32bpp ||
      textureType == TextureType.RGBA16bpp ||
      textureType == TextureType.GrayscaleAlpha16bpp ||
      textureType == TextureType.GrayscaleAlpha8bpp ||
      textureType == TextureType.GrayscaleAlpha4bpp;
}
