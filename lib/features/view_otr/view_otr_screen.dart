import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/view_otr/view_otr_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class ViewOTRScreen extends StatefulWidget {
  const ViewOTRScreen({super.key});

  @override
  _ViewOTRScreenState createState() => _ViewOTRScreenState();
}

class _ViewOTRScreenState extends State<ViewOTRScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewOTRViewModel>(context);

    return CustomScaffold(
      title: "View OTR",
      onBackButtonPressed: () {
        viewModel.resetState();
        Navigator.of(context).pop();
      },
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
                    labelText: viewModel.selectedOTRPath ?? 'OTR Path',
                  ),
                )),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: viewModel.onSelectOTR,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 50)),
                    child: const Text("Select"))
              ]),
              if (viewModel.isProcessing || viewModel.filesInOTR.isNotEmpty)
                Expanded(
                    child: viewModel.isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                                itemCount: viewModel.filesInOTR.length,
                                itemBuilder: (context, index) {
                                  return Text(viewModel.filesInOTR[index]);
                                })))
            ],
          ),
        ),
      ),
    );
  }
}
