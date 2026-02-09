// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Retro';

  @override
  String get home_createOption => 'Maak een OTR / O2R';

  @override
  String get home_createOptionSubtitle => 'Maak OTR / O2R voor SoH';

  @override
  String get home_inspectOption => 'Inspecteer een OTR / O2R';

  @override
  String get home_inspectOptionSubtitle =>
      'Inspecteer de inhoud van een OTR / O2R';

  @override
  String get createSelectionScreen_title => 'Selectie maken';

  @override
  String get createSelectionScreen_subtitle =>
      'Selecteer het type selectie dat je wilt maken';

  @override
  String get createSelectionScreen_nonHdTex => 'Vervang textures';

  @override
  String get createSelectionScreen_customSequences => 'Aangepaste composities';

  @override
  String get createSelectionScreen_custom => 'Aangepast';

  @override
  String get createReplaceTexturesScreen_Option => 'Vervang textures';

  @override
  String get createReplaceTexturesScreen_OptionDescription =>
      'Vervang textures van een OTR / O2R door aangepaste (niet-hd) textures';

  @override
  String get questionContentView_mainQuestion =>
      'Heb je al een map met vervangende textures?';

  @override
  String get questionContentView_mainText =>
      'Als je een map heeft die door deze tool is gegenereerd met vervangingen, selecteer Ja.\nals je er nog geen hebt, selecteer Nee en dan gaan we een map maken.';

  @override
  String get questionContentView_yes => 'Ja';

  @override
  String get questionContentView_no => 'Nee';

  @override
  String get otrContentView_otrPath => 'OTR / O2R Pad';

  @override
  String get otrContentView_otrSelect => 'Selecteer';

  @override
  String get otrContentView_details => 'Details';

  @override
  String get otrContentView_step1 =>
      '1. Selecteer OTR / O2R waar in je textures wilt vervangen';

  @override
  String get otrContentView_step2 =>
      '2. We extracten texture assets als PNG met de juiste mapstructuur';

  @override
  String get otrContentView_step3 =>
      '3. Je vervangd textures in die aangemaakte map';

  @override
  String get otrContentView_step4 =>
      '4. Voer dit process opnieuw uit en voer je extractiemap in';

  @override
  String get otrContentView_step5 =>
      '5. We genereren een OTR / O2R met de gewijzigde textures! 🚀';

  @override
  String get otrContentView_processing => 'Verwerken...';

  @override
  String get folderContentView_customTexturePath => 'Vervangende Texture Map';

  @override
  String get folderContentView_prependAltToggle =>
      'Voeg \'alt/\' toe aan het begin. Dit stelt spelers in staat om deze assets tijdens het spel direct aan en uit te zetten.';

  @override
  String get folderContentView_compressToggle =>
      'Bestanden comprimeren. Dit zal de grootte van de OTR / O2R verkleinen.';

  @override
  String get folderContentView_selectButton => 'Selecteer';

  @override
  String get folderContentView_stageTextures => 'Stage-Textures';

  @override
  String get createCustomSequences_addCustomSequences =>
      'Voeg aangepaste composities toe';

  @override
  String get createCustomSequences_addCustomSequencesDescription =>
      'Selecteer een map met composities en metabestanden';

  @override
  String get createCustomSequences_SequencesFolderPath => 'Composities Map';

  @override
  String get createCustomSequences_selectButton => 'Selecteer';

  @override
  String get createCustomSequences_stageFiles => 'Stage-bestanden';

  @override
  String get createFinishScreen_finish => 'Klaar';

  @override
  String get createFinishScreen_finishSubtitle =>
      'Controleer jouw OTR / O2R-gegevens';

  @override
  String get createFinishScreen_generateOtr => 'Generate OTR / O2R';

  @override
  String get components_ephemeralBar_finalizeOtr =>
      'Proces afgerond OTR / O2R ⚡️';

  @override
  String get createCustomScreen_title => 'Via Pad';

  @override
  String get createCustomScreen_subtitle =>
      'Selecteer bestanden om op pad te plaatsen';

  @override
  String get createCustomScreen_labelPath => 'Pad';

  @override
  String get createCustomScreen_selectButton => 'Selecteer bestanden';

  @override
  String get createCustomScreen_fileToInsert => 'Bestanden om in te voegen: ';

  @override
  String get createCustomScreen_stageFiles => 'Stage-bestanden';

  @override
  String get inspectOtrScreen_inspectOtr => 'Inspecteer OTR / O2R';

  @override
  String get inspectOtrScreen_inspectOtrSubtitle =>
      'Inspecteer de inhoud van een OTR / O2R';

  @override
  String get inspectOtrScreen_noOtrSelected => 'Geen OTR / O2R geselecteerd';

  @override
  String get inspectOtrScreen_selectButton => 'Selecteer';

  @override
  String get inspectOtrScreen_search => 'Zoek';

  @override
  String get gameSelectionScreen_title => 'Specifieke Tools';

  @override
  String get gameSelectionScreen_subtitle =>
      'Selecteer het spel waarvoor je een selectie wilt maken';

  @override
  String get gameSelectionScreenSoh_title => 'Ship of Harkinian';

  @override
  String get gameSelectionScreenSoh_subtitle =>
      'Selecteer de tool die je wilt gebruiken';

  @override
  String get sohCreateDebugFontScreen_title => 'Debug Lettertype Genereren';

  @override
  String get sohCreateDebugFontScreen_subtitle =>
      'Genereer debug-lettertypen voor de soh map selector';

  @override
  String get gameSelectionScreen2Ship_title => '2 Ship 2 Harkinian';

  @override
  String get gameSelectionScreen2Ship_subtitle =>
      'Selecteer de tool die je wilt gebruiken';

  @override
  String get gameSelection2ShipComingSoon_text =>
      'Tools voor 2 Ship 2 Harkinian komen binnenkort!';

  @override
  String get extractModsWarning_part1 => 'Bestaande mods extraheren';

  @override
  String get extractModsWarning_part2 => 'Het zou niet kunnen werken.';
}
