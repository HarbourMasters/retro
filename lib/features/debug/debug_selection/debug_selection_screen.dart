import 'package:flutter/material.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/option_card.dart';

class DebugSelectionScreen extends StatefulWidget {
  const DebugSelectionScreen({super.key});

  @override
  _DebugSelectionScreenState createState() => _DebugSelectionScreenState();
}

class _DebugSelectionScreenState extends State<DebugSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Debug Selection',
      subtitle: 'This options are on an experimental state and may not work as expected',
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OptionCard(
                  text: 'Textures',
                  icon: Icons.texture,
                  onTap: () {
                    Navigator.of(context).pushNamed('/debug_convert_textures');
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
