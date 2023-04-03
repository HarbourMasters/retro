import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final AppLocalizations i18n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(i18n.appTitle, style: textTheme.headline3),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OptionCard(
                  text: i18n.home_createOption,
                  icon: Icons.add_circle,
                  onMouseEnter: () => viewModel.onCreateOTRCardFocused(i18n.home_createOptionSubtitle),
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {
                    Navigator.pushNamed(context, "/create_selection");
                  }),
              const SizedBox(width: 20),
              OptionCard(
                  text: i18n.home_inspectOption,
                  icon: Icons.visibility,
                  onMouseEnter: () => viewModel.onCreateOTRCardFocused(i18n.home_inspectOptionSubtitle),
                  onMouseLeave: viewModel.onCardFocusLost,
                  onTap: () {
                    Navigator.pushNamed(context, "/view_otr");
                  }),
              const SizedBox(width: 20),
              OptionCard(
                  text: "Debug",
                  icon: Icons.warning_rounded,
                  onTap: () {
                    Navigator.of(context).pushNamed('/debug_selection');
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
