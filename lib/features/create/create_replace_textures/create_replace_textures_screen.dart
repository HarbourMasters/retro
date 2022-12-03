import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final CreateReplaceTexturesViewModel viewModel =
        Provider.of<CreateReplaceTexturesViewModel>(context);

    return CustomScaffold(
      title: "Replace Textures",
      subtitle: "Replace textures from an OTR with custom ones",
      onBackButtonPressed: () {
        Navigator.pop(context);
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
                      labelText: viewModel.selectedFolderPath ?? 'Custom Texture Extraction Folder',
                    ),
                  )),
                  const SizedBox(width: 12),
                  ElevatedButton(
                      onPressed: viewModel.onSelectFolder,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 50)),
                      child: const Text("Select"))
                ]),
                if (viewModel.selectedFolderPath == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child:  Text(
                      "Please select the folder generated by an OTR texture extraction containing you replacements. If you don't have one, point us to an OTR instaed and we'll set you up with a texture replacement setup.",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,

                    ))),
              ]))
      )
    );
  }
}
