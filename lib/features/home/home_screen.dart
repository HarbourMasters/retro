import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/ui/components/option_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    final CreateFinishViewModel createFinishViewModel =
        Provider.of<CreateFinishViewModel>(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Retro", style: textTheme.headline3),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OptionCard(
                  text: "Create OTR",
                  icon: Icons.add_circle,
                  onMouseEnter: viewModel.onCreateOTRCardFocused,
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {
                    createFinishViewModel.onCreationState();
                    Navigator.pushNamed(context, "/create_selection");
                  }),
              const SizedBox(width: 8),
              OptionCard(
                  text: "View OTR",
                  icon: Icons.visibility,
                  onMouseEnter: viewModel.onCreateOTRCardFocused,
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {
                    createFinishViewModel.onInspectState();
                    Navigator.pushNamed(context, "/view_otr");
                  }),
            ],
          ),
          const SizedBox(height: 40),
          Text(viewModel.focusedCardInfo,
              style: textTheme.subtitle2
                  ?.copyWith(color: colorScheme.onSurface.withOpacity(0.2))),
        ],
      ),
    );
  }
}
