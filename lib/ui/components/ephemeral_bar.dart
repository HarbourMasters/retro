import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create/create_finish/create_finish_screen.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class EphemeralBar extends StatefulWidget {
  const EphemeralBar({super.key});

  @override
  State<EphemeralBar> createState() => _EphemeralBarState();
}

class _EphemeralBarState extends State<EphemeralBar>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  void prepareAnimations() {
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500),);
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final viewModel =
        Provider.of<CreateFinishViewModel>(context);
    final i18n = AppLocalizations.of(context)!;

    final hasStagedFiles = viewModel.entries.isNotEmpty;
    final Color backgroundColor = hasStagedFiles ? Colors.green : Colors.blueAccent;
    final isExpanded = viewModel.isEphemeralBarExpanded;

    final Widget bottomBar = AnimatedContainer(
      width: MediaQuery.of(context).size.width,
      height: 24,
      duration: const Duration(milliseconds: 100),
      color: isExpanded ? RetroColors.blueBayoux : backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.gamepad, size: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text('state/${viewModel.displayState()}',
                      style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            if (hasStagedFiles && !isExpanded)
            TextButton(
              onPressed: () {
                viewModel.toggleEphemeralBar();
                expandController.forward();
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  i18n.components_ephemeralBar_finalizeOtr,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Retro: 0.1.1', style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface,),
                  ),
                  if (!isExpanded)
                  // TODO: Replace this one with Github icon
                  Material(
                    child: Container(
                      width: 24,
                      height: 24,
                      color: backgroundColor,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (!await launchUrl(Uri.parse('https://github.com/HarbourMasters/retro'), mode: LaunchMode.externalApplication)) {
                            throw 'Could not launch URL';
                          }
                        },
                        icon: const Icon(Icons.memory, size: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final size = MediaQuery.of(context).size;
    return SizedBox.fromSize(
        size: Size(size.width, max(size.height * animation.value, 24)),
        child: CreateFinishBottomBarModal(
            bottomBar: bottomBar, dismissCallback: () {
              expandController.reverse();
              viewModel.toggleEphemeralBar();
            },),);
  }
}
