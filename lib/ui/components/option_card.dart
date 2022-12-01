import 'package:flutter/material.dart';

class OptionCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function? onMouseEnter;
  final Function? onMouseLeave;
  final void Function() onTap;

  const OptionCard({
    Key? key,
    required this.text,
    required this.icon,
    this.onMouseEnter,
    this.onMouseLeave,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      MouseRegion(
        onEnter: (event) {
          setState(() { isHovered = true; });

          if (widget.onMouseEnter != null) {
            widget.onMouseEnter!();
          }
        },
        onExit: (event) {
          setState(() { isHovered = false; });
          if (widget.onMouseLeave != null) {
            widget.onMouseLeave!();
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: isHovered ? Colors.white24 : Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
                child: Icon(
                  widget.icon,
                  size: 50,
                )),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(widget.text,
          style: textTheme.bodyText1
              ?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
    ]);
  }
}
