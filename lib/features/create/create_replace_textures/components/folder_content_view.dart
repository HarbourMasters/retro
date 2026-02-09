import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:retro/l10n/app_localizations.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:retro/models/texture_manifest_entry.dart';
import 'package:tuple/tuple.dart';

// ignore: non_constant_identifier_names
Widget FolderContent(
  CreateReplaceTexturesViewModel viewModel,
  CreateFinishViewModel finishViewModel,
  BuildContext context,
) {
  final i18n = AppLocalizations.of(context)!;
  return Column(
    children: [
      Row(children: [
        Expanded(
            child: TextField(
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: viewModel.selectedFolderPath ??
                i18n.folderContentView_customTexturePath,
          ),
        ),),
        const SizedBox(width: 12),
        ElevatedButton(
            onPressed: viewModel.onSelectFolder,
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 50)),
            child: Text(i18n.folderContentView_selectButton),)
      ],),
      const SizedBox(height: 10),
      Row(children: [
        Switch(
          activeColor: Colors.blue,
          value: finishViewModel.prependAlt,
          onChanged: (value) {
            finishViewModel.onTogglePrependAlt(value);
          },
        ),
        Text(i18n.folderContentView_prependAltToggle),
      ],),
      Row(children: [
        Switch(
          activeColor: Colors.blue,
          value: finishViewModel.compressFiles,
          onChanged: (value) {
            finishViewModel.onToggleCompressFiles(value);
          },
        ),
        Text(i18n.folderContentView_compressToggle),
      ],),
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
                  final key = viewModel.processedFiles.keys.elementAt(index);
                  // ignore: avoid_dynamic_calls
                  return Text("${finishViewModel.prependAlt ? 'alt/' : ''}$key (${viewModel.processedFiles[key]?.length ?? 0} tex)");
                },),),),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ElevatedButton(
          onPressed: viewModel.processedFiles.isNotEmpty ? () {
            finishViewModel.onAddCustomTextureEntry(viewModel.processedFiles as HashMap<String, List<Tuple2<File, TextureManifestEntry>>>);
            viewModel.reset();
            Navigator.of(context).popUntil(ModalRoute.withName('/create_selection'));
          } : null,
          style: ElevatedButton.styleFrom(minimumSize: Size(
            MediaQuery.of(context).size.width * 0.5, 50,),
          ),
          child: Text(i18n.folderContentView_stageTextures),
        ),)
    ],
  );
}
