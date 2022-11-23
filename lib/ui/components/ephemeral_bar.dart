import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class EphemeralBar extends StatefulWidget {
  const EphemeralBar({Key? key}) : super(key: key);

  @override
  State<EphemeralBar> createState() => _EphemeralBarState();
}

class _EphemeralBarState extends State<EphemeralBar> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final CreateFinishViewModel viewModel =
        Provider.of<CreateFinishViewModel>(context);

    return Container(
      height: 24,
      color: Colors.blueAccent,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.gamepad, size: 14),
                  const SizedBox(width: 4),
                  Text("state/${viewModel.currentState.name}",
                      style: textTheme.bodyText2!
                          .copyWith(color: colorScheme.onSurface)),
                ],
              )),
              Expanded(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text("Retro: 0.0.1",
                    style: textTheme.bodyText2!
                        .copyWith(color: colorScheme.onSurface)),
                const SizedBox(width: 4),
                // TODO: Replace this one with Github icon
                Material(
                    child: Container(
                        width: 24,
                        height: 24,
                        color: Colors.blueAccent,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              // open Github link
                              if (!await launchUrl(
                                  Uri.parse(
                                      "https://github.com/HarbourMasters/retro"),
                                  mode: LaunchMode.externalApplication)) {
                                throw "Could not launch URL";
                              }
                            },
                            icon: const Icon(Icons.memory, size: 14))))
              ])),
            ],
          )),
    );
  }
}
