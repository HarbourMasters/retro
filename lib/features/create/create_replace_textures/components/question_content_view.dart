import 'package:flutter/material.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: non_constant_identifier_names
Widget QuestionContent(CreateReplaceTexturesViewModel viewModel, BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final TextTheme textTheme = theme.textTheme;
  final AppLocalizations i18n = AppLocalizations.of(context)!;
  
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        i18n.questionContentView_mainQuestion,
        style: textTheme.headline6,
      ),
      SizedBox(
        width: 500,
        child: Text(
          i18n.questionContentView_mainText,
          style: textTheme.caption?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                viewModel.onUpdateStep(CreateReplacementTexturesStep.selectFolder);
              },
              child:Text(i18n.questionContentView_yes)),
          const SizedBox(width: 20),
          ElevatedButton(
              onPressed: () {
                viewModel.onUpdateStep(CreateReplacementTexturesStep.selectOTR);
              },
              child: Text(i18n.questionContentView_no)),
        ],
      )
    ],
  );
}
