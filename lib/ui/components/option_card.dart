import 'package:flutter/material.dart';

class OptionCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function(bool) onHover;
  final Function onTap;

  const OptionCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.onHover,
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
        widget.onHover(true);
      },
      onExit:  (_) {
        setState(() {
          isHovered = false;
        });
        widget.onHover(false);
      },
      child: Container(
        width: 130,
        height: 160,
        child: const Icon(Icons.heart_broken),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isHovered ? Colors.white24 : Colors.white12,
        ),
      ),
    );
  }
}
