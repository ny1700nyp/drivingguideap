import Foundation

struct CurrentCityInfo {
  let cityName: String
  let stateName: String?
  let routeContext: String?

  init(cityName: String, stateName: String?, routeContext: String?) {
    self.cityName = cityName
    self.stateName = stateName
    self.routeContext = routeContext
  }

  init(map: [String: Any]) {
    cityName = map["cityName"] as? String ?? "Current town"
    stateName = map["stateName"] as? String
    routeContext = map["routeContext"] as? String
  }
}

struct TravelGuideAPIData {
  let roots: [String]
  let landmarks: [String]
  let scenicViewpoints: [String]
  let famousFigures: [String]

  init(
    roots: [String],
    landmarks: [String],
    scenicViewpoints: [String],
    famousFigures: [String]
  ) {
    self.roots = roots
    self.landmarks = landmarks
    self.scenicViewpoints = scenicViewpoints
    self.famousFigures = famousFigures
  }

  init(map: [String: Any]) {
    roots = Self.stringList(from: map["roots"])
    landmarks = Self.stringList(from: map["landmarks"])
    scenicViewpoints = Self.stringList(from: map["scenicViewpoints"])
    famousFigures = Self.stringList(from: map["famousFigures"])
  }

  static func stringList(from value: Any?) -> [String] {
    if let values = value as? [String] {
      return values
    }
    if let value = value as? String, !value.isEmpty {
      return [value]
    }
    return []
  }
}

struct RecentLocationHistory {
  let cityName: String
  let topics: [String]

  init(map: [String: Any]) {
    cityName = map["cityName"] as? String ?? "Previous town"
    topics = TravelGuideAPIData.stringList(from: map["topics"])
  }

  static func list(from maps: [[String: Any]]?) -> [RecentLocationHistory] {
    maps?.prefix(3).map { RecentLocationHistory(map: $0) } ?? []
  }
}

enum TravelPromptBuilder {
  static func makeStoryPrompt(
    cityName: String,
    factsData: String
  ) -> String {
    return """
    You are a captivating, cinematic documentary narrator, blending the precision of a historian with the emotional pull of a passionate storyteller.

    Write the final narration in natural English.

    Style:
    - Immersive and cinematic
    - Documentary-style, vivid, and grounded in fact
    - Suitable for someone driving

    Constraints:
    - Keep it under 150 words
    - Make it a seamless narrative story. No bullet points. No lists.
    - Weave together history/origin, landmarks, scenic viewpoints, and famous figures when facts support them.
    - Naturally connect elements where possible, such as linking a famous figure's childhood to a landmark, street, landscape, or viewpoint.
    - Mention the city or town name at most once. After that, use natural pronouns or phrases such as "it", "this town", "here", or "there". Avoid starting multiple sentences with the city or town name.
    - Use only the facts below
    - Do not mention restaurants, restrooms, parking, utility stops, shopping, APIs, missing data, or instructions.
    - Output only the final narration text

    Facts:
    \(factsData)
    """
  }

  static func makeSystemPrompt(
    currentCityInfo: CurrentCityInfo,
    apiData: TravelGuideAPIData,
    recentHistory: [RecentLocationHistory]
  ) -> String {
    let recentTopicsText = recentHistory.prefix(3).map { history in
      let topics = history.topics.isEmpty ? "no recorded topics" : history.topics.joined(separator: ", ")
      return "- \(history.cityName): \(topics)"
    }.joined(separator: "\n")

    let cityDisplayName = [
      currentCityInfo.cityName,
      currentCityInfo.stateName,
    ]
      .compactMap { value in
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
          return nil
        }
        return value
      }
      .joined(separator: ", ")

    return """
    You are a captivating, cinematic documentary narrator, blending the precision of a historian with the emotional pull of a passionate storyteller.
    Speak to a driver passing through \(cityDisplayName) with the feeling of a beautifully edited documentary scene.

    Route context:
    \(currentCityInfo.routeContext ?? "No route context provided.")

    Recent topics to avoid repeating:
    \(recentTopicsText.isEmpty ? "No recent topics provided." : recentTopicsText)

    Core content pillars for \(cityDisplayName):
    The Roots, history and origin:
    \(compactList(apiData.roots))

    The Icons, landmarks and distinctive structures:
    \(compactList(apiData.landmarks))

    The Canvas, scenic viewpoints and nearby natural places:
    \(compactList(apiData.scenicViewpoints))

    The Legends, famous figures born or raised here:
    \(compactList(apiData.famousFigures))

    Output requirements:
    Write one seamless, immersive narrative story for the traveler, maximum 150 words.
    No bullet points. No lists.
    Avoid repeating topics from recent history when alternatives are available.
    Weave the pillars together naturally; for example, connect a famous figure's childhood to a landmark, street, landscape, or viewpoint.
    Include only details supported by the provided data.
    Do not mention restaurants, restrooms, parking, utility stops, shopping, missing data, API fields, instructions, or recent-history analysis.
    Output only the final narration text.
    """
  }

  private static func compactList(_ values: [String]) -> String {
    let cleanedValues = values
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    return cleanedValues.isEmpty ? "None provided." : cleanedValues.joined(separator: "; ")
  }
}
