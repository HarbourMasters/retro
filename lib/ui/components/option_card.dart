import 'package:flutter/material.dart';

class OptionCard extends StatefulWidget {
  const OptionCard({
    super.key,
    required this.text,
    required this.icon,
    this.onMouseEnter,
    this.onMouseLeave,
    required this.onTap,
  });
  final String text;
  final IconData icon;
  final Function? onMouseEnter;
  final Function? onMouseLeave;
  final void Function() onTap;

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        MouseRegion(
          onEnter: (event) {
            setState(() {
              isHovered = true;
            });

            if (widget.onMouseEnter != null) {
              widget.onMouseEnter!();
            }
          },
          onExit: (event) {
            setState(() {
              isHovered = false;
            });
            if (widget.onMouseLeave != null) {
              widget.onMouseLeave!();
            }
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isHovered ? Colors.white24 : Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(80),
                child: Icon(
                  widget.icon,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.text,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
