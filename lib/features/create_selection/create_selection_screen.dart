import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_selection/create_selection_viewmodel.dart';
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
    final CreateSelectionViewModel viewModel =
        Provider.of<CreateSelectionViewModel>(context);

    return CustomScaffold(
        title: 'Create Selection',
        subtitle: 'Select the type of selection you want to create',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        content: Column(children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OptionCard(
                  text: "Replace Models",
                  icon: Icons.switch_access_shortcut,
                  onMouseEnter: viewModel.onReplaceModelsCardFocused,
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {}),
              const SizedBox(width: 8),
              OptionCard(
                  text: "Custom",
                  icon: Icons.settings_suggest,
                  onMouseEnter: viewModel.onCustomCardFocused,
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {}),
            ],
          ),
        ]));
  }
}
