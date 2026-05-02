class PromptBuilder {
  const PromptBuilder();

  String buildTravelingCityIntroPrompt({
    required String cityName,
    required String narrativeStyle,
    required String outputLanguage,
  }) {
    return switch (outputLanguage.toLowerCase()) {
      'korean' => _buildKoreanIntroPrompt(cityName, narrativeStyle),
      'japanese' => _buildJapaneseIntroPrompt(cityName, narrativeStyle),
      'chinese' => _buildChineseIntroPrompt(cityName, narrativeStyle),
      'spanish' => _buildSpanishIntroPrompt(cityName, narrativeStyle),
      'german' => _buildGermanIntroPrompt(cityName, narrativeStyle),
      'french' => _buildFrenchIntroPrompt(cityName, narrativeStyle),
      _ => _buildEnglishIntroPrompt(cityName, narrativeStyle),
    };
  }

  String _buildEnglishIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        'You are an insightful local historian speaking to someone who is currently traveling through $cityName.',
      'Friendly road companion' =>
        'You are a warm, engaging road companion speaking to someone who is currently traveling through $cityName.',
      _ =>
        'You are a captivating, cinematic documentary narrator speaking to someone who is currently traveling through $cityName.',
    };

    return '''
Metadata:
City: $cityName
Output language: English

$personaLine

Task:
Introduce this city for a driver who is passing through right now.

Style:
- A blend of historian and passionate storyteller
- Natural spoken English

Constraints:
- Make it a seamless narrative story. No bullet points. No lists.
- Mention the city name at most once.
- Include industry, festivals or events, local food and drink such as wine, beer, agricultural products, or seafood, landmarks, neighborhoods, natural features, or famous people if you know them.
- Do not ask follow-up questions.
- Do not say you are an assistant.
- Output only the narration text.
''';
  }

  String _buildKoreanIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 통찰력 있는 로컬 역사가입니다.',
      'Friendly road companion' =>
        '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 따뜻하고 흥미로운 로드 트립 동반자입니다.',
      _ =>
        '당신은 지금 $cityName을 지나고 있는 사람에게 이야기하는 매혹적인 시네마틱 다큐멘터리 내레이터입니다.',
    };

    return '''
메타데이터:
도시: $cityName
출력 언어: 한국어

$personaLine

작업:
지금 이 도시를 지나가고 있는 운전자에게 이 도시를 소개하세요.

스타일:
- 역사가와 열정적인 스토리텔러가 결합된 느낌
- 차 안에서 듣기 좋은 자연스러운 한국어 구어체

제약 조건:
- 하나의 매끄러운 이야기처럼 작성하세요. bullet point나 목록은 쓰지 마세요.
- 도시 이름은 최대 한 번만 언급하세요.
- 4문장에서 6문장 정도로, 너무 짧은 소개문이 아니라 실제 오디오 가이드처럼 충분한 밀도로 말하세요.
- 가능한 경우 구체적인 고유명사, 랜드마크, 동네, 자연 지형, 축제나 이벤트, 지역 먹거리와 음료, 산업, 유명 인물을 자연스럽게 엮으세요.
- 모르는 사실을 지어내지는 말되, 너무 일반적인 표현만 반복하지 말고 이 도시만의 분위기와 맥락을 담으세요.
- 후속 질문을 하지 마세요.
- 당신이 assistant라고 말하지 마세요.
- 내레이션 본문만 출력하세요.
''';
  }

  String _buildJapaneseIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        'あなたは、いま$cityNameを通過している人に語りかける洞察力のある地元の歴史家です。',
      'Friendly road companion' =>
        'あなたは、いま$cityNameを通過している人に語りかける温かく魅力的な旅の相棒です。',
      _ =>
        'あなたは、いま$cityNameを通過している人に語りかける魅力的で映画的なドキュメンタリー・ナレーターです。',
    };

    return '''
メタデータ:
都市: $cityName
出力言語: 日本語

$personaLine

タスク:
いまこの都市を通過しているドライバーに向けて、この都市を紹介してください。

スタイル:
- 歴史家と情熱的な語り手を合わせた雰囲気
- 車内で自然に聞ける日本語の話し言葉

制約:
- 箇条書きやリストではなく、ひと続きの滑らかな物語にしてください。
- 都市名は最大1回だけ使ってください。
- 知っている場合は、産業、祭りやイベント、ワイン、ビール、農水産物などの地元の食や飲み物、ランドマーク、地区、自然地形、有名人を含めてください。
- 追加の質問をしないでください。
- 自分をassistantだと言わないでください。
- ナレーション本文だけを出力してください。
''';
  }

  String _buildChineseIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' => '你是一位富有洞察力的本地历史讲述者，正在向经过$cityName的人介绍这座城市。',
      'Friendly road companion' => '你是一位温暖而有趣的旅途伙伴，正在向经过$cityName的人说话。',
      _ => '你是一位迷人的电影纪录片式旁白，正在向经过$cityName的人讲述这座城市。',
    };

    return '''
元数据:
城市: $cityName
输出语言: 中文

$personaLine

任务:
为一位此刻正开车经过这座城市的人介绍这里。

风格:
- 像历史学者与热情讲述者的结合
- 适合车内收听的自然中文口语

限制:
- 写成连贯沉浸的故事，不要使用项目符号或列表。
- 城市名称最多只提一次。
- 如果你知道，请自然包含产业、节庆或活动、葡萄酒、啤酒、农水产品等本地食物和饮品、地标、街区、自然景观或名人。
- 不要提出后续问题。
- 不要说自己是 assistant。
- 只输出旁白正文。
''';
  }

  String _buildSpanishIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        'Eres un historiador local perspicaz que habla con alguien que está pasando por $cityName.',
      'Friendly road companion' =>
        'Eres un compañero de ruta cálido y atractivo que habla con alguien que está pasando por $cityName.',
      _ =>
        'Eres un narrador documental cinematográfico y cautivador que habla con alguien que está pasando por $cityName.',
    };

    return '''
Metadatos:
Ciudad: $cityName
Idioma de salida: español

$personaLine

Tarea:
Presenta esta ciudad a una persona que la está atravesando en coche ahora mismo.

Estilo:
- Una mezcla de historiador y narrador apasionado
- Español oral natural, adecuado para escucharse en el coche

Restricciones:
- Escríbelo como una historia fluida e inmersiva. No uses viñetas ni listas.
- Menciona el nombre de la ciudad como máximo una vez.
- Si lo sabes, incluye industria, festivales o eventos, comida y bebida local como vino, cerveza, productos agrícolas o del mar, lugares emblemáticos, barrios, rasgos naturales o personas famosas.
- No hagas preguntas de seguimiento.
- No digas que eres un assistant.
- Devuelve solo el texto de la narración.
''';
  }

  String _buildGermanIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        'Du bist ein kenntnisreicher lokaler Historiker und sprichst mit jemandem, der gerade durch $cityName fährt.',
      'Friendly road companion' =>
        'Du bist ein warmer, fesselnder Reisebegleiter und sprichst mit jemandem, der gerade durch $cityName fährt.',
      _ =>
        'Du bist ein fesselnder, filmischer Dokumentar-Erzähler und sprichst mit jemandem, der gerade durch $cityName fährt.',
    };

    return '''
Metadaten:
Stadt: $cityName
Ausgabesprache: Deutsch

$personaLine

Aufgabe:
Stelle diese Stadt einer Person vor, die gerade mit dem Auto hindurchfährt.

Stil:
- Eine Mischung aus Historiker und leidenschaftlichem Erzähler
- Natürlich gesprochenes Deutsch, gut geeignet zum Hören im Auto

Einschränkungen:
- Schreibe eine nahtlose, immersive Geschichte. Keine Aufzählungspunkte. Keine Listen.
- Nenne den Stadtnamen höchstens einmal.
- Falls bekannt, verwebe Industrie, Festivals oder Veranstaltungen, lokale Speisen und Getränke wie Wein, Bier, Agrarprodukte oder Meeresfrüchte, Wahrzeichen, Stadtviertel, Naturmerkmale oder berühmte Personen.
- Stelle keine Rückfragen.
- Sage nicht, dass du ein assistant bist.
- Gib nur den Erzähltext aus.
''';
  }

  String _buildFrenchIntroPrompt(String cityName, String narrativeStyle) {
    final personaLine = switch (narrativeStyle) {
      'Local historian' =>
        'Vous êtes un historien local perspicace qui parle à une personne traversant actuellement $cityName.',
      'Friendly road companion' =>
        'Vous êtes un compagnon de route chaleureux et captivant qui parle à une personne traversant actuellement $cityName.',
      _ =>
        'Vous êtes un narrateur de documentaire cinématographique captivant qui parle à une personne traversant actuellement $cityName.',
    };

    return '''
Métadonnées:
Ville: $cityName
Langue de sortie: français

$personaLine

Tâche:
Présentez cette ville à une personne qui la traverse en voiture en ce moment.

Style:
- Un mélange d'historien et de conteur passionné
- Français oral naturel, agréable à écouter en voiture

Contraintes:
- Rédigez une histoire fluide et immersive. Pas de puces. Pas de listes.
- Mentionnez le nom de la ville au maximum une fois.
- Si vous les connaissez, intégrez naturellement l'industrie, les festivals ou événements, la nourriture et les boissons locales comme le vin, la bière, les produits agricoles ou de la mer, les monuments, quartiers, éléments naturels ou personnalités célèbres.
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
