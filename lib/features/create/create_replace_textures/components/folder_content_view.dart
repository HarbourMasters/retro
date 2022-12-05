import 'package:flutter/material.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:retro/otr/utils/language_ext.dart';

// ignore: non_constant_identifier_names
Widget FolderContent(
  CreateReplaceTexturesViewModel viewModel,
  CreateFinishViewModel finishViewModel,
  BuildContext context,
) {
  return Column(
    children: [
      Row(children: [
        Expanded(
            child: TextField(
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: viewModel.selectedFolderPath ??
                'Custom Texture Replacements Folder',
          ),
        )),
        const SizedBox(width: 12),
        ElevatedButton(
            onPressed: viewModel.onSelectFolder,
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 50)),
            child: const Text("Select"))
      ]),
      if (viewModel.processedFiles.isEmpty && viewModel.isProcessing == false)
        const Spacer(),
      if (viewModel.processedFiles.isNotEmpty || viewModel.isProcessing)
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: viewModel.isProcessing
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: viewModel.processedFiles.keys.length,
                prototypeItem: const SizedBox(width: 0, height: 20),
                itemBuilder: (context, index) {
                  String key = viewModel.processedFiles.keys.elementAt(index);
                  return Text("$key (${viewModel.processedFiles[key]?.length ?? 0} tex)");
                }))),
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: ElevatedButton(
          onPressed: viewModel.processedFiles.isNotEmpty ? () {
            finishViewModel.onAddCustomTextureEntry(cast(viewModel.processedFiles));
            viewModel.reset();
            Navigator.of(context).popUntil(ModalRoute.withName("/create_selection"));
          } : null,
          style: ElevatedButton.styleFrom(minimumSize: Size(
            MediaQuery.of(context).size.width * 0.5, 50)
          ),
          child: const Text('Stage Textures')
        ))
    ],
  );
}
