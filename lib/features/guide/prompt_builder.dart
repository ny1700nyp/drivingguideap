/// Title + detailed description for a user persona (injected into the first LLM prompt).
class CustomPersonaPromptContent {
  const CustomPersonaPromptContent({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class PromptBuilder {
  const PromptBuilder();

  /// Stored narrative style values use this prefix plus a stable id (see app prefs).
  static const customPersonaValuePrefix = 'customPersona:';

  String buildTravelingCityIntroPrompt({
    required String cityName,
    required String narrativeStyle,
    required String outputLanguage,
    Map<String, CustomPersonaPromptContent> customPersonasById = const {},
  }) {
    final customs = customPersonasById;
    return switch (outputLanguage.toLowerCase()) {
      'korean' => _buildKoreanIntroPrompt(cityName, narrativeStyle, customs),
      'japanese' => _buildJapaneseIntroPrompt(cityName, narrativeStyle, customs),
      'chinese' => _buildChineseIntroPrompt(cityName, narrativeStyle, customs),
      'spanish' => _buildSpanishIntroPrompt(cityName, narrativeStyle, customs),
      'german' => _buildGermanIntroPrompt(cityName, narrativeStyle, customs),
      'french' => _buildFrenchIntroPrompt(cityName, narrativeStyle, customs),
      _ => _buildEnglishIntroPrompt(cityName, narrativeStyle, customs),
    };
  }

  String? _customPersonaIntro({
    required String templateLang,
    required String cityName,
    required String narrativeStyle,
    required Map<String, CustomPersonaPromptContent> customs,
  }) {
    if (!narrativeStyle.startsWith(customPersonaValuePrefix)) {
      return null;
    }
    final id = narrativeStyle.substring(customPersonaValuePrefix.length);
    final entry = customs[id];
    if (entry == null) return null;
    final title = entry.title.trim();
    final description = entry.description.trim();
    if (title.isEmpty || description.isEmpty) {
      return null;
    }

    return switch (templateLang) {
      'english' =>
        '''Follow this persona direction exactly.

Persona title: $title

Persona description:
$description

You are addressing someone who is currently traveling through $cityName.''',
      'korean' =>
        '''아래 페르소나 지침을 정확히 따르세요.

페르소나 제목: $title

페르소나 설명:
$description

지금 $cityName을 지나가고 있는 사람에게 말하고 있습니다.''',
      'japanese' =>
        '''次のペルソナ指示に正確に従ってください。

ペルソナのタイトル: $title

ペルソナの説明:
$description

いま$cityNameを通過している人に話しかけています。''',
      'chinese' =>
        '''请严格遵循以下人设指引：

人设标题：$title

人设描述：
$description

你正在向经过$cityName的人讲述。''',
      'spanish' =>
        '''Sigue exactamente esta dirección de persona:

Título de la persona: $title

Descripción de la persona:
$description

Te diriges a alguien que está pasando por $cityName.''',
      'german' =>
        '''Befolge genau diese Persona-Anweisung:

Persona-Titel: $title

Persona-Beschreibung:
$description

Du sprichst mit jemandem, der gerade durch $cityName fährt.''',
      'french' =>
        '''Suivez exactement cette direction de persona :

Titre de la persona : $title

Description de la persona :
$description

Vous vous adressez à une personne qui traverse actuellement $cityName.''',
      _ =>
        '''Follow this persona direction exactly.

Persona title: $title

Persona description:
$description

You are addressing someone who is currently traveling through $cityName.''',
    };
  }

  String _buildEnglishIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'english',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            'You are an insightful local historian speaking to someone who is currently traveling through $cityName.',
          'Friendly road companion' =>
            'You are a warm, engaging road companion speaking to someone who is currently traveling through $cityName.',
          'Energetic Town Wit' =>
            'You are a lively local wit speaking to someone who is currently traveling through $cityName, with brisk energy and clever observations.',
          _ =>
            'You are a narrator speaking to someone who is currently traveling through $cityName.',
        };

    return '''
Metadata:
City: $cityName
Output language: English

$personaLine

Task:
Introduce this city for a driver who is passing through right now.

Constraints:
- Make it a seamless narrative story. No bullet points. No lists.
- Mention the city name at most once.
- Do not ask follow-up questions.
- Do not say you are an assistant.
- Output only the narration text.
''';
  }

  String _buildKoreanIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'korean',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 통찰력 있는 로컬 역사가입니다.',
          'Friendly road companion' =>
            '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 따뜻하고 흥미로운 로드 트립 동반자입니다.',
          'Energetic Town Wit' =>
            '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 활기찬 로컬 재치꾼입니다. 빠른 템포와 영리한 관찰로 도시를 소개합니다.',
          _ =>
            '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 내레이터입니다.',
        };

    return '''
메타데이터:
도시: $cityName
출력 언어: 한국어

$personaLine

작업:
지금 이 도시를 지나가고 있는 운전자에게 이 도시를 소개하세요.

제약 조건:
- 하나의 매끄러운 이야기처럼 작성하세요. bullet point나 목록은 쓰지 마세요.
- 도시 이름은 최대 한 번만 언급하세요.
- 4문장에서 6문장 정도로, 너무 짧은 소개문이 아니라 실제 오디오 가이드처럼 충분한 밀도로 말하세요.
- 모르는 사실을 지어내지는 말되, 너무 일반적인 표현만 반복하지 말고 이 도시만의 분위기와 맥락을 담으세요.
- 후속 질문을 하지 마세요.
- 당신이 assistant라고 말하지 마세요.
- 내레이션 본문만 출력하세요.
''';
  }

  String _buildJapaneseIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'japanese',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            'あなたは、いま$cityNameを通過している人に語りかける洞察力のある地元の歴史家です。',
          'Friendly road companion' =>
            'あなたは、いま$cityNameを通過している人に語りかける温かく魅力的な旅の相棒です。',
          'Energetic Town Wit' =>
            'あなたは、いま$cityNameを通過している人に語りかける活気ある地元のウィット役です。軽快なテンポと気の利いた観察で街を紹介します。',
          _ =>
            'あなたは、いま$cityNameを通過している人に語りかけるナレーターです。',
        };

    return '''
メタデータ:
都市: $cityName
出力言語: 日本語

$personaLine

タスク:
いまこの都市を通過しているドライバーに向けて、この都市を紹介してください。

制約:
- 箇条書きやリストではなく、ひと続きの滑らかな物語にしてください。
- 都市名は最大1回だけ使ってください。
- 追加の質問をしないでください。
- 自分をassistantだと言わないでください。
- ナレーション本文だけを出力してください。
''';
  }

  String _buildChineseIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'chinese',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            '你是一位富有洞察力的本地历史讲述者，正在向经过$cityName的人介绍这座城市。',
          'Friendly road companion' =>
            '你是一位温暖而有趣的旅途伙伴，正在向经过$cityName的人说话。',
          'Energetic Town Wit' =>
            '你是一位充满活力的本地机智讲述者，正在向经过$cityName的人介绍这座城市，语气轻快并带有聪明的观察。',
          _ => '你是一位旁白者，正在向经过$cityName的人讲述这座城市。',
        };

    return '''
元数据:
城市: $cityName
输出语言: 中文

$personaLine

任务:
为一位此刻正开车经过这座城市的人介绍这里。

限制:
- 写成连贯沉浸的故事，不要使用项目符号或列表。
- 城市名称最多只提一次。
- 不要提出后续问题。
- 不要说自己是 assistant。
- 只输出旁白正文。
''';
  }

  String _buildSpanishIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'spanish',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            'Eres un historiador local perspicaz que habla con alguien que está pasando por $cityName.',
          'Friendly road companion' =>
            'Eres un compañero de ruta cálido y atractivo que habla con alguien que está pasando por $cityName.',
          'Energetic Town Wit' =>
            'Eres una voz local ingeniosa y enérgica que habla con alguien que está pasando por $cityName, con ritmo ágil y observaciones inteligentes.',
          _ =>
            'Eres un narrador que habla con alguien que está pasando por $cityName.',
        };

    return '''
Metadatos:
Ciudad: $cityName
Idioma de salida: español

$personaLine

Tarea:
Presenta esta ciudad a una persona que la está atravesando en coche ahora mismo.

Restricciones:
- Escríbelo como una historia fluida e inmersiva. No uses viñetas ni listas.
- Menciona el nombre de la ciudad como máximo una vez.
- No hagas preguntas de seguimiento.
- No digas que eres un assistant.
- Devuelve solo el texto de la narración.
''';
  }

  String _buildGermanIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'german',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            'Du bist ein kenntnisreicher lokaler Historiker und sprichst mit jemandem, der gerade durch $cityName fährt.',
          'Friendly road companion' =>
            'Du bist ein warmer, fesselnder Reisebegleiter und sprichst mit jemandem, der gerade durch $cityName fährt.',
          'Energetic Town Wit' =>
            'Du bist eine lebhafte lokale Stimme mit Witz und sprichst mit jemandem, der gerade durch $cityName fährt, mit flottem Tempo und klugen Beobachtungen.',
          _ =>
            'Du bist ein Erzähler und sprichst mit jemandem, der gerade durch $cityName fährt.',
        };

    return '''
Metadaten:
Stadt: $cityName
Ausgabesprache: Deutsch

$personaLine

Aufgabe:
Stelle diese Stadt einer Person vor, die gerade mit dem Auto hindurchfährt.

Einschränkungen:
- Schreibe eine nahtlose, immersive Geschichte. Keine Aufzählungspunkte. Keine Listen.
- Nenne den Stadtnamen höchstens einmal.
- Stelle keine Rückfragen.
- Sage nicht, dass du ein assistant bist.
- Gib nur den Erzähltext aus.
''';
  }

  String _buildFrenchIntroPrompt(
    String cityName,
    String narrativeStyle,
    Map<String, CustomPersonaPromptContent> customs,
  ) {
    final personaLine =
        _customPersonaIntro(
          templateLang: 'french',
          cityName: cityName,
          narrativeStyle: narrativeStyle,
          customs: customs,
        ) ??
        switch (narrativeStyle) {
          'Local historian' =>
            'Vous êtes un historien local perspicace qui parle à une personne traversant actuellement $cityName.',
          'Friendly road companion' =>
            'Vous êtes un compagnon de route chaleureux et captivant qui parle à une personne traversant actuellement $cityName.',
          'Energetic Town Wit' =>
            'Vous êtes une voix locale vive et spirituelle qui parle à une personne traversant actuellement $cityName, avec un rythme énergique et des observations malines.',
          _ =>
            'Vous êtes un narrateur qui parle à une personne traversant actuellement $cityName.',
        };

    return '''
Métadonnées:
Ville: $cityName
Langue de sortie: français

$personaLine

Tâche:
Présentez cette ville à une personne qui la traverse en voiture en ce moment.

Contraintes:
- Rédigez une histoire fluide et immersive. Pas de puces. Pas de listes.
- Mentionnez le nom de la ville au maximum une fois.
- Ne posez pas de questions de suivi.
- Ne dites pas que vous êtes un assistant.
- Ne produisez que le texte de la narration.
''';
  }

  String buildProperNounExtractionPrompt({
    required String narration,
  }) {
    return '''
You extract proper nouns from travel narration.

Task:
Read the narration below and extract only unique proper nouns that would be useful as links.

Rules:
- Extract names of places, landmarks, neighborhoods, natural features, institutions, events, organizations, and famous people.
- Do not extract generic nouns, adjectives, full sentences, or descriptive phrases that are not proper nouns.
- Remove duplicates and near-duplicates.
- Classify each item as exactly one of:
  - "place": physical locations, landmarks, neighborhoods, natural features, buildings, institutions, parks, bridges, streets, districts, museums.
  - "nonPlace": people, events, organizations, movements, historical periods, cultural references, or other named concepts.
- Output only valid JSON. No markdown. No explanation.
- Each JSON object must represent exactly one proper noun.
- The "label" value must be the actual proper noun text from the narration.
- The "kind" value must be a string, either "place" or "nonPlace".
- Do not nest objects or arrays inside "kind".
- Do not use placeholder labels like "Proper Noun".

Correct JSON example:
[
  {"label":"San Jose Museum of Art","kind":"place"},
  {"label":"William Wirt Winchester","kind":"nonPlace"}
]

Wrong output examples:
- {"label":"Proper Noun","kind":{"place":{"name":"San Jose"}}}
- {"label":"Proper Noun","kind":"place":{"name":"San Jose"}}
- {"place":["San Jose","Silicon Valley"]}

Narration:
$narration
''';
  }
}
