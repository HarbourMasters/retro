import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:retro/features/create/create_custom/create_custom_viewmodel.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/l10n/app_localizations.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final viewModel = Provider.of<CreateCustomViewModel>(context);
    final finishViewModel = Provider.of<CreateFinishViewModel>(context);
    final i18n = AppLocalizations.of(context)!;

    return CustomScaffold(
      title: i18n.createCustomScreen_title,
      subtitle: i18n.createCustomScreen_subtitle,
      onBackButtonPressed: () {
        viewModel.reset();
        Navigator.of(context).pop();
      },
      content: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: OutlinedButton(
                      onPressed: viewModel.onSelectFiles,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                      child: Text(i18n.createCustomScreen_selectButton),
                    ),
                  ),
                  Text(viewModel.path),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${i18n.createCustomScreen_fileToInsert}${viewModel.files.length}',
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.files.length,
                  itemBuilder: (context, index) {
                    return Text(
                      p.relative(
                        viewModel.files[index].path,
                        from: viewModel.path,
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: viewModel.files.isNotEmpty && viewModel.path.isNotEmpty
                    ? () {
                        finishViewModel.onAddCustomStageEntries(
                          viewModel.files,
                          viewModel.path,
                        );
                        viewModel.reset();
                        Navigator.of(context).popUntil(
                          ModalRoute.withName('/create_selection'),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.5,
                    50,
                  ),
                ),
                child: Text(i18n.createCustomScreen_stageFiles),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
