// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Retro';

  @override
  String get home_createOption => 'Erstelle OTR / O2R';

  @override
  String get home_createOptionSubtitle => 'Erstelle eine OTR / O2R für SoH';

  @override
  String get home_inspectOption => 'Überprüfe OTR / O2R';

  @override
  String get home_inspectOptionSubtitle =>
      'Überprüfe die Inhalte einer OTR / O2R';

  @override
  String get createSelectionScreen_title => 'Erstelle eine Auswahl';

  @override
  String get createSelectionScreen_subtitle =>
      'Wähle die Kategorie, von der du etwas erstellen willst';

  @override
  String get createSelectionScreen_nonHdTex => 'Tausche Texturen aus';

  @override
  String get createSelectionScreen_customSequences =>
      'Benutzidentifizierte Sequenzen';

  @override
  String get createSelectionScreen_custom => 'Benutzeridentifiziert';

  @override
  String get createReplaceTexturesScreen_Option => 'Tausche Texturen aus';

  @override
  String get createReplaceTexturesScreen_OptionDescription =>
      'Tausche Texturen einer OTR / O2R durch andere Texturen aus';

  @override
  String get questionContentView_mainQuestion =>
      'Hast du bereits einen Austausch-Texturen Ordner?';

  @override
  String get questionContentView_mainText =>
      'Falls du einen von diesem Tool generierten Ordner für Austausch-Texturen hast, wähle Ja.\nFalls du keinen hast, wähle Nein und wir werden sofort mit dem Erstellen von Austuasch-Texturen starten.';

  @override
  String get questionContentView_yes => 'Ja';

  @override
  String get questionContentView_no => 'Nein';

  @override
  String get otrContentView_otrPath => 'OTR / O2R Pfad';

  @override
  String get otrContentView_otrSelect => 'Wähle';

  @override
  String get otrContentView_details => 'Details';

  @override
  String get otrContentView_step1 =>
      '1. Wähle OTR / O2R dessen Texturen du austauschen möchtest';

  @override
  String get otrContentView_step2 =>
      '2. Wir extrahieren Texturen Assets als PNG mit korrekter Ordner Struktur';

  @override
  String get otrContentView_step3 =>
      '3. Ersetze die Texturen in dem Ordner mit den extrahierten Texturen';

  @override
  String get otrContentView_step4 =>
      '4. Führe diesen Flow erneut aus und wähle deinen Extrahier-Ordner';

  @override
  String get otrContentView_step5 =>
      '5. Wir generieren eine OTR / O2R mit anderen Texturen! 🚀';

  @override
  String get otrContentView_processing => 'Verarbeite...';

  @override
  String get folderContentView_customTexturePath =>
      'Benutzeridentifizierter Austausch-Texturen Ordner';

  @override
  String get folderContentView_prependAltToggle =>
      'Füge einen `alt/` Dies ermöglicht es den Spielern, Assets im Spiel zu aktivieren oder zu deaktivieren.';

  @override
  String get folderContentView_compressToggle =>
      'Dateien komprimieren. Dadurch wird die Größe der OTR / O2R reduziert.';

  @override
  String get folderContentView_selectButton => 'Wähle';

  @override
  String get folderContentView_stageTextures => 'Texturen indexieren';

  @override
  String get createCustomSequences_addCustomSequences =>
      'Füge benutzeridentifizierte Sequenzen hinzu';

  @override
  String get createCustomSequences_addCustomSequencesDescription =>
      'Wähle einen einen Ornder mit Sequenzen und meta Dateien';

  @override
  String get createCustomSequences_SequencesFolderPath =>
      'Sequenzen Ordner Pfad';

  @override
  String get createCustomSequences_selectButton => 'Wähle';

  @override
  String get createCustomSequences_stageFiles => 'Dateien indexieren';

  @override
  String get createFinishScreen_finish => 'Beenden';

  @override
  String get createFinishScreen_finishSubtitle =>
      'Übersicht über deine OTR / O2R Details';

  @override
  String get createFinishScreen_generateOtr => 'Generiere OTR / O2R';

  @override
  String get components_ephemeralBar_finalizeOtr => 'Vollende OTR / O2R ⚡️';

  @override
  String get createCustomScreen_title => 'Via Pfad';

  @override
  String get createCustomScreen_subtitle =>
      'Wähle Dateien, die im Pfad platziert werden sollen';

  @override
  String get createCustomScreen_labelPath => 'Pfad';

  @override
  String get createCustomScreen_selectButton => 'Wähle Dateien';

  @override
  String get createCustomScreen_fileToInsert => 'Dateien zum Einfügen: ';

  @override
  String get createCustomScreen_stageFiles => 'Stage Files';

  @override
  String get inspectOtrScreen_inspectOtr => 'Überprüfe OTR / O2R';

  @override
  String get inspectOtrScreen_inspectOtrSubtitle =>
      'Überprüfe die Inhalte einer OTR / O2R';

  @override
  String get inspectOtrScreen_noOtrSelected => 'Keine OTR / O2R ausgewählt';

  @override
  String get inspectOtrScreen_selectButton => 'Wähle';

  @override
  String get inspectOtrScreen_search => 'Suchen';

  @override
  String get gameSelectionScreen_title => 'Spezifische Werkzeuge';

  @override
  String get gameSelectionScreen_subtitle =>
      'Wähle das Spiel aus, für das du eine Auswahl treffen möchtest';

  @override
  String get gameSelectionScreenSoh_title => 'Ship of Harkinian';

  @override
  String get gameSelectionScreenSoh_subtitle =>
      'Wähle das Werkzeug aus, das du verwenden möchtest';

  @override
  String get sohCreateDebugFontScreen_title => 'Debug-Schriftart Generieren';

  @override
  String get sohCreateDebugFontScreen_subtitle =>
      'Generiere Debug-Schriften für den SOH-Karten-Selektor';

  @override
  String get gameSelectionScreen2Ship_title => '2 Ship 2 Harkinian';

  @override
  String get gameSelectionScreen2Ship_subtitle =>
      'Wähle das Werkzeug aus, das du verwenden möchtest';

  @override
  String get gameSelection2ShipComingSoon_text =>
      'Werkzeuge für 2 Ship 2 Harkinian kommen bald!';

  @override
  String get extractModsWarning_part1 => 'Existierende Mods extrahieren';

  @override
  String get extractModsWarning_part2 => 'Könnte nicht funktionieren.';
}
