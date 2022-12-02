import 'package:flutter/material.dart';
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
    return CustomScaffold(
        title: 'Create Selection',
        subtitle: 'Select the type of selection you want to create',
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
                      text: "Custom Sequences",
                      icon: Icons.playlist_add,
                      onTap: () {
                        Navigator.of(context).pushNamed('/create_custom_sequences');
                      }),
                  const SizedBox(width: 20),
                  OptionCard(
                      text: "Custom",
                      icon: Icons.settings_suggest,
                      onTap: () {
                        Navigator.of(context).pushNamed('/create_custom');
                      }),
                ],
              )
            ])));
  }
}
