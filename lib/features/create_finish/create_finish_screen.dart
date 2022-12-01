import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/ui/components/custom_scaffold.dart';

class CreateFinishBottomBarModal extends StatefulWidget {
  final Widget bottomBar;
  final Function dismissCallback;

  const CreateFinishBottomBarModal({
    Key? key,
    required this.bottomBar,
    required this.dismissCallback,
  }) : super(key: key);

  @override
  _CreateFinishBottomBarModalState createState() =>
      _CreateFinishBottomBarModalState();
}

class _CreateFinishBottomBarModalState
    extends State<CreateFinishBottomBarModal> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final CreateFinishViewModel viewModel =
        Provider.of<CreateFinishViewModel>(context);

    return Column(
      children: [
        widget.bottomBar,
        Expanded(
          child: CustomScaffold(
              title: 'Finish',
              subtitle: 'Review your OTR details',
              topRightWidget: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () { widget.dismissCallback(); }),
              content: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Contents:", style: textTheme.subtitle1!.copyWith(decoration: TextDecoration.underline)),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: viewModel.entries.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = viewModel.entries.keys.elementAt(index);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(key, style: textTheme.subtitle2),
                                  for (var file in viewModel.entries[key]!.iterables)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("\u2022 ${file.path}", style: textTheme.bodyText2),
                                        const Spacer(),
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: IconButton(
                                            iconSize: 20,
                                            splashRadius: 20,
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              viewModel.onRemoveFile(file, key);
                                            },
                                          )),
                                      ],
                                    ),
                              ]);
                            }))
                      ]),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: viewModel.entries.isNotEmpty ? viewModel.onGenerateOTR : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.5, 50)
                        ),
                        child: viewModel.isGenerating
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('Generate OTR')
                      ),
                  ]),
                )),
            ),
        ),
      ],
    );
  }
}
