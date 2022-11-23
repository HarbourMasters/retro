import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_custom/create_custom_viewmodel.dart';
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
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final CreateCustomViewModel viewModel =
        Provider.of<CreateCustomViewModel>(context);

    return CustomScaffold(
        title: 'Via Path',
        subtitle: 'Select files to place at path',
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
        content: Expanded(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(
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
                  ],
                ))));
  }
}
