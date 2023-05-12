import 'package:flutter/material.dart';

class TextNumpad extends StatefulWidget {

  const TextNumpad({ required this.input, required this.onInput, this.title, this.step = 1.0, super.key });

  final String? title;
  final num input;
  final num step;
  final Function(num) onInput;

  @override
  State<TextNumpad> createState() => _TextNumpadState();
}

class _TextNumpadState extends State<TextNumpad> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      spacing: 10,
      children: [
        Text(
          widget.title ?? '${widget.input}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('-'),
              onPressed: () {
                widget.onInput(widget.input - widget.step);
              },
            ),
            // The text that will be displayed
            Text(
              widget.input.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              child: const Text('+'),
              onPressed: () {
                widget.onInput(widget.input + widget.step);
              },
            ),
          ],
        ),
      ],
    );
  }
}