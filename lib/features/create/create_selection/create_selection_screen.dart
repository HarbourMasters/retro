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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 15,
              children: [
                OptionCard(
                  text: i18n.createSelectionScreen_nonHdTex,
                  icon: Icons.texture,
                  overlay: Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.yellow[800]!.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                i18n.extractModsWarning_part1,
                                style: const TextStyle(color: Colors.white, fontSize: 10.5),
                              ),
                            ],
                          ),
                          Text(
                            i18n.extractModsWarning_part2,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_replace_textures');
                  },
                ),
                OptionCard(
                  text: i18n.gameSelectionScreen_title,
                  icon: Icons.videogame_asset_rounded,
                  onTap: () {
                    Navigator.of(context).pushNamed('/game_selection');
                  },
                ),
                OptionCard(
                  text: i18n.createSelectionScreen_custom,
                  icon: Icons.settings_suggest,
                  onTap: () {
                    Navigator.of(context).pushNamed('/create_custom');
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
