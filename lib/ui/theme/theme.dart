import 'package:flutter/material.dart';
import 'package:retro/ui/theme/colors.dart';
import 'package:retro/ui/theme/typography.dart';

ThemeData lightTheme() {
  return ThemeData.light(); // TODO
}

ThemeData darkTheme() {
  final base = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: RetroColors.bigStone,
  );
  final dark = base.colorScheme.copyWith(
    primary: RetroColors.telegramBlue,
    onPrimary: Colors.white,
    secondary: RetroColors.elephant,
    onSecondary: Colors.white,
    surface: RetroColors.bigStone,
    error: RetroColors.wildWatermelon,
  );

  final textTheme = retroTypography.apply(
    fontFamily: 'GoogleSans',
  );

  return base.copyWith(
    colorScheme: dark,
    textTheme: textTheme,
  );
}
