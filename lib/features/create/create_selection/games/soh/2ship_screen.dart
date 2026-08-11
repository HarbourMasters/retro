import 'package:flutter/material.dart';
import 'package:retro/l10n/app_localizations.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/option_card.dart';

class Ship2GameScreen extends StatefulWidget {
  const Ship2GameScreen({super.key});

  @override
  _Ship2GameScreenState createState() => _Ship2GameScreenState();
}

class _Ship2GameScreenState extends State<Ship2GameScreen> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
      title: i18n.gameSelectionScreen2Ship_title,
      subtitle: i18n.gameSelectionScreen2Ship_subtitle,
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
                  text: i18n.gameSelectionScreenSoh_title,
                  icon: Icons.extension,
                  onTap: () {
                    Navigator.of(context).pushNamed('/game_selection/soh');
                  },
                ),
                OptionCard(
                  text: i18n.gameSelectionScreen2Ship_title,
                  icon: Icons.music_note,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_replace_textures');
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
