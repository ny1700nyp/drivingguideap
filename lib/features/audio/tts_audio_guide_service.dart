import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsAudioGuideService {
  TtsAudioGuideService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> configure() async {
    if (_configured) {
      return;
    }

    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.assistanceNavigationGuidance,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: false,
      ),
    );

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1);
    await _tts.setVolume(1);
    await _tts.awaitSpeakCompletion(true);
    _configured = true;
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    await configure();
    final session = await AudioSession.instance;
    await session.setActive(true);

    try {
      await _tts.stop();
      await _tts.speak(text);
    } finally {
      await session.setActive(false);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    final session = await AudioSession.instance;
    await session.setActive(false);
  }
}
