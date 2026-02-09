import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:retro/l10n/app_localizations.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:retro/context.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/ui/components/option_card.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int versionCode = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getRetroVersion();
    });
  }

  Future<void> getRetroVersion() async {
    const url = 'https://raw.githubusercontent.com/HarbourMasters/retro/main/release.json';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          versionCode = data['version'] as int;
        });
      }
    } catch (e) {
      print('Error fetching version code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final viewModel = Provider.of<HomeViewModel>(context);
    final i18n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(i18n.appTitle, style: textTheme.displaySmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Brought to you by', style: textTheme.titleSmall),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: GradientAnimationText(
                      text: Text('HM64'),
                      colors: [
                          Colors.indigo,
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                      ],
                      duration: const Duration(seconds: 2),
                    ),
                  ),
                  const Icon(Icons.favorite, color: Colors.red),
                ],
              ),
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
                        Navigator.pushNamed(context, '/create_selection');
                      },),
                  const SizedBox(width: 20),
                  OptionCard(
                      text: i18n.home_inspectOption,
                      icon: Icons.visibility,
                      onMouseEnter: () => viewModel.onCreateOTRCardFocused(i18n.home_inspectOptionSubtitle),
                      onMouseLeave: viewModel.onCardFocusLost,
                      onTap: () {
                        Navigator.pushNamed(context, '/view_otr');
                      },),
                  const SizedBox(width: 20),
                  OptionCard(
                      text: 'Debug',
                      icon: Icons.warning_rounded,
                      onTap: () {
                        Navigator.of(context).pushNamed('/debug_selection');
                      },),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                '${RetroContext.git.commitHash} - ${RetroContext.git.branch}',
                style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.2)),
              ),
              Text(
                RetroContext.git.commitDate,
                style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.2)),
              ),
            ],
          ),
          if(versionCode != -1 && RetroContext.versionCode < versionCode)
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () async {
                final url = Uri.parse('https://github.com/HarbourMasters/retro/releases/latest');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.yellow[700],
                      size: 25,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'New version available',
                      style: TextStyle(
                        color: Colors.yellow[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
