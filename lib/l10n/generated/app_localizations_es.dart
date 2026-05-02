// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get loadingVoices => 'Cargando voces...';

  @override
  String get systemDefaultEnglishVoice =>
      'Usando la voz predeterminada del sistema.';

  @override
  String voiceLoadError(Object error) {
    return 'No se pudieron cargar las voces: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return '$count voz/voces premium o mejoradas disponibles. Seleccionada: $quality.';
  }

  @override
  String usingVoice(Object voiceName) {
    return 'Usando $voiceName.';
  }

  @override
  String get startGuidingDialogTitle => '¿Iniciar la guía?';

  @override
  String get startGuidingDialogMessage =>
      'La guía se activará. Presentaré automáticamente la historia, los lugares emblemáticos y los sabores locales de cada nuevo pueblo al que entres.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get fullNarrative => 'Narración completa';

  @override
  String get noLocationYet => 'Aún no hay ubicación';

  @override
  String get currentArea => 'Área actual';

  @override
  String get startAreaMonitoringPlaceholder => 'Inicia la guía del área.';

  @override
  String get startGuiding => 'Iniciar guía';

  @override
  String get pauseGuide => 'Pausar guía';

  @override
  String get checkThisTown => 'Consultar este pueblo';

  @override
  String get startTestRoute => 'Iniciar ruta de prueba Sacramento a Seattle';

  @override
  String get stopTestRoute => 'Detener ruta de prueba';

  @override
  String get prevStop => 'Parada anterior';

  @override
  String get nextStop => 'Siguiente parada';

  @override
  String get heritage => 'Herencia';

  @override
  String heritageBody(Object areaName) {
    return 'El origen del nombre y la historia que dio forma a $areaName.';
  }

  @override
  String get icons => 'Iconos';

  @override
  String get iconsBody =>
      'Personas famosas y episodios locales conectados con este lugar.';

  @override
  String get views => 'Vistas';

  @override
  String get viewsBody =>
      'Miradores escénicos y pequeños desvíos hermosos cerca.';

  @override
  String get bites => 'Sabores';

  @override
  String get bitesBody =>
      'Una comida o bebida local que vale la pena recordar.';

  @override
  String get goods => 'Productos';

  @override
  String get goodsBody =>
      'Productos de temporada, vino, cerveza, mariscos o agricultura.';

  @override
  String get trivia => 'Curiosidades';

  @override
  String get triviaBody =>
      'Locaciones de cine, festivales, eventos y pequeñas sorpresas locales.';

  @override
  String get digitalMagazine => 'Revista digital';

  @override
  String detailsIntro(Object areaName) {
    return 'Detente y explora la historia más profunda detrás de $areaName.';
  }

  @override
  String get relatedLinks => 'Enlaces relacionados';

  @override
  String get personaSettings => 'Ajustes de personalidad';

  @override
  String get narrativeStyle => 'Estilo narrativo';

  @override
  String get cinematicStoryteller => 'Narrador cinematográfico';

  @override
  String get localHistorian => 'Historiador local';

  @override
  String get friendlyRoadCompanion => 'Compañero de ruta amigable';

  @override
  String get voiceSettings => 'Ajustes de voz';

  @override
  String get firstLlmPrompt => 'Prompt del primer LLM';

  @override
  String get noFirstLlmPrompt =>
      'Aún no se ha generado ningún prompt del primer LLM.';

  @override
  String get liveGuide => 'Guía en vivo';

  @override
  String get details => 'Detalles';

  @override
  String get more => 'Más';

  @override
  String get cruisingTowardsNextDiscovery => 'Rumbo al próximo descubrimiento.';

  @override
  String get liveNarrative => 'Narración en vivo';

  @override
  String get expandNarrative => 'Expandir narración';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get replay => 'Repetir';

  @override
  String get thinking => 'Pensando';

  @override
  String get noRelatedLinks => 'Aún no hay enlaces relacionados preparados.';

  @override
  String get voice => 'Voz';

  @override
  String get systemDefault => 'Predeterminada del sistema';

  @override
  String get moreVoice => '¿Más voces?';

  @override
  String get moreVoiceDescription =>
      'Puedes agregar nuevas voces en Configuración > Accesibilidad > Leer y hablar > Voces.';
}
