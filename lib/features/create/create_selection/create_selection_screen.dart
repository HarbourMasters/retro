import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/option_card.dart';

class CreateSelectionScreen extends StatefulWidget {
  const CreateSelectionScreen({super.key});

  @override
  _CreateSelectionScreenState createState() => _CreateSelectionScreenState();
}

class _CreateSelectionScreenState extends State<CreateSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
        title: i18n.createSelectionScreen_title,
        subtitle: i18n.createSelectionScreen_subtitle,
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        content: Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OptionCard(
                  text: i18n.createSelectionScreen_nonHdTex,
                  icon: Icons.texture,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_replace_textures');
                  },),
              const SizedBox(width: 20),
              OptionCard(
                  text: i18n.createSelectionScreen_customSequences,
                  icon: Icons.library_music,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_custom_sequences');
                  },),
              const SizedBox(width: 20),
              OptionCard(
                  text: i18n.createSelectionScreen_custom,
                  icon: Icons.settings_suggest,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_custom');
                  },),
            ],
          )
        ],),),);
  }
}
