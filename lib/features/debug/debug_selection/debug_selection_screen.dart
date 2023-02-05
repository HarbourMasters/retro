import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
        title: "Debug Selection",
        subtitle: "Looks like you're a developer. Select an option to debug.",
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        content: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OptionCard(
                      text: "Textures",
                      icon: Icons.texture,
                      onTap: () {
                        Navigator.of(context).pushNamed('/debug_convert_textures');
                      }),
                  const SizedBox(width: 20),
                  OptionCard(
                      text: "Font Generator",
                      icon: Icons.font_download,
                      onTap: () {
                        Navigator.of(context).pushNamed('/debug_generate_font');
                      }),
                ],
              )
            ])));
  }
}
