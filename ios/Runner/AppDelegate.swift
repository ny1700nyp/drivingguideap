import Flutter
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let localLLMService = AppleLocalLLMService()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerLocalLLMChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func registerLocalLLMChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "drivingguide/local_llm",
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { [localLLMService] call, result in
      switch call.method {
      case "fetchMapKitFacts":
        guard
          let arguments = call.arguments as? [String: Any],
          let regionName = arguments["regionName"] as? String
        else {
          result(FlutterError(
            code: "bad_arguments",
            message: "fetchMapKitFacts requires regionName.",
            details: nil
          ))
          return
        }

        Task {
          let facts = await MapKitFactFetcher.fetchFacts(
            regionName: regionName,
            latitude: arguments["latitude"] as? Double,
            longitude: arguments["longitude"] as? Double
          )
          result(facts)
        }
      case "buildTravelPrompt":
        guard
          let arguments = call.arguments as? [String: Any],
          let currentCityInfoMap = arguments["currentCityInfo"] as? [String: Any],
          let apiDataMap = arguments["apiData"] as? [String: Any]
        else {
          result(FlutterError(
            code: "bad_arguments",
            message: "buildTravelPrompt requires currentCityInfo and apiData.",
            details: nil
          ))
          return
        }

        let prompt = TravelPromptBuilder.makeSystemPrompt(
          currentCityInfo: CurrentCityInfo(map: currentCityInfoMap),
          apiData: TravelGuideAPIData(map: apiDataMap),
          recentHistory: RecentLocationHistory.list(
            from: arguments["recentHistory"] as? [[String: Any]]
          )
        )
        result(prompt)
      case "buildStoryPrompt":
        guard
          let arguments = call.arguments as? [String: Any],
          let cityName = arguments["cityName"] as? String,
          let factsData = arguments["factsData"] as? String
        else {
          result(FlutterError(
            code: "bad_arguments",
            message: "buildStoryPrompt requires cityName and factsData.",
            details: nil
          ))
          return
        }

        result(TravelPromptBuilder.makeStoryPrompt(
          cityName: cityName,
          factsData: factsData
        ))
      case "getModelInfo":
        Task {
          let modelInfo = await localLLMService.modelInfo()
          result(modelInfo)
        }
      case "loadModel":
        Task {
          _ = await localLLMService.loadModel()
          result(nil)
        }
      case "generateText":
        guard
          let arguments = call.arguments as? [String: Any],
          let prompt = arguments["prompt"] as? String
        else {
          result(FlutterError(
            code: "bad_arguments",
            message: "generateText requires a prompt string.",
            details: nil
          ))
          return
        }

        Task {
          let generatedText = await localLLMService.generateText(prompt: prompt)
          result(generatedText)
        }
      case "enterStandby":
        Task {
          await localLLMService.enterStandby()
          result(nil)
        }
      case "unloadModel":
        Task {
          await localLLMService.unloadModel()
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private actor AppleLocalLLMService {
  #if canImport(FoundationModels)
  private var generator: Any?
  #endif

  func modelInfo() async -> [String: Any] {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      let availability: String
      let usesFallback: Bool
      switch SystemLanguageModel.default.availability {
      case .available:
        availability = "Available"
        usesFallback = false
      default:
        availability = "Unavailable on this device or disabled in Settings"
        usesFallback = true
      }

      return [
        "provider": "Apple Foundation Models",
        "modelName": "SystemLanguageModel.default",
        "availability": availability,
        "usesFallback": usesFallback,
      ]
    }
    #endif

    return [
      "provider": "Dart fallback",
      "modelName": "Template fallback generator",
      "availability": "Foundation Models framework unavailable on this OS",
      "usesFallback": true,
    ]
  }

  func loadModel() async -> Bool {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      if generator == nil {
        generator = FoundationModelsTextGenerator()
      }
      return await (generator as? FoundationModelsTextGenerator)?.load() ?? false
    }
    #endif

    return false
  }

  func generateText(prompt: String) async -> String? {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      if generator == nil {
        generator = FoundationModelsTextGenerator()
      }

      do {
        return try await (generator as? FoundationModelsTextGenerator)?
          .generate(prompt: prompt)
      } catch {
        return nil
      }
    }
    #endif

    return nil
  }

  func enterStandby() async {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      (generator as? FoundationModelsTextGenerator)?.enterStandby()
    }
    #endif
  }

  func unloadModel() async {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      (generator as? FoundationModelsTextGenerator)?.unload()
      generator = nil
    }
    #endif
  }
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
private final class FoundationModelsTextGenerator {
  private var session: LanguageModelSession?

  func load() async -> Bool {
    switch SystemLanguageModel.default.availability {
    case .available:
      if session == nil {
        session = LanguageModelSession(instructions: """
        You are a narrator speaking to a driver.
        Speak only as finished roadside narration for in-car audio.
        Keep responses concise, immersive, and grounded. Never ask how you can help.
        Never say you are an assistant. Never output labels, markdown, or meta
        commentary.
        """)
      }
      return true
    default:
      return false
    }
  }

  func generate(prompt: String) async throws -> String? {
    guard await load(), let session else {
      return nil
    }

    let response = try await session.respond(to: prompt)
    let content = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    return content.isEmpty ? nil : content
  }

  func enterStandby() {
    // Reset the stateful conversation so the next city starts from a clean prompt.
    session = nil
  }

  func unload() {
    session = nil
  }
}
#endif
