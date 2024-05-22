import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/inspect_otr/inspect_otr_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class InspectOTRScreen extends StatefulWidget {
  const InspectOTRScreen({super.key});

  @override
  _InspectOTRScreenState createState() => _InspectOTRScreenState();
}

class _InspectOTRScreenState extends State<InspectOTRScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InspectOTRViewModel>(context);
    final i18n = AppLocalizations.of(context)!;

    return CustomScaffold(
      title: i18n.inspectOtrScreen_inspectOtr,
      subtitle: i18n.inspectOtrScreen_inspectOtrSubtitle,
      onBackButtonPressed: () {
        viewModel.reset();
        Navigator.of(context).pop();
      },
      topRightWidget: SizedBox(
        width: 300,
        child: TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: i18n.inspectOtrScreen_search,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: viewModel.onSearch,
        ),
      ),
      content: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: viewModel.selectedOTRPath ?? i18n.inspectOtrScreen_noOtrSelected,
                  ),
                ),),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: viewModel.onSelectOTR,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50),),
                    child: Text(i18n.inspectOtrScreen_selectButton),),
              ],),
              if (viewModel.isProcessing || viewModel.filteredFilesInOTR.isNotEmpty)
                Expanded(
                    child: viewModel.isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                                itemCount: viewModel.filteredFilesInOTR.length,
                                prototypeItem: const SizedBox(width: 0, height: 20),
                                itemBuilder: (context, index) {
                                  return Text(viewModel.filteredFilesInOTR[index]);
                                },),),),
            ],
          ),
        ),
      ),
    );
  }
}
