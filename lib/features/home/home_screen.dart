import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/ui/components/option_card.dart';

class HomeScreen extends StatefulWidget {
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Home", style: textTheme.headline3),
        const SizedBox(height: 40),
        Row(
          children: [
            OptionCard(
                text: "Create OTR",
                icon: Icons.compress,
                onMouseEnter: viewModel.onCreateOTRCardFocused,
                onMouseLeave: viewModel.onCardFocusLost,
                onTap: () {
                  // TODO: push new view
                }),
          ],
        ),
        const SizedBox(height: 40),
        Text(viewModel.focusedCardInfo,
            style: textTheme.subtitle2
                ?.copyWith(color: colorScheme.onSurface.withOpacity(0.2))),
      ],
    );
  }
}
