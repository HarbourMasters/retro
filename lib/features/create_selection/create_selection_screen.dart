import 'package:flutter/material.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

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
      content: const Center(
        child: Text('Create Selection Screen'),
      ),
    );
  }
}
