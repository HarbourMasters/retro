import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('nl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get appTitle;

  /// No description provided for @home_createOption.
  ///
  /// In en, this message translates to:
  /// **'Create OTR / O2R'**
  String get home_createOption;

  /// No description provided for @home_createOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an OTR / O2R for SoH'**
  String get home_createOptionSubtitle;

  /// No description provided for @home_inspectOption.
  ///
  /// In en, this message translates to:
  /// **'Inspect OTR / O2R'**
  String get home_inspectOption;

  /// No description provided for @home_inspectOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inspect the contents of an OTR / O2R'**
  String get home_inspectOptionSubtitle;

  /// No description provided for @createSelectionScreen_title.
  ///
  /// In en, this message translates to:
  /// **'Create Selection'**
  String get createSelectionScreen_title;

  /// No description provided for @createSelectionScreen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the type of selection you want to create'**
  String get createSelectionScreen_subtitle;

  /// No description provided for @createSelectionScreen_nonHdTex.
  ///
  /// In en, this message translates to:
  /// **'Replace Textures'**
  String get createSelectionScreen_nonHdTex;

  /// No description provided for @createSelectionScreen_customSequences.
  ///
  /// In en, this message translates to:
  /// **'Custom Sequences'**
  String get createSelectionScreen_customSequences;

  /// No description provided for @createSelectionScreen_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get createSelectionScreen_custom;

  /// No description provided for @createReplaceTexturesScreen_Option.
  ///
  /// In en, this message translates to:
  /// **'Replace Textures'**
  String get createReplaceTexturesScreen_Option;

  /// No description provided for @createReplaceTexturesScreen_OptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace textures from an OTR / O2R with custom ones'**
  String get createReplaceTexturesScreen_OptionDescription;

  /// No description provided for @questionContentView_mainQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you already have a texture replacement folder?'**
  String get questionContentView_mainQuestion;

  /// No description provided for @questionContentView_mainText.
  ///
  /// In en, this message translates to:
  /// **'If you have a folder generated by this tool with replacements, select Yes.\nIf you don\'t have one, select No and we\'ll get you started with creating replacements.'**
  String get questionContentView_mainText;

  /// No description provided for @questionContentView_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get questionContentView_yes;

  /// No description provided for @questionContentView_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get questionContentView_no;

  /// No description provided for @otrContentView_otrPath.
  ///
  /// In en, this message translates to:
  /// **'OTR / O2R Path'**
  String get otrContentView_otrPath;

  /// No description provided for @otrContentView_otrSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get otrContentView_otrSelect;

  /// No description provided for @otrContentView_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get otrContentView_details;

  /// No description provided for @otrContentView_step1.
  ///
  /// In en, this message translates to:
  /// **'1. Select OTR / O2R that you want to replace textures from'**
  String get otrContentView_step1;

  /// No description provided for @otrContentView_step2.
  ///
  /// In en, this message translates to:
  /// **'2. We extract texture assets as PNG with correct folder structure'**
  String get otrContentView_step2;

  /// No description provided for @otrContentView_step3.
  ///
  /// In en, this message translates to:
  /// **'3. You replace the textures in that extraction folder'**
  String get otrContentView_step3;

  /// No description provided for @otrContentView_step4.
  ///
  /// In en, this message translates to:
  /// **'4. Run this flow again and present your extraction folder'**
  String get otrContentView_step4;

  /// No description provided for @otrContentView_step5.
  ///
  /// In en, this message translates to:
  /// **'5. We generate an OTR / O2R with the changed textures! 🚀'**
  String get otrContentView_step5;

  /// No description provided for @otrContentView_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get otrContentView_processing;

  /// No description provided for @folderContentView_customTexturePath.
  ///
  /// In en, this message translates to:
  /// **'Custom Texture Replacements Folder'**
  String get folderContentView_customTexturePath;

  /// No description provided for @folderContentView_prependAltToggle.
  ///
  /// In en, this message translates to:
  /// **'Prepend `alt/`. This will allow players to toggle these assets on-the-fly in game.'**
  String get folderContentView_prependAltToggle;

  /// No description provided for @folderContentView_compressToggle.
  ///
  /// In en, this message translates to:
  /// **'Compress Files. This will reduce the size of the OTR / O2R.'**
  String get folderContentView_compressToggle;

  /// No description provided for @folderContentView_selectButton.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get folderContentView_selectButton;

  /// No description provided for @folderContentView_stageTextures.
  ///
  /// In en, this message translates to:
  /// **'Stage Textures'**
  String get folderContentView_stageTextures;

  /// No description provided for @createCustomSequences_addCustomSequences.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Sequences'**
  String get createCustomSequences_addCustomSequences;

  /// No description provided for @createCustomSequences_addCustomSequencesDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a folder with sequences and meta files'**
  String get createCustomSequences_addCustomSequencesDescription;

  /// No description provided for @createCustomSequences_SequencesFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Sequences Folder Path'**
  String get createCustomSequences_SequencesFolderPath;

  /// No description provided for @createCustomSequences_selectButton.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get createCustomSequences_selectButton;

  /// No description provided for @createCustomSequences_stageFiles.
  ///
  /// In en, this message translates to:
  /// **'Stage Files'**
  String get createCustomSequences_stageFiles;

  /// No description provided for @createFinishScreen_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get createFinishScreen_finish;

  /// No description provided for @createFinishScreen_finishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your OTR / O2R details'**
  String get createFinishScreen_finishSubtitle;

  /// No description provided for @createFinishScreen_generateOtr.
  ///
  /// In en, this message translates to:
  /// **'Generate OTR / O2R'**
  String get createFinishScreen_generateOtr;

  /// No description provided for @components_ephemeralBar_finalizeOtr.
  ///
  /// In en, this message translates to:
  /// **'Finalize OTR / O2R ⚡️'**
  String get components_ephemeralBar_finalizeOtr;

  /// No description provided for @createCustomScreen_title.
  ///
  /// In en, this message translates to:
  /// **'Custom Directory'**
  String get createCustomScreen_title;

  /// No description provided for @createCustomScreen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select directory to pack as .otr'**
  String get createCustomScreen_subtitle;

  /// No description provided for @createCustomScreen_labelPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get createCustomScreen_labelPath;

  /// No description provided for @createCustomScreen_selectButton.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get createCustomScreen_selectButton;

  /// No description provided for @createCustomScreen_fileToInsert.
  ///
  /// In en, this message translates to:
  /// **'Files to insert: '**
  String get createCustomScreen_fileToInsert;

  /// No description provided for @createCustomScreen_stageFiles.
  ///
  /// In en, this message translates to:
  /// **'Stage Files'**
  String get createCustomScreen_stageFiles;

  /// No description provided for @inspectOtrScreen_inspectOtr.
  ///
  /// In en, this message translates to:
  /// **'Inspect OTR / O2R'**
  String get inspectOtrScreen_inspectOtr;

  /// No description provided for @inspectOtrScreen_inspectOtrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inspect the contents of an OTR / O2R'**
  String get inspectOtrScreen_inspectOtrSubtitle;

  /// No description provided for @inspectOtrScreen_noOtrSelected.
  ///
  /// In en, this message translates to:
  /// **'No OTR / O2R Selected'**
  String get inspectOtrScreen_noOtrSelected;

  /// No description provided for @inspectOtrScreen_selectButton.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get inspectOtrScreen_selectButton;

  /// No description provided for @inspectOtrScreen_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get inspectOtrScreen_search;

  /// No description provided for @gameSelectionScreen_title.
  ///
  /// In en, this message translates to:
  /// **'Game Specific Tools'**
  String get gameSelectionScreen_title;

  /// No description provided for @gameSelectionScreen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the game you want to create a selection for'**
  String get gameSelectionScreen_subtitle;

  /// No description provided for @gameSelectionScreenSoh_title.
  ///
  /// In en, this message translates to:
  /// **'Ship of Harkinian'**
  String get gameSelectionScreenSoh_title;

  /// No description provided for @gameSelectionScreenSoh_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the tool you want to use'**
  String get gameSelectionScreenSoh_subtitle;

  /// No description provided for @sohCreateDebugFontScreen_title.
  ///
  /// In en, this message translates to:
  /// **'Debug Font Converter'**
  String get sohCreateDebugFontScreen_title;

  /// No description provided for @sohCreateDebugFontScreen_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert and generate fonts for the soh map selector'**
  String get sohCreateDebugFontScreen_subtitle;

  /// No description provided for @gameSelectionScreen2Ship_title.
  ///
  /// In en, this message translates to:
  /// **'2 Ship 2 Harkinian'**
  String get gameSelectionScreen2Ship_title;

  /// No description provided for @gameSelectionScreen2Ship_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the tool you want to use'**
  String get gameSelectionScreen2Ship_subtitle;

  /// No description provided for @gameSelection2ShipComingSoon_text.
  ///
  /// In en, this message translates to:
  /// **'2 Ship 2 Harkinian Tools are coming soon!'**
  String get gameSelection2ShipComingSoon_text;

  /// No description provided for @extractModsWarning_part1.
  ///
  /// In en, this message translates to:
  /// **'Extracting existing mods'**
  String get extractModsWarning_part1;

  /// No description provided for @extractModsWarning_part2.
  ///
  /// In en, this message translates to:
  /// **'might not work properly.'**
  String get extractModsWarning_part2;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
