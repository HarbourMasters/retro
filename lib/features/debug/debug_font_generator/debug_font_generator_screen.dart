import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Texture, Image;
import 'package:flutter/services.dart';
import 'package:retro/features/debug/debug_font_generator/widgets/numpad.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;

class DebugGeneratorFontScreen extends StatefulWidget {
  const DebugGeneratorFontScreen({super.key});

  @override
  State<DebugGeneratorFontScreen> createState() => _DebugGeneratorFontScreenState();
}

class _DebugGeneratorFontScreenState extends State<DebugGeneratorFontScreen> {

  String fontName = "font";
  String? fontFamily;
  double textOffset = 0.0;
  double textScale = 1.0;
  int glyphWidth = 32;
  int glyphHeight = 32;

  void loadFont(File ttf){
    String fontName = ttf.path.split(Platform.pathSeparator).last.split('.').first;
    final font = FontLoader(fontName);
    font.addFont(Future.value(ttf.readAsBytesSync().buffer.asByteData()));
    font.load();
    setState(() {
      fontFamily = fontName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Debug Font Generator",
      subtitle: "Convert and generate fonts for the oot debug menu",
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  const Text("Font to OoT Generator",
                    style: TextStyle(color: Colors.white, fontFamily: 'GoogleSans', fontWeight: FontWeight.bold)
                  ),
                  TextNumpad(
                    title: "Text Offset:",
                    step: 0.5,
                    input: textOffset,
                    onInput: (num value) {
                      setState(() {
                        textOffset = value.toDouble();
                      });
                    },
                  ),
                  TextNumpad(
                    title: "Text Scale:",
                    input: textScale,
                    step: 0.1,
                    onInput: (num value) {
                      setState(() {
                        textScale = value.toDouble();
                      });
                    },
                  ),
                  TextNumpad(
                    title: "Glyph Width:",
                    input: glyphWidth,
                    onInput: (num value) {
                      setState(() {
                        glyphWidth = value.toInt();
                      });
                    },
                  ),
                  TextNumpad(
                    title: "Glyph Height:",
                    input: glyphHeight,
                    onInput: (num value) {
                      setState(() {
                        glyphHeight = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Load Font"),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom, allowedExtensions: ['ttf']
                      );
                      if (result != null) {
                        loadFont(File(result.files.single.path!));
                      }
                    }
                  ),
                  if (fontFamily != null)
                  ElevatedButton(
                    onPressed: writeFontTable,
                    child: const Text("Convert Texture")
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 119,
                padding: const EdgeInsets.only(top: 20, right: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: fontFamily != null ? CustomPaint(
                  painter: FontPainter(fontFamily: fontFamily!, offset: textOffset, scale: textScale, glyphWidth: glyphWidth, glyphHeight: glyphHeight),
                ) : null
              ),
            ),
          ],
        ),
      ),
    );
  }


  void writeFontTable() async {
    final recorder = ui.PictureRecorder();
    double width = glyphWidth * 8;
    double height = glyphHeight * 32;
    FontPainter(
      fontFamily: fontFamily!,
      offset: textOffset,
      scale: textScale,
      glyphWidth: glyphWidth,
      glyphHeight: glyphHeight,
      drawGrid: false
    ).paint(Canvas(recorder), Size(width, height));
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);

    String? result = await FilePicker.platform.saveFile(
      type: FileType.custom, allowedExtensions: ['png'], fileName: 'sGfxPrintFontData.png'
    );
    if (result != null) {
      await File(result).writeAsBytes(pngBytes!.buffer.asUint8List());
    }
  }

}

class FontPainter extends CustomPainter {

  List<List<String>> fontTable = [
    ['0', '4', '1', '5', '2', '6', '3', '7'],
    ['8', 'C', '9', 'D', 'A', 'E', 'B', 'F'],
    ['0', '4', '1', '5', '2', '6', '3', '7'],
    ['8', '←', '9', '→', 'A', '↑', 'B', '↓'],
    [' ', '\$', '!', '%', '"', '&', '#', '\''],
    ['(', ',', ')', '-', '*', '.', '+', '/'],
    ['0', '4', '1', '5', '2', '6', '3', '7'],
    ['8', '<', '9', '=', ':', '>', ';', '?'],
    ['@', 'D', 'A', 'E', 'B', 'F', 'C', 'G'],
    ['H', 'L', 'I', 'M', 'J', 'N', 'K', 'O'],
    ['P', 'T', 'Q', 'U', 'R', 'V', 'S', 'W'],
    ['X', '¥', 'Y', ']', 'Z', '^', '[', '_'],
    ['\'', 'd', 'a', 'e', 'b', 'f', 'c', 'g'],
    ['h', 'l', 'i', 'm', 'j', 'n', 'k', 'o'],
    ['p', 't', 'q', 'u', 'r', 'v', 's', 'w'],
    ['x', ';', 'y', '}', 'z', '~', '{', '␡'],
    [' ', ',', '.', ' ', ' ', ' ', ' ', ' '],
    ['い', 'や', 'う', 'や', 'え', 'や', 'え', 'や'],
    ['-', 'え', 'あ', 'お', 'い', 'か', 'い', 'か'],
    ['く', 'し', 'け', 'チ', 'こ', 'せ', 'こ', 'せ'],
    [' ', ',', ' ', '.', ' ', ' ', ' ', ' '],
    ['イ', 'ヤ', 'ウ', 'コ', 'ェ', 'ヨ', 'エ', 'ッ'],
    ['-', 'エ', 'ア', 'オ', 'イ', 'カ', 'ウ', 'キ'],
    ['ワ', 'シ', 'ク', 'ス', 'コ', 'セ', 'サ', 'ン'],
    ['タ', 'ト', '子', 'ナ', 'ッ', 'ニ', 'テ', 'ヌ'],
    ['ネ', 'つ', 'ノ', 'へ', 'い', 'ホ', 'い', 'マ'],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    ['リ', 'ワ', 'ル', 'ン', 'レ', '"', '口', 'ロ'],
    [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
    ['ね', 'ふ', 'の', 'へ', 'は', 'ほ', 'は', 'ま'],
    ['み', 'せ', 'せ', 'ゆ', 'の', 'よ', 'も', 'ら'],
    [' ', 'わ', 'る', 'ん', 'れ', '"', 'ろ', 'ロ']
  ];

  final regExp = RegExp(
    r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
    "'" // <-- ' is added to the expression
    ']'
  );

  final String fontFamily;
  final double offset;
  final double scale;
  final int glyphWidth;
  final int glyphHeight;
  final bool drawGrid;

  FontPainter({
    required this.fontFamily,
    this.offset = 0.0,
    this.scale = 1.0,
    this.glyphWidth = 32,
    this.glyphHeight = 32,
    this.drawGrid = true
  });

  double convertFontSize(double size) => (size / WidgetsBinding.instance.window.devicePixelRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for(double id = 0; id < 32 * 8; id++){
      double tx = (id % 8).floorToDouble();
      double ty = (id / 8).floorToDouble();
      Offset to = Offset(tx * glyphWidth, ty * glyphHeight);
      Rect rect = Rect.fromLTWH(to.dx, to.dy, glyphWidth.toDouble(), glyphHeight.toDouble());
      String text = fontTable[ty.toInt()][tx.toInt()];
      if(drawGrid){
        canvas.drawRect(rect, paint);
      }
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: text == ' ' && ty >= 16 ? '�' : text,
          style: TextStyle( color: Colors.white, fontSize: text == ' ' ? convertFontSize(20) : convertFontSize(text.contains(regExp) ? glyphHeight - 5 : glyphHeight.toDouble()) * scale, fontFamily: fontFamily ),
        ),
      );
      textPainter.layout( minWidth: 0, maxWidth: size.width );
      textPainter.paint(canvas, Offset(tx * glyphWidth + (glyphWidth / 2) - (textPainter.size.width / 2), (ty * glyphHeight + (glyphHeight / 2) - (textPainter.size.height / 2)) - offset));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}