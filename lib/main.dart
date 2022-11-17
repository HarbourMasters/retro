import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro/features/create_selection/create_selection_screen.dart';
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
        theme: lightTheme(),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        builder: (context, child) {
          return Column(
            children: [
              Expanded(child: child!),
              // Replace this with the bottom bar
              Container(
                height: 50,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Cool permanent bar",
                        style: Theme.of(context).textTheme.headline6),
                  ],
                ),
              )
            ],
          );
        },
        routes: {
          '/': (context) => HomeScreen(),
          '/create_selection': (context) => const CreateSelectionScreen(),
        },
      ),
    );
  }
}
