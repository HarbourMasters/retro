import 'package:flutter/widgets.dart';

class OptionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onMouseEnter;
  final Function onMouseLeave;
  final Function onTap;

  const OptionCard({
    Key? key,
    required this.text,
    required this.icon,
    required this.onMouseEnter,
    required this.onMouseLeave,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text("OptionCard");
  }
}
