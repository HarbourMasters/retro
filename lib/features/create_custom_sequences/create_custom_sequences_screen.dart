
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_custom_sequences/create_custom_sequences_viewmodel.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class CreateCustomSequencesScreen extends StatefulWidget {
  const CreateCustomSequencesScreen({super.key});

  @override
  _CreateCustomSequencesScreenState createState() => _CreateCustomSequencesScreenState();
}

class _CreateCustomSequencesScreenState extends State<CreateCustomSequencesScreen> {
  @override
  Widget build(BuildContext context) {
    final CreateCustomSequencesViewModel viewModel = Provider.of<CreateCustomSequencesViewModel>(context);
    final CreateFinishViewModel finishViewModel = Provider.of<CreateFinishViewModel>(context);

    String nameWithoutExtension(String path, String basePath) {
      return path.split("$basePath/").last.split('.').first;
    }

    return CustomScaffold(
        title: 'Add Custom Sequences',
        subtitle: 'Select a folder with sequences and meta files',
        onBackButtonPressed: () {
          viewModel.resetState();
          Navigator.of(context).pop();
        },
        content: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: viewModel.selectedFolderPath ?? 'Sequences Folder Path',
                  ),
                )),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: viewModel.onSelectFolder,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50)),
                    child: const Text("Select"))
              ]),
              if (viewModel.isProcessing || viewModel.sequenceMetaPairs.isNotEmpty)
                Expanded(
                    child: viewModel.isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                                itemCount: viewModel.sequenceMetaPairs.length,
                                prototypeItem: const SizedBox(width: 0, height: 20),
                                itemBuilder: (context, index) {
                                  return Text(nameWithoutExtension(viewModel.sequenceMetaPairs[index].item1.path, viewModel.selectedFolderPath!));
                                }))),
              if (!viewModel.isProcessing && viewModel.sequenceMetaPairs.isEmpty)
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child:
                    ElevatedButton(
                      onPressed: viewModel.sequenceMetaPairs.isNotEmpty ? () {
                        finishViewModel.onAddCustomSequenceEntry(viewModel.sequenceMetaPairs, 'custom/music');
                        viewModel.resetState();
                        Navigator.of(context).popUntil(ModalRoute.withName("/create_selection"));
                      } : null,
                      style: ElevatedButton.styleFrom(minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.5, 50)
                      ),
                      child: const Text('Stage Files')
                    )
                ),
            ])
        ))
      );
  }
}