import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/option_card.dart';

class SOHGameScreen extends StatefulWidget {
  const SOHGameScreen({super.key});

  @override
  _SOHGameScreenState createState() => _SOHGameScreenState();
}

class _SOHGameScreenState extends State<SOHGameScreen> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
      title: i18n.gameSelectionScreenSoh_title,
      subtitle: i18n.gameSelectionScreenSoh_subtitle,
      onBackButtonPressed: () {
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 15,
              alignment: WrapAlignment.center,
              children: [
                OptionCard(
                  text: i18n.createSelectionScreen_customSequences,
                  icon: Icons.library_music,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_custom_sequences');
                  },
                ),
                OptionCard(
                  text: i18n.sohCreateDebugFontScreen_title,
                  icon: FontAwesomeIcons.font,
                  onTap: () {
                    Navigator.of(context).pushNamed('/debug_generate_font');
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
