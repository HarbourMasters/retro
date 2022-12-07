
import 'package:flutter/material.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: non_constant_identifier_names
Widget OTRContent(CreateReplaceTexturesViewModel viewModel, BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final TextTheme textTheme = theme.textTheme;
  final AppLocalizations i18n = AppLocalizations.of(context)!;

  return Column(
    children: [
      Row(children: [
        Expanded(
            child: TextField(
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: viewModel.selectedOTRPath ?? i18n.otrReplaceTextures_otrPath,
          ),
        )),
        const SizedBox(width: 12),
        ElevatedButton(
            onPressed: viewModel.onSelectOTR,
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 50)),
            child: Text(i18n.otrReplaceTextures_otrSelect))
      ]),
      if (viewModel.processedFiles.isEmpty && viewModel.isProcessing == false)
          Expanded( child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Text(
                i18n.otrReplaceTextures_details,
                style: textTheme.headline5,
              ),
              Text(i18n.otrReplaceTextures_step1, style: textTheme.bodyMedium),
              Text(i18n.otrReplaceTextures_step2, style: textTheme.bodyMedium),
              Text(i18n.otrReplaceTextures_step3, style: textTheme.bodyMedium),
              Text(i18n.otrReplaceTextures_step4, style: textTheme.bodyMedium),
              Text(i18n.otrReplaceTextures_step5, style: textTheme.bodyMedium),
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
          child: Text(viewModel.isProcessing ? i18n.otrReplaceTextures_processing : viewModel.processedFiles.isNotEmpty ? 'Extracted ${viewModel.processedFiles.length} Textures' : 'Process') // TODO Better management of this for localization
        ))
    ],
  );
}