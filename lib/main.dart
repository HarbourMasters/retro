import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/home/home_screen.dart';
import 'package:retro/features/home/home_viewmodel.dart';
import 'package:retro/ui/theme/theme.dart';

void main() {
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
      ],
      child: MaterialApp(
        title: 'Retro',
        darkTheme: darkTheme(),
        theme: lightTHeme(),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
        },
      ),
    );
  }
}
