import 'package:flutter/material.dart';

class CreateSelectionScreen extends StatefulWidget {
  const CreateSelectionScreen({super.key});

  @override
  _CreateSelectionScreenState createState() => _CreateSelectionScreenState();
}

class _CreateSelectionScreenState extends State<CreateSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Create Selection Screen"),
      ),
    );
  }
}
