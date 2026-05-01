import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/tts_voice.dart';

class TtsAudioGuideService {
  TtsAudioGuideService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;
  TtsVoice? _selectedVoice;

  TtsVoice? get selectedVoice => _selectedVoice;

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
    if (_selectedVoice != null) {
      await _tts.setVoice(_selectedVoice!.toFlutterTtsVoice());
    }
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1);
    await _tts.setVolume(1);
    await _tts.awaitSpeakCompletion(true);
    _configured = true;
  }

  Future<List<TtsVoice>> availableVoices({String localePrefix = 'en-'}) async {
    final voices = await _tts.getVoices;
    if (voices is! List) {
      return const [];
    }

    final parsedVoices =
        voices
            .whereType<Map<dynamic, dynamic>>()
            .map(TtsVoice.fromMap)
            .where(
              (voice) =>
                  voice.name.trim().isNotEmpty &&
                  voice.isPreferredQuality &&
                  voice.locale.toLowerCase().startsWith(
                    localePrefix.toLowerCase(),
                  ),
            )
            .toList()
          ..sort((a, b) {
            final qualityCompare = a.qualityRank.compareTo(b.qualityRank);
            if (qualityCompare != 0) {
              return qualityCompare;
            }
            final localeCompare = a.locale.compareTo(b.locale);
            if (localeCompare != 0) {
              return localeCompare;
            }
            return a.name.compareTo(b.name);
          });

    return parsedVoices;
  }

  Future<void> selectVoice(TtsVoice? voice) async {
    _selectedVoice = voice;
    await configure();
    if (voice == null) {
      await _tts.setLanguage('en-US');
      return;
    }
    await _tts.setVoice(voice.toFlutterTtsVoice());
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
