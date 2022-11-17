import 'package:flutter/material.dart';

class OptionCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function onMouseEnter;
  final Function onMouseLeave;
  final void Function() onTap;

  const OptionCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.onMouseEnter,
    required this.onMouseLeave,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> {

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
        widget.onMouseEnter();
      },
      onExit:  (_) {
        setState(() {
          isHovered = false;
        });
        widget.onMouseLeave();
      },
      child: InkWell(
        enableFeedback: true,
        onTap: widget.onTap,
        child: Container(
          width: 130,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isHovered ? Colors.white24 : Colors.white12,
          ),
          child: const Icon(Icons.compress, size: 50),
        ),
      ),
    );
  }
}
