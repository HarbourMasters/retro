import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_custom/create_custom_viewmodel.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class CreateCustomScreen extends StatefulWidget {
  const CreateCustomScreen({super.key});

  @override
  _CreateCustomScreenState createState() => _CreateCustomScreenState();
}

class _CreateCustomScreenState extends State<CreateCustomScreen> {
  final textFieldController = TextEditingController();

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final CreateCustomViewModel viewModel = Provider.of<CreateCustomViewModel>(context);
    final CreateFinishViewModel finishViewModel = Provider.of<CreateFinishViewModel>(context);

    return CustomScaffold(
      title: 'Via Path',
      subtitle: 'Select files to place at path',
      onBackButtonPressed: () {
        viewModel.onDiscardFiles();
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textFieldController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Path',
              ),
              onChanged: (String value) {
                viewModel.onPathChanged(value);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: OutlinedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true, type: FileType.any
                  );
                  if (result != null) {
                    viewModel.onSelectedFiles(result.paths
                      .map((path) => File(path!))
                      .toList()
                    );
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                child: const Text('Select Files')
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Files to insert: ${viewModel.files.length}',
                  style: textTheme.subtitle1,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.files.length,
                itemBuilder: (context, index) {
                  return Text(viewModel.files[index].path);
                }
              )
            ),
            ElevatedButton(
              onPressed: viewModel.files.isNotEmpty && viewModel.isPathValid ? () {
                finishViewModel.onStageFiles(viewModel.files, textFieldController.text);
                viewModel.onDiscardFiles();
                Navigator.of(context).popUntil(ModalRoute.withName("/create_selection"));
              } : null,
              style: ElevatedButton.styleFrom(minimumSize: Size(
                MediaQuery.of(context).size.width * 0.5, 50)
              ),
              child: const Text('Stage Files')
            ),
          ],
        )
      )
    ));
  }
}
