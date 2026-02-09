// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Retro';

  @override
  String get home_createOption => 'Crear OTR / O2R';

  @override
  String get home_createOptionSubtitle => 'Crear un OTR / O2R para SoH';

  @override
  String get home_inspectOption => 'Inspeccionar OTR / O2R';

  @override
  String get home_inspectOptionSubtitle =>
      'Inspeccionar el contenido de un OTR / O2R';

  @override
  String get createSelectionScreen_title => 'Crear selección';

  @override
  String get createSelectionScreen_subtitle =>
      'Seleccione el tipo de selección que desea crear';

  @override
  String get createSelectionScreen_nonHdTex => 'Reemplazar texturas';

  @override
  String get createSelectionScreen_customSequences =>
      'Secuencias personalizadas';

  @override
  String get createSelectionScreen_custom => 'Personalizada';

  @override
  String get createReplaceTexturesScreen_Option => 'Reemplazar texturas';

  @override
  String get createReplaceTexturesScreen_OptionDescription =>
      'Reemplace texturas de un OTR / O2R con otras personalizadas';

  @override
  String get questionContentView_mainQuestion =>
      '¿Ya tiene una carpeta de reemplazo de texturas?';

  @override
  String get questionContentView_mainText =>
      'Si tiene una carpeta generada por esta herramienta con reemplazos, seleccione Sí.\nDe lo contrario, seleccione No y le ayudaremos con la creación de reemplazos.';

  @override
  String get questionContentView_yes => 'Sí';

  @override
  String get questionContentView_no => 'No';

  @override
  String get otrContentView_otrPath => 'Ruta del OTR / O2R';

  @override
  String get otrContentView_otrSelect => 'Seleccionar';

  @override
  String get otrContentView_details => 'Detalles';

  @override
  String get otrContentView_step1 =>
      '1. Seleccione un OTR / O2R del que desee reemplazar texturas';

  @override
  String get otrContentView_step2 =>
      '2. Extraemos las texturas como PNG con la estructura de carpetas correcta';

  @override
  String get otrContentView_step3 =>
      '3. Reemplace las texturas de la carpeta de extracción';

  @override
  String get otrContentView_step4 =>
      '4. Ejecute este procedimiento de nuevo y seleccione la carpeta de extracción';

  @override
  String get otrContentView_step5 =>
      '5. ¡Generamos un OTR / O2R con las texturas modificadas! 🚀';

  @override
  String get otrContentView_processing => 'Procesando...';

  @override
  String get folderContentView_customTexturePath =>
      'Carpeta de reemplazos de texturas personalizadas';

  @override
  String get folderContentView_prependAltToggle =>
      'Agregar en `alt/`. Esto permitirá a los jugadores cambiar los recursos durante el juego.';

  @override
  String get folderContentView_compressToggle =>
      'Comprimir archivos, esto puede reducir el tamaño del OTR / O2R';

  @override
  String get folderContentView_selectButton => 'Seleccionar';

  @override
  String get folderContentView_stageTextures => 'Agregar texturas';

  @override
  String get createCustomSequences_addCustomSequences =>
      'Agregar secuencias personalizadas';

  @override
  String get createCustomSequences_addCustomSequencesDescription =>
      'Seleccione una carpeta con secuencias y archivos meta';

  @override
  String get createCustomSequences_SequencesFolderPath =>
      'Ruta de la carpeta de secuencias';

  @override
  String get createCustomSequences_selectButton => 'Seleccionar';

  @override
  String get createCustomSequences_stageFiles => 'Agregar archivos';

  @override
  String get createFinishScreen_finish => 'Finalizar';

  @override
  String get createFinishScreen_finishSubtitle =>
      'Compruebe los detalles de su OTR / O2R';

  @override
  String get createFinishScreen_generateOtr => 'Generar OTR / O2R';

  @override
  String get components_ephemeralBar_finalizeOtr => 'Finalizar OTR / O2R ⚡️';

  @override
  String get createCustomScreen_title => 'Por ruta';

  @override
  String get createCustomScreen_subtitle =>
      'Seleccione archivos que desee colocar en la ruta';

  @override
  String get createCustomScreen_labelPath => 'Ruta';

  @override
  String get createCustomScreen_selectButton => 'Seleccionar archivos';

  @override
  String get createCustomScreen_fileToInsert => 'Archivos para insertar: ';

  @override
  String get createCustomScreen_stageFiles => 'Agregar archivos';

  @override
  String get inspectOtrScreen_inspectOtr => 'Inspeccionar OTR / O2R';

  @override
  String get inspectOtrScreen_inspectOtrSubtitle =>
      'Inspeccione el contenido de un OTR / O2R';

  @override
  String get inspectOtrScreen_noOtrSelected =>
      'No se ha seleccionado un OTR / O2R';

  @override
  String get inspectOtrScreen_selectButton => 'Seleccionar';

  @override
  String get inspectOtrScreen_search => 'Buscar';

  @override
  String get gameSelectionScreen_title => 'Herramientas Específicas';

  @override
  String get gameSelectionScreen_subtitle =>
      'Selecciona el juego para el cual deseas crear una selección';

  @override
  String get gameSelectionScreenSoh_title => 'Ship of Harkinian';

  @override
  String get gameSelectionScreenSoh_subtitle =>
      'Selecciona la herramienta que deseas utilizar';

  @override
  String get sohCreateDebugFontScreen_title => 'Generar Debug Font';

  @override
  String get sohCreateDebugFontScreen_subtitle =>
      'Genera debug fonts para el selector de mapas de soh';

  @override
  String get gameSelectionScreen2Ship_title => '2 Ship 2 Harkinian';

  @override
  String get gameSelectionScreen2Ship_subtitle =>
      'Selecciona la herramienta que deseas utilizar';

  @override
  String get gameSelection2ShipComingSoon_text =>
      'Herramientas para 2 Ship 2 Harkinian llegarán pronto!';

  @override
  String get extractModsWarning_part1 => 'Extraer mods ya existentes';

  @override
  String get extractModsWarning_part2 => 'puede no funcionar.';
}
