import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Texture, Image;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/numpad.dart';

class DebugGeneratorFontScreen extends StatefulWidget {
  const DebugGeneratorFontScreen({super.key});

  @override
  State<DebugGeneratorFontScreen> createState() => _DebugGeneratorFontScreenState();
}

class _DebugGeneratorFontScreenState extends State<DebugGeneratorFontScreen> {
  String fontName = 'font';
  String? fontFamily;
  double textOffset = 0;
  double textScale = 1;
  int glyphWidth = 32;
  int glyphHeight = 32;
  int rows = 18;
  int columns = 32;

  void loadFont(File ttf) {
    final fontName = ttf.path.split(Platform.pathSeparator).last.split('.').first;
    final font = FontLoader(fontName);
    font.addFont(Future.value(ttf.readAsBytesSync().buffer.asByteData()));
    font.load();
    setState(() {
      fontFamily = fontName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
      title: i18n.sohCreateDebugFontScreen_title,
      subtitle: i18n.sohCreateDebugFontScreen_subtitle,
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Wrap(
                direction: Axis.vertical,
                spacing: 10,
                children: [
                  TextNumpad(
                    title: 'Text Offset:',
                    step: 0.5,
                    input: textOffset,
                    onInput: (num value) {
                      setState(() {
                        textOffset = value.toDouble();
                      });
                    },
                  ),
                  TextNumpad(
                    title: 'Text Scale:',
                    input: textScale,
                    step: 0.1,
                    onInput: (num value) {
                      setState(() {
                        textScale = value.toDouble();
                      });
                    },
                  ),
                  TextNumpad(
                    title: 'Glyph Width:',
                    input: glyphWidth,
                    onInput: (num value) {
                      setState(() {
                        glyphWidth = value.toInt();
                      });
                    },
                  ),
                  TextNumpad(
                    title: 'Glyph Height:',
                    input: glyphHeight,
                    onInput: (num value) {
                      setState(() {
                        glyphHeight = value.toInt();
                      });
                    },
                  ),
                  TextNumpad(
                    title: 'Rows:',
                    step: 1,
                    input: rows,
                    onInput: (num value) {
                      setState(() {
                        rows = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Load Font'),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['ttf', 'otf'],
                      );
                      if (result != null) {
                        loadFont(File(result.files.single.path!));
                      }
                    },
                  ),
                  if (fontFamily != null)
                  ElevatedButton(
                    onPressed: () async {
                      await writeFontTable(context);
                    },
                    child: const Text('Convert Texture'),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 119,
                padding: const EdgeInsets.only(top: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: fontFamily != null
                  ? CustomPaint(
                      painter: FontPainter(
                        fontFamily: fontFamily!,
                        offset: textOffset,
                        scale: textScale,
                        glyphWidth: glyphWidth,
                        glyphHeight: glyphHeight,
                        ht: rows,
                        vt: columns,
                      ),
                    )
                  : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> writeFontTable(BuildContext context) async {
    final recorder = ui.PictureRecorder();
    final width = glyphWidth * 8;
    final height = glyphHeight * 32;
    final finishViewModel = Provider.of<CreateFinishViewModel>(context, listen: false);
    FontPainter(
      fontFamily: fontFamily!,
      offset: textOffset,
      scale: textScale,
      glyphWidth: glyphWidth,
      glyphHeight: glyphHeight,
      drawGrid: false,
      ht: 8,
    ).paint(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    final tmpDir = await getTemporaryDirectory();
    final file = File('${tmpDir.path}/sGfxPrintFontData.png');

    await file.writeAsBytes(pngBytes!.buffer.asUint8List());
    finishViewModel.onAddFile(file, 'textures/font/sGfxPrintFontData');
    Navigator.of(context).popUntil(ModalRoute.withName('/create_selection'));
  }
}

class FontPainter extends CustomPainter {
  FontPainter({
    required this.fontFamily,
    this.offset = 0.0,
    this.scale = 1.0,
    this.glyphWidth = 32,
    this.glyphHeight = 32,
    this.drawGrid = true,
    this.ht = 18,
    this.vt = 32,
  });

  List<String> fontTable = [
    '0', '4', '1', '5', '2', '6', '3', '7',
    '8', 'C', '9', 'D', 'A', 'E', 'B', 'F',
    '0', '4', '1', '5', '2', '6', '3', '7',
    '8', '←', '9', '→', 'A', '↑', 'B', '↓',
    ' ', r'$', '!', '%', '"', '&', '#', "'",
    '(', ',', ')', '-', '*', '.', '+', '/',
    '0', '4', '1', '5', '2', '6', '3', '7',
    '8', '<', '9', '=', ':', '>', ';', '?',
    '@', 'D', 'A', 'E', 'B', 'F', 'C', 'G',
    'H', 'L', 'I', 'M', 'J', 'N', 'K', 'O',
    'P', 'T', 'Q', 'U', 'R', 'V', 'S', 'W',
    'X', '¥', 'Y', ']', 'Z', '^', '[', '_',
    "'", 'd', 'a', 'e', 'b', 'f', 'c', 'g',
    'h', 'l', 'i', 'm', 'j', 'n', 'k', 'o',
    'p', 't', 'q', 'u', 'r', 'v', 's', 'w',
    'x', ';', 'y', '}', 'z', '~', '{', '␡',
    ' ', ',', '.', ' ', ' ', ' ', ' ', ' ',
    'い', 'や', 'う', 'や', 'え', 'や', 'え', 'や',
    '-', 'え', 'あ', 'お', 'い', 'か', 'い', 'か',
    'く', 'し', 'け', 'チ', 'こ', 'せ', 'こ', 'せ',
    ' ', ',', ' ', '.', ' ', ' ', ' ', ' ',
    'イ', 'ヤ', 'ウ', 'コ', 'ェ', 'ヨ', 'エ', 'ッ',
    '-', 'エ', 'ア', 'オ', 'イ', 'カ', 'ウ', 'キ',
    'ワ', 'シ', 'ク', 'ス', 'コ', 'セ', 'サ', 'ン',
    'タ', 'ト', '子', 'ナ', 'ッ', 'ニ', 'テ', 'ヌ',
    'ネ', 'つ', 'ノ', 'へ', 'い', 'ホ', 'い', 'マ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    'リ', 'ワ', 'ル', 'ン', 'レ', '"', '口', 'ロ',
    ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
    'ね', 'ふ', 'の', 'へ', 'は', 'ほ', 'は', 'ま',
    'み', 'せ', 'せ', 'ゆ', 'の', 'よ', 'も', 'ら',
    ' ', 'わ', 'る', 'ん', 'れ', '"', 'ろ', 'ロ'
  ];

  final regExp = RegExp(r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
      "'" // <-- ' is added to the expression
      ']');

  final String fontFamily;
  final double offset;
  final double scale;
  final int glyphWidth;
  final int glyphHeight;
  final bool drawGrid;
  final int ht;
  final int vt;

  double convertFontSize(double size) => size / WidgetsBinding.instance.window.devicePixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var id = 0; id < vt * ht; id++) {
      final tx = (id % ht).floorToDouble();
      final ty = (id / ht).floorToDouble();
      final to = Offset(tx * glyphWidth, ty * glyphHeight);
      final rect = Rect.fromLTWH(to.dx, to.dy, glyphWidth.toDouble(), glyphHeight.toDouble());
      if (id >= fontTable.length) {
        continue;
      }
      final text = fontTable[id];
      if (drawGrid) {
        canvas.drawRect(rect, paint);
      }
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: text == ' ' && ty >= 16 ? '�' : text,
          style: TextStyle(
              color: Colors.white,
              fontSize: text == ' ' ? convertFontSize(20) : convertFontSize(text.contains(regExp) ? glyphHeight - 5 : glyphHeight.toDouble()) * scale,
              fontFamily: fontFamily),
        ),
      );
      textPainter.layout(maxWidth: size.width);
      textPainter.paint(
          canvas,
          Offset(tx * glyphWidth + (glyphWidth / 2) - (textPainter.size.width / 2),
              (ty * glyphHeight + (glyphHeight / 2) - (textPainter.size.height / 2)) - offset));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
