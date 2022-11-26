import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:retro/ui/theme/colors.dart';
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

    bool hasStagedFiles = viewModel.files.isNotEmpty;
    Color backgroundColor = hasStagedFiles ? Colors.green : Colors.blueAccent;
    bool isExpaned = viewModel.currentState == AppState.creationFinalization;

    return Stack(children: [
      AnimatedContainer(
        height: 24,
        duration: const Duration(milliseconds: 100),
        color: isExpaned ? RetroColors.blueBayoux : backgroundColor,
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
                    Text("state/${viewModel.displayState()}",
                        style: textTheme.bodyText2!
                            .copyWith(color: colorScheme.onSurface)),
                  ],
                )),
                if (hasStagedFiles && !isExpaned)
                  TextButton(
                      onPressed: () {
                        // Navigator.of(context).pushNamed('/create_finish');
                        if (viewModel.currentState ==
                            AppState.creationFinalization) {
                          viewModel.onCreationState();
                        } else {
                          viewModel.onCreationFinalizationState();
                        }
                      },
                      child: Text(
                        'Finalize OTR ⚡️',
                        style: textTheme.bodyText2!.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                      )),
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                      Text("Retro: 0.0.1",
                          style: textTheme.bodyText2!
                              .copyWith(color: colorScheme.onSurface)),
                      if (!isExpaned) const SizedBox(width: 4),
                      if (!isExpaned)
                        // TODO: Replace this one with Github icon
                        Material(
                            child: Container(
                                width: 24,
                                height: 24,
                                color: backgroundColor,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      if (!await launchUrl(
                                          Uri.parse(
                                              "https://github.com/HarbourMasters/retro"),
                                          mode:
                                              LaunchMode.externalApplication)) {
                                        throw "Could not launch URL";
                                      }
                                    },
                                    icon: const Icon(Icons.memory, size: 14))))
                    ])),
              ],
            )),
      ),
      if (isExpaned)
        Column(
          children: [
            const SizedBox(height: 24),
            // breaks if we use CustomScaffold here :(
            CustomScaffold(
                title: 'Finish',
                subtitle: 'Review your selection',
                onBackButtonPressed: () {
                  if (viewModel.currentState == AppState.creationFinalization) {
                    viewModel.onCreationState();
                  } else {
                    viewModel.onCreationFinalizationState();
                  }
                },
                content: const Text('Finish'))
          ],
        ),
    ]);
  }
}
