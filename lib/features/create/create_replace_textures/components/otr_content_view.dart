
import 'package:flutter/material.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';

// ignore: non_constant_identifier_names
Widget OTRContent(CreateReplaceTexturesViewModel viewModel, BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final TextTheme textTheme = theme.textTheme;

  return Column(
    children: [
      Row(children: [
        Expanded(
            child: TextField(
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: viewModel.selectedOTRPath ?? 'OTR Path',
          ),
        )),
        const SizedBox(width: 12),
        ElevatedButton(
            onPressed: viewModel.onSelectOTR,
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 50)),
            child: const Text("Select"))
      ]),
      if (viewModel.processedFiles.isEmpty && viewModel.isProcessing == false)
          Expanded( child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Text(
                "Details",
                style: textTheme.headline5,
              ),
              Text("1. Select OTR that you want to replace textures from", style: textTheme.bodyMedium),
              Text("2. We extract texture assets as PNG with correct folder structure", style: textTheme.bodyMedium),
              Text("3. You replace the textures in that extraction folder", style: textTheme.bodyMedium),
              Text("4. Run this flow again and present your extraction folder", style: textTheme.bodyMedium),
              Text("5. We generate an OTR with the changed textures! 🚀", style: textTheme.bodyMedium),
            ],
          ))),
      if (viewModel.processedFiles.isNotEmpty || viewModel.isProcessing)
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: viewModel.isProcessing
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: viewModel.processedFiles.keys.length,
                prototypeItem: const SizedBox(width: 0, height: 20),
                itemBuilder: (context, index) {
                  return Text(viewModel.processedFiles.keys.elementAt(index));
                }))),
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: ElevatedButton(
          onPressed: viewModel.selectedOTRPath?.isEmpty == false && !viewModel.isProcessing && viewModel.processedFiles.isEmpty
            ? viewModel.processOTR : null,
          style: ElevatedButton.styleFrom(minimumSize: Size(
            MediaQuery.of(context).size.width * 0.5, 50)
          ),
          child: Text(viewModel.isProcessing ? 'Processing...' : viewModel.processedFiles.isNotEmpty ? 'Extracted ${viewModel.processedFiles.length} Textures' : 'Process')
        ))
    ],
  );
}