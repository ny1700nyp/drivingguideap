import AVFoundation
import Combine
import Foundation

@MainActor
final class TTSManager: NSObject, ObservableObject {
  @Published private(set) var needsPremiumVoiceDownload = false

  private let synthesizer = AVSpeechSynthesizer()
  private var previousAudioCategory: AVAudioSession.Category?
  private var previousAudioMode: AVAudioSession.Mode?
  private var previousAudioOptions: AVAudioSession.CategoryOptions?

  override init() {
    super.init()
    synthesizer.delegate = self
  }

  func speak(_ text: String) {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty else {
      return
    }

    let utterance = AVSpeechUtterance(string: trimmedText)
    utterance.voice = preferredEnglishVoice()
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    utterance.pitchMultiplier = 1.0
    utterance.volume = 1.0

    configureAudioSessionForDucking()
    synthesizer.stopSpeaking(at: .immediate)
    synthesizer.speak(utterance)
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
    restoreAudioSession()
  }

  private func preferredEnglishVoice() -> AVSpeechSynthesisVoice? {
    let englishVoices = AVSpeechSynthesisVoice.speechVoices().filter {
      $0.language.hasPrefix("en")
    }

    if #available(iOS 16.0, *) {
      if let premiumVoice = englishVoices.first(where: { $0.quality == .premium }) {
        needsPremiumVoiceDownload = false
        return premiumVoice
      }
    }

    needsPremiumVoiceDownload = true
    NSLog(
      "Premium English voice is not installed. Please download it from Settings > Accessibility > Spoken Content."
    )

    if let enhancedVoice = englishVoices.first(where: { $0.quality == .enhanced }) {
      return enhancedVoice
    }

    return AVSpeechSynthesisVoice(language: "en-US") ?? englishVoices.first
  }

  private func configureAudioSessionForDucking() {
    let audioSession = AVAudioSession.sharedInstance()
    previousAudioCategory = audioSession.category
    previousAudioMode = audioSession.mode
    previousAudioOptions = audioSession.categoryOptions

    do {
      try audioSession.setCategory(
        .playback,
        mode: .spokenAudio,
        options: [.duckOthers]
      )
      try audioSession.setActive(true)
    } catch {
      NSLog("Failed to configure TTS audio session: \(error.localizedDescription)")
    }
  }

  private func restoreAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()

    do {
      try audioSession.setActive(false, options: .notifyOthersOnDeactivation)

      if let category = previousAudioCategory {
        try audioSession.setCategory(
          category,
          mode: previousAudioMode ?? .default,
          options: previousAudioOptions ?? []
        )
      }
    } catch {
      NSLog("Failed to restore TTS audio session: \(error.localizedDescription)")
    }
  }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
  nonisolated func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    Task { @MainActor in
      self.restoreAudioSession()
    }
  }

  nonisolated func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didCancel utterance: AVSpeechUtterance
  ) {
    Task { @MainActor in
      self.restoreAudioSession()
    }
  }
}
