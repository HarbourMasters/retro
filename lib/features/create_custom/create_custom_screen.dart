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
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final CreateCustomViewModel viewModel =
        Provider.of<CreateCustomViewModel>(context);
    final CreateFinishViewModel finishViewModel =
        Provider.of<CreateFinishViewModel>(context);
    final textFieldController = TextEditingController();

    @override
    void dispose() {
      textFieldController.dispose();
      super.dispose();
    }

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
                    ),
                    // submit button with solid background
                    const SizedBox(height: 12),
                    // elevated button with 200 width
                    OutlinedButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  allowMultiple: true, type: FileType.any);

                          if (result != null) {
                            viewModel.onSelectedFiles(result.paths
                                .map((path) => File(path!))
                                .toList());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50)),
                        child: const Text('Select Files')),
                    const SizedBox(height: 12),
                    // full width left aligned text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Files to insert: ${viewModel.files.length}',
                          style: textTheme.subtitle1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                        child: ListView.builder(
                            itemCount: viewModel.files.length,
                            itemBuilder: (context, index) {
                              return Text(viewModel.files[index].path);
                            })),
                    // 80% width submit button
                    if (viewModel.files.isNotEmpty)
                      ElevatedButton(
                          onPressed: () {
                            finishViewModel.onStageFiles(
                                viewModel.files, textFieldController.text);
                            viewModel.onDiscardFiles();
                            Navigator.of(context).popUntil(
                                ModalRoute.withName("/create_selection"));
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.5, 50)),
                          child: const Text('Stage Files')),
                  ],
                ))));
  }
}
