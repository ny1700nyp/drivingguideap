import 'dart:math';

/// Friendly randomized narration when on-device LLM is unavailable.
/// Uses Open-Meteo style brief weather clauses when [weatherPhrase] is non-null.
class FriendlyFallbackCityNarration {
  FriendlyFallbackCityNarration._();

  static final _random = Random();

  static String pick({
    required String cityName,
    required String outputLanguage,
    String? weatherPhrase,
  }) {
    final lang = outputLanguage.trim().toLowerCase();
    final weather =
        (weatherPhrase != null && weatherPhrase.trim().isNotEmpty)
            ? weatherPhrase.trim()
            : _weatherSkipped(lang);
    final templates = _templates(lang);
    final t = templates[_random.nextInt(templates.length)];
    return t
        .replaceAll('{city}', cityName)
        .replaceAll('{weather}', weather);
  }

  static String _weatherSkipped(String lang) {
    return switch (lang) {
      'korean' => '이번에는 실시간 날씨를 가져오지 못했습니다',
      'japanese' => '今回は天気を取得できませんでした',
      'chinese' => '本次未能获取实时天气',
      'spanish' => 'no pudimos obtener el tiempo en vivo esta vez',
      'german' => 'diesmal haben wir kein aktuelles Wetter geholt',
      'french' => "on n'a pas pu récupérer la météo cette fois",
      _ => "we couldn't grab live weather this round",
    };
  }

  static List<String> _templates(String lang) {
    return switch (lang) {
      'korean' => _ko,
      'japanese' => _ja,
      'chinese' => _zh,
      'spanish' => _es,
      'german' => _de,
      'french' => _fr,
      _ => _en,
    };
  }

  static const _en = [
    "You're rolling through {city} today. {weather}. Let whatever catches your eye along the shoulder stick for a mile or two.",
    '{weather} as you cruise near {city}. Pretend this stretch has its own soundtrack.',
    '{city} slips past the windows — {weather}. Every billboard and side street hints at where you really are.',
    'Say a quiet hello to {city} from the passing lane. {weather}. Small towns and big skylines both deserve a nod.',
    '{weather} paints the mood around {city}. Catch the hills, wires, or neon — they are part of the ride.',
    "You're threading through {city} now. {weather}. Let curiosity borrow the wheel for thirty harmless seconds.",
    '{city}, briefly yours at highway speed. {weather}. Maybe you will loop back someday with time to park.',
    'Outside {city}, {weather}. Road trips collect memories like spare change in a cup holder.',
    "You will wave at {city} in the rearview soon enough. {weather}. This chapter is still writing itself.",
    'Near {city}, {weather}. Every exit is a maybe — enjoy this page without choosing every fork.',
  ];

  static const _ko = [
    '오늘 {city} 구간을 지나가고 있어요. {weather}. 창밖으로 스치는 풍경을 천천히 즐겨 보세요.',
    '{city} 근처를 달리는 지금, {weather}. 이 구간만의 플레이리스트가 있는 것처럼 상상해 보세요.',
    '{city}이 창문 너머로 스쳐 지나가요. {weather}. 간판과 골목이 지금 어디를 지나는지 알려 주죠.',
    '차선 너머로 {city}에 조용히 인사해 보세요. {weather}. 작은 마을이든 높은 빌딩이든 모두 한 번쯤은 인사받을 만해요.',
    '{city} 주변 분위기를 {weather}이 더해 주네요. 언덕, 전선, 네온 중 무엇이든 여행의 한 장면이에요.',
    '지금 {city} 사이를 관통하고 있어요. {weather}. 잠깐만이라도 호기심에 길을 맡겨 보세요.',
    '고속도로 속도로 잠깐만 스치는 {city}, {weather}. 나중에 여유 있게 다시 들를 날이 있을지도 몰라요.',
    '{city} 밖으로 나오니 {weather}. 로드트립은 컵홀더 동전처럼 기억을 하나씩 모아 가요.',
    '곧 {city}가 뒷유리 너머로 멀어지겠죠. {weather}. 오늘 구간은 아직 쓰이고 있는 이야기예요.',
    '{city} 근처예요. {weather}. 모든 출구는 가능성 — 오늘은 모든 갈림길을 고르지 않아도 괜찮아요.',
  ];

  static const _ja = [
    '今日は{city}のあたりを走っています。{weather}。窓の外の景色をゆっくり味わってください。',
    '{city}付近をクルーズ中、{weather}。この区間だけのサウンドトラックがある気分で。',
    '{city}が窓の向こうを過ぎていきます。{weather}。看板や路地が、いまの場所を教えてくれます。',
    '追い越し車線から{city}にそっと挨拶を。{weather}。小さな町も高いビルも、一度はねぎらわれたいものです。',
    '{city}のまわりの空気を、{weather}が彩ります。丘も電線もネオンも、旅のワンシーンです。',
    'いま{city}のど真ん中を通っています。{weather}。ほんの数十秒、好奇心にハンドルをゆずってみて。',
    '高速のスピードで一瞬だけ{city}はあなたのもの、{weather}。いつかゆっくり戻る日があるかもしれません。',
    '{city}の外では、{weather}。ドライブはコインホルダーの小銭みたいに思い出を拾っていきます。',
    'すぐに{city}はミラーの奥へ、{weather}。この章はまだ書きかけです。',
    '{city}の近く。{weather}。どの出口もひとつの「もしも」——今日はすべて選ばなくて大丈夫。',
  ];

  static const _zh = [
    '今天你正驶过{city}一带。{weather}。不妨留意窗外掠过的风景。',
    '靠近{city}时，{weather}。不妨想象这一段路有自己的配乐。',
    '{city}从窗边掠过。{weather}。招牌与小路都在诉说此刻身在何处。',
    '从快车道悄悄向{city}问好。{weather}。小镇与高楼都值得一声招呼。',
    '{city}周围的氛围里，{weather}添了一笔。山峦、电线或霓虹，都是旅程的一部分。',
    '你正穿行{city}。{weather}。就让好奇心接管方向盘几十秒也无妨。',
    '在高速上与{city}擦肩而过，{weather}。也许哪天你会有空再来停靠。',
    '来到{city}外，{weather}。公路旅行像在零钱格里积攒回忆。',
    '很快{city}会在后视镜里远去。{weather}。这一章还在书写。',
    '靠近{city}，{weather}。每个出口都是一种可能——今天不必每个岔路都做选择。',
  ];

  static const _es = [
    'Hoy pasas por {city}. {weather}. Deja que lo que ves al borde de la carretera se quede un kilometro.',
    'Cerca de {city}, {weather}. Imagina que este tramo tiene banda sonora propia.',
    '{city} se desliza tras el cristal — {weather}. Letreros y callejuelas dicen dónde estás.',
    'Saluda en silencio a {city} desde el carril. {weather}. Pueblos y rascacielos merecen un gesto.',
    '{weather} marca el ambiente alrededor de {city}. Colinas, cables o neón: parte del viaje.',
    'Atraviesas {city} ahora. {weather}. Presta el volante a la curiosidad treinta segundos.',
    '{city}, tuya un instante a velocidad de autopista. {weather}. Quizá vuelvas con tiempo para estacionar.',
    'Fuera de {city}, {weather}. Los road trips guardan recuerdos como monedas sueltas.',
    'Pronto {city} quedará en el retrovisor. {weather}. Este capítulo aún se escribe.',
    'Junto a {city}, {weather}. Cada salida es un quizás — disfruta la página sin elegir todo.',
  ];

  static const _de = [
    'Heute rollst du durch {city}. {weather}. Lass dir auf der Schulter, was ins Auge fällt, eine Weile hängen.',
    'Nahe {city}, {weather}. Tu so, als hätte diese Strecke eine eigene Playlist.',
    '{city} gleitet am Fenster vorbei — {weather}. Werbung und Seitenstraßen verraten, wo du bist.',
    'Grüß {city} leise aus der Überholspur. {weather}. Kleine Orte und große Skyline verdienen einen Punkt.',
    '{weather} mischt sich ins Bild um {city}. Hügel, Leitungen oder Neon gehören zur Fahrt.',
    'Du durchquerst jetzt {city}. {weather}. Überlass das Lenkrad der Neugier für ein paar Sekunden.',
    '{city}, für einen Moment deins auf der Autobahn. {weather}. Vielleicht kommst du zurück mit Zeit zum Parken.',
    'Vor {city}, {weather}. Roadtrips sammeln Erinnerungen wie Kleingeld.',
    'Bald rückt {city} im Rückspiegel ab. {weather}. Dieses Kapitel schreibt sich noch.',
    'Nahe {city}, {weather}. Jede Ausfahrt ist ein Vielleicht — genieß die Seite ohne jeden Abzweig.',
  ];

  static const _fr = [
    "Aujourd'hui tu traverses {city}. {weather}. Laisse ce qui attire l'œil au bord de la route te suivre un peu.",
    'Près de {city}, {weather}. Imagine que ce bout de route a sa propre bande-son.',
    '{city} défile derrière la vitre — {weather}. Panneaux et ruelles disent où tu es.',
    'Dis bonjour à {city} depuis la voie de dépassement. {weather}. Villages et gratte-ciel méritent un clin d’œil.',
    '{weather} teinte l’ambiance autour de {city}. Collines, fils ou néons font partie du trajet.',
    'Tu traverses {city} maintenant. {weather}. Prête le volant à la curiosité quelques secondes.',
    '{city}, à toi un instant à vitesse autoroutière. {weather}. Peut-être reviendras-tu avec du temps pour te garer.',
    'Aux abords de {city}, {weather}. Les road trips ramassent des souvenirs comme des pièces.',
    'Bientôt {city} sera dans le rétro. {weather}. Ce chapitre s’écrit encore.',
    'Près de {city}, {weather}. Chaque sortie est un peut-être — savoure la page sans tout choisir.',
  ];
}
