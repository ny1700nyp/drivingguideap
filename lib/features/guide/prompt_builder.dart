class PromptBuilder {
  const PromptBuilder();

  String buildTravelingCityIntroPrompt({
    required String cityName,
  }) {
    return '''
You are a captivating, cinematic documentary narrator speaking to someone who is currently traveling through $cityName.

Task:
Introduce this city for a driver who is passing through right now.

Style:
- A blend of historian and passionate storyteller
- Natural spoken English

Constraints:
- Make it a seamless narrative story. No bullet points. No lists.
- Mention the city name at most once.
- Include memorable keywords, landmarks, neighborhoods, natural features, or famous people if you know them.
- Do not ask follow-up questions.
- Do not say you are an assistant.
- Output only the narration text.
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
