import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create/create_custom/create_custom_viewmodel.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final AppLocalizations i18n = AppLocalizations.of(context)!;

    return CustomScaffold(
      title: i18n.createCustomScreen_title,
      subtitle: i18n.createCustomScreen_subtitle,
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: i18n.createCustomScreen_labelPath,
              ),
              onChanged: (String value) {
                viewModel.onPathChanged(value);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: OutlinedButton(
                onPressed: viewModel.onSelectFiles,
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                child: Text(i18n.createCustomScreen_selectButton)
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'i18n.createCustomScreen_fileToInsert: ${viewModel.files.length}', // TODO Fix this one to use localisation properly
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
                finishViewModel.onAddCustomStageEntry(viewModel.files, textFieldController.text);
                viewModel.onDiscardFiles();
                Navigator.of(context).popUntil(ModalRoute.withName("/create_selection"));
              } : null,
              style: ElevatedButton.styleFrom(minimumSize: Size(
                MediaQuery.of(context).size.width * 0.5, 50)
              ),
              child: Text(i18n.createCustomScreen_stageFiles)
            ),
          ],
        )
      )
    ));
  }
}
