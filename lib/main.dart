import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:retro/context.dart';
import 'package:retro/features/create/create_custom/create_custom_screen.dart';
import 'package:retro/features/create/create_custom/create_custom_viewmodel.dart';
import 'package:retro/features/create/create_custom_sequences/create_custom_sequences_screen.dart';
import 'package:retro/features/create/create_custom_sequences/create_custom_sequences_viewmodel.dart';
import 'package:retro/features/create/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_screen.dart';
import 'package:retro/features/create/create_replace_textures/create_replace_textures_viewmodel.dart';
import 'package:retro/features/create/create_selection/create_selection_screen.dart';
import 'package:retro/features/create/create_selection/games/games_selection_screen.dart';
import 'package:retro/features/create/create_selection/games/soh/2ship_screen.dart';
import 'package:retro/features/create/create_selection/games/soh/soh_screen.dart';
import 'package:retro/features/debug/debug_convert_textures/debug_convert_textures_screen.dart';
import 'package:retro/features/debug/debug_font_generator/debug_font_generator_screen.dart';
import 'package:retro/features/debug/debug_selection/debug_selection_screen.dart';
import 'package:retro/features/home/home_screen.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/features/inspect_otr/inspect_otr_screen.dart';
import 'package:retro/features/inspect_otr/inspect_otr_viewmodel.dart';
import 'package:retro/ui/components/ephemeral_bar.dart';
import 'package:retro/ui/theme/theme.dart';
import 'package:retro/utils/git.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final errorFile = File('latest.log')
    ..createSync();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Retro');
    setWindowMinSize(const Size(700, 700));
    setWindowMaxSize(Size.infinite);
  }

  RetroContext.git = GitLoader.getGitInfo();

  runZonedGuarded<Future<void>>(bindApp, (error, stack) async {
    // Log to file
    final errorString = 'Error: $error\nStack: $stack';
    await errorFile.writeAsString(errorString, mode: FileMode.append);
  });
}

Future<void> bindApp() async {
  runApp(const Retro());
}


class Retro extends StatelessWidget {
  const Retro({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CreateCustomViewModel()),
        ChangeNotifierProvider(create: (_) => CreateFinishViewModel()),
        ChangeNotifierProvider(create: (_) => InspectOTRViewModel()),
        ChangeNotifierProvider(create: (_) => CreateCustomSequencesViewModel()),
        ChangeNotifierProvider(create: (_) => CreateReplaceTexturesViewModel()),
      ],
      child: MaterialApp(
        title: 'Retro',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('de', ''), Locale('fr', ''), Locale('es', ''), Locale('nl', '')],
        darkTheme: darkTheme(),
        theme: lightTheme(),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => ScaffoldMessenger(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 24,
                        child: child,
                      ),
                      const Positioned(bottom: 0, child: EphemeralBar()),
                    ],
                  ),
                ),
              )
            ],
          );
        },
        routes: {
          '/': (context) => const HomeScreen(),
          '/create_selection': (context) => const CreateSelectionScreen(),
          '/game_selection': (context) => const GameSelectionScreen(),
          '/game_selection/soh': (context) => const SOHGameScreen(),
          '/game_selection/2ship': (context) => const Ship2GameScreen(),
          '/create_custom': (context) => const CreateCustomScreen(),
          '/view_otr': (context) => const InspectOTRScreen(),
          '/create_custom_sequences': (context) => const CreateCustomSequencesScreen(),
          '/create_replace_textures': (context) => const CreateReplaceTexturesScreen(),
          '/debug_selection': (context) => const DebugSelectionScreen(),
          '/debug_convert_textures': (context) => const DebugGeneratorFontsScreen(),
          '/debug_generate_font': (context) => const DebugGeneratorFontScreen(),
        },
      ),
    );
  }
}
