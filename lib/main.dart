import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_custom/create_custom_screen.dart';
import 'package:retro/features/create_custom/create_custom_viewmodel.dart';
import 'package:retro/features/create_finish/create_finish_viewmodel.dart';
import 'package:retro/features/create_selection/create_selection_screen.dart';
import 'package:retro/features/create_selection/create_selection_viewmodel.dart';
import 'package:retro/features/home/home_screen.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/ui/components/ephemeral_bar.dart';
import 'package:retro/ui/theme/theme.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Retro');
    setWindowMinSize(const Size(600, 600));
    setWindowMaxSize(Size.infinite);
  }

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
        ChangeNotifierProvider(create: (_) => CreateSelectionViewModel()),
        ChangeNotifierProvider(create: (_) => CreateCustomViewModel()),
        ChangeNotifierProvider(create: (_) => CreateFinishViewModel()),
      ],
      child: MaterialApp(
        title: 'Retro',
        darkTheme: darkTheme(),
        theme: lightTheme(),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        builder: (context, child) {
          return Overlay(initialEntries: [
            OverlayEntry(
                builder: (context) => Stack(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height - 24,
                            child: child!),
                        const Positioned(bottom: 0, child: EphemeralBar()),
                      ],
                    ))
          ]);
        },
        routes: {
          '/': (context) => const HomeScreen(),
          '/create_selection': (context) => const CreateSelectionScreen(),
          '/create_custom': (context) => const CreateCustomScreen(),
        },
      ),
    );
  }
}
