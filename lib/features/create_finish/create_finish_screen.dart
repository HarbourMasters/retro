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
    final CreateFinishViewModel viewModel =
        Provider.of<CreateFinishViewModel>(context);

    return Column(
      children: [
        widget.bottomBar,
        Expanded(
          child: CustomScaffold(
              title: 'Finish',
              subtitle: 'Review your selection',
              onBackButtonPressed: () {
                if (viewModel.currentState == AppState.creationFinalization) {
                  widget.dismissCallback();
                  viewModel.onCreationState();
                } else {
                  viewModel.onCreationFinalizationState();
                }
              },
              content: const Expanded(child: Text("Finish"))),
        ),
      ],
    );
  }
}
