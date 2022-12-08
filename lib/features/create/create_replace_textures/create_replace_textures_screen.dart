import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/create/create_replace_textures/components/folder_content_view.dart';
import 'package:retro/features/create/create_replace_textures/components/otr_content_view.dart';
import 'package:retro/features/create/create_replace_textures/components/question_content_view.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class CreateReplaceTexturesScreen extends StatefulWidget {
  const CreateReplaceTexturesScreen({super.key});

  @override
  _CreateReplaceTexturesScreenState createState() =>
      _CreateReplaceTexturesScreenState();
}

class _CreateReplaceTexturesScreenState extends State<CreateReplaceTexturesScreen> {
  @override
  Widget build(BuildContext context) {
    final CreateReplaceTexturesViewModel viewModel = Provider.of<CreateReplaceTexturesViewModel>(context);
    final CreateFinishViewModel finishViewModel = Provider.of<CreateFinishViewModel>(context);
    final AppLocalizations i18n = AppLocalizations.of(context)!;

    return CustomScaffold(
      title: i18n.createReaplceTexturesOption,
      subtitle: i18n.createReaplceTexturesOptionDescription,
      onBackButtonPressed: () {
        viewModel.reset();
        Navigator.pop(context);
      },
      content: Expanded(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: stepContent(viewModel, finishViewModel, context))
      )
    );
  }
}

Widget stepContent(CreateReplaceTexturesViewModel viewModel, CreateFinishViewModel finishViewModel, BuildContext context) {
  switch (viewModel.currentStep) {
    case CreateReplacementTexturesStep.question:
      return QuestionContent(viewModel, context);
    case CreateReplacementTexturesStep.selectFolder:
      return FolderContent(viewModel, finishViewModel, context);
    case CreateReplacementTexturesStep.selectOTR:
      return OTRContent(viewModel, context);
  }
}
