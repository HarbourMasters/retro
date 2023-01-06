# retro

An OTR generation tool.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### i18n localization rules

When adding any text to retro, be sure to make it localizable by doing the following
- Make sure that `import 'package:flutter_gen/gen_l10n/app_localizations.dart';` is properly imported in the file you're adding any kind of text.
- Make sure to also have this `final AppLocalizations i18n = AppLocalizations.of(context)!;`present in the override.
- When it's the time for you to add your text, follow this naming convention:
    - When you're adding a key in a **component**, use this: `i18n.components_myFile_keyName`
    - When you're adding a key somewhere else, use this: `i18n.myFile_keyName`
    - Add the corresponding keys in both `app_en.arb` which will contain your text.
    - When you're adding new text, please notify it so we can translate your new keys as fast as we can.
