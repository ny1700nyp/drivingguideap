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
  String get introductionTitle => 'Introducción';

  @override
  String get introductionButton => 'Introduction';

  @override
  String get introductionSummary =>
      'Cómo encajan la pantalla Live Guide, el inicio automático, Magazine y los ajustes de More.';

  @override
  String get introductionBodyMain =>
      'Twingl Road es una guía de viaje pensada primero para audio. Mientras atraviesas ciudades y pueblos, presenta historia local, lugares emblemáticos, paisajes, comida, festivales y personas destacadas con un estilo de documental cinematográfico.\n\nAl abrir la app, la guía se inicia automáticamente para poder presentar cada pueblo nuevo al entrar. En la pestaña Live Guide, la tarjeta «Live Narrative» llena el espacio desde debajo del título hasta justo encima de la barra de pestañas: el área y la narración se muestran sobre una foto a todo el ancho. En la parte inferior hay controles solo con iconos, de izquierda a derecha: iniciar la guía si hace falta, pausar o reanudar la reproducción, repetir la narración y pausar la guía para dejar el seguimiento continuo y el uso de ubicación en esa sesión.\n\nLa pestaña Revista ofrece enlaces relacionados con el área actual. Los lugares se abren en Mapas, mientras que personas, eventos y referencias culturales se abren como búsquedas en el navegador.';

  @override
  String get introductionMoreAndroid =>
      'En More puedes elegir la persona narrativa, revisar el idioma del sistema y la voz.';

  @override
  String get introductionMoreIos =>
      'En More puedes elegir la persona narrativa, revisar el idioma actual del sistema y seleccionar una voz TTS premium o mejorada. En iOS, hacer coincidir Settings > Apple Intelligence & Siri > Language con el idioma de la app puede ayudar a que la narración local con IA funcione de forma más natural.';

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
  String get save => 'Guardar';

  @override
  String get fullNarrative => 'Narración completa';

  @override
  String characterCount(int count) {
    return '$count caracteres';
  }

  @override
  String wordCount(int count) {
    return '$count palabras';
  }

  @override
  String get noLocationYet => 'Aún no hay ubicación';

  @override
  String get currentArea => 'Área actual';

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
  String get cinematicStoryteller => 'Narrador';

  @override
  String get localHistorian => 'Historiador local';

  @override
  String get friendlyRoadCompanion => 'Compañero de ruta amigable';

  @override
  String get energeticTownWit => 'Ingenio local enérgico';

  @override
  String get customPersonasSectionTitle => 'Tus personas';

  @override
  String get customPersonaHint =>
      'Tono, papel, actitud y estilo de habla detallado del narrador.';

  @override
  String get customPersonaTitleLabel => 'Título';

  @override
  String get customPersonaTitleHint => 'Nombre corto que aparece en los menús';

  @override
  String get customPersonaDescriptionLabel => 'Descripción';

  @override
  String get addCustomPersona => 'Añadir persona';

  @override
  String get removeCustomPersona => 'Eliminar';

  @override
  String get customPersonasMaxHint =>
      'Puedes guardar hasta 24 personas personalizadas.';

  @override
  String get routeHistoryTitle => 'Lugares por los que pasaste';

  @override
  String get routeHistoryEmpty =>
      'Cuando escuches una guía de ciudad, aparecerá aquí.';

  @override
  String get routeHistoryToday => 'Hoy';

  @override
  String get routeHistoryYesterday => 'Ayer';

  @override
  String get routeHistoryDayBeforeYesterday => 'Anteayer';

  @override
  String get routeHistoryEarlier => 'Viajes anteriores';

  @override
  String get routeHistoryNoEntriesThatDay =>
      'No hay lugares guardados para este día.';

  @override
  String get cityNarration => 'Narración de la ciudad';

  @override
  String get clearRouteHistoryTitle => 'Historial de ruta';

  @override
  String get clearRouteHistoryDescription =>
      'Elimina todas las entradas guardadas en «Lugares por los que pasaste».';

  @override
  String get clearRouteHistoryButton => 'Borrar historial';

  @override
  String get clearRouteHistoryConfirmTitle =>
      '¿Borrar todo el historial de ruta?';

  @override
  String get clearRouteHistoryConfirmBody =>
      'Se quitarán todos los pueblos guardados de este dispositivo. No se puede deshacer.';

  @override
  String get languageSettings => 'Ajustes de idioma';

  @override
  String currentLanguage(Object languageName) {
    return 'Idioma actual del sistema: $languageName';
  }

  @override
  String get appleIntelligenceSiriLanguageNotice =>
      'Para obtener una mejor narración local con IA en iOS, haz coincidir este idioma en Configuración > Apple Intelligence y Siri > Idioma.';

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
  String get details => 'Revista';

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

  @override
  String get onDeviceNarrationNotice =>
      'La IA en el dispositivo no está activa. Revisa los ajustes del sistema. Comprueba también si este dispositivo admite IA en el dispositivo.';
}
