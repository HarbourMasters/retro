import 'package:flutter/material.dart';
import 'package:retro/ui/theme/colors.dart';
import 'package:retro/ui/theme/typography.dart';

ThemeData lightTheme() {
  return ThemeData.light(); // TODO
}

ThemeData darkTheme() {
  final ThemeData base = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: RetroColors.bigStone,
  );
  ColorScheme dark = base.colorScheme.copyWith(
    primary: RetroColors.telegramBlue,
    onPrimary: Colors.white,
    secondary: RetroColors.elephant,
    onSecondary: Colors.white,
    surface: RetroColors.bigStone,
    error: RetroColors.wildWatermelon,
    background: RetroColors.bigStone,
  );

  final textTheme = retroTypography.apply(
    fontFamily: 'GoogleSans',
  );

  return base.copyWith(
    colorScheme: dark,
    textTheme: textTheme,
  );
}
