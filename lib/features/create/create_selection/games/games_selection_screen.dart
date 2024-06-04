import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/components/option_card.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  _GameSelectionScreenState createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    return CustomScaffold(
      title: i18n.gameSelectionScreen_title,
      subtitle: i18n.gameSelectionScreen_subtitle,
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
                  icon: Icons.directions_boat_filled_rounded,
                  onTap: () {
                    Navigator.of(context).pushNamed('/game_selection/soh');
                  },
                ),
                OptionCard(
                  text: i18n.gameSelectionScreen2Ship_title,
                  icon: Icons.dark_mode,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: const Color.fromARGB(255, 249, 210, 144),
                      content: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 5),
                          Text(i18n.gameSelection2ShipComingSoon_text, style: const TextStyle(color: Colors.black, fontSize: 16)),
                        ],
                      ),
                    ));
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
