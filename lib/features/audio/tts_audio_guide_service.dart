import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../models/tts_voice.dart';

class SpeakingRange {
  const SpeakingRange({
    required this.start,
    required this.end,
    required this.word,
  });

  final int start;
  final int end;
  final String word;
}

class TtsAudioGuideService {
  TtsAudioGuideService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final _speakingRangeController = StreamController<SpeakingRange?>.broadcast();
  bool _configured = false;
  TtsVoice? _selectedVoice;
  String _defaultLanguage = 'en-US';
  int _speakingOffset = 0;
  bool _utteranceActive = false;

  TtsVoice? get selectedVoice => _selectedVoice;
  Stream<SpeakingRange?> get speakingRanges => _speakingRangeController.stream;
  /// True from the first [speak]/[speakFrom] segment until completion, cancel, or [stop].
  bool get isUtteranceActive => _utteranceActive;

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

    await _tts.setLanguage(_defaultLanguage);
    if (_selectedVoice != null) {
      await _tts.setVoice(_selectedVoice!.toFlutterTtsVoice());
    }
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1);
    await _tts.setVolume(1);
    await _tts.awaitSpeakCompletion(true);
    _tts.setProgressHandler((text, start, end, word) {
      _speakingRangeController.add(
        SpeakingRange(
          start: start + _speakingOffset,
          end: end + _speakingOffset,
          word: word,
        ),
      );
    });
    void clearUtterance() {
      _utteranceActive = false;
    }

    _tts.setCompletionHandler(() {
      clearUtterance();
      _speakingRangeController.add(null);
    });
    _tts.setCancelHandler(() {
      clearUtterance();
      _speakingRangeController.add(null);
    });
    _tts.setErrorHandler((_) {
      clearUtterance();
      _speakingRangeController.add(null);
    });
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

  Future<void> setDefaultLanguage(String language) async {
    _defaultLanguage = language;
    if (_configured && _selectedVoice == null) {
      await _tts.setLanguage(_defaultLanguage);
    }
  }

  Future<void> selectVoice(TtsVoice? voice) async {
    _selectedVoice = voice;
    await configure();
    if (voice == null) {
      await _tts.setLanguage(_defaultLanguage);
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

    await _speakSegment(text: text, offset: 0, stopFirst: true);
    await session.setActive(false);
  }

  Future<void> speakFrom(String text, int startIndex) async {
    final safeStart = _nearestWordStart(text, startIndex);
    if (safeStart >= text.length) {
      return;
    }
    await configure();
    final session = await AudioSession.instance;
    await session.setActive(true);
    await _speakSegment(
      text: text.substring(safeStart),
      offset: safeStart,
      stopFirst: true,
    );
    await session.setActive(false);
  }

  Future<void> stop() async {
    _utteranceActive = false;
    await _tts.stop();
    _speakingOffset = 0;
    _speakingRangeController.add(null);
    final session = await AudioSession.instance;
    await session.setActive(false);
  }

  Future<void> _speakSegment({
    required String text,
    required int offset,
    required bool stopFirst,
  }) async {
    try {
      if (stopFirst) {
        await _tts.stop();
      }
      _speakingOffset = offset;
      _utteranceActive = true;
      await _tts.speak(text);
    } finally {
      _speakingOffset = 0;
    }
  }

  int _nearestWordStart(String text, int index) {
    if (text.trim().isEmpty) {
      return text.length;
    }
    var safeIndex = index.clamp(0, text.length).toInt();
    while (safeIndex > 0 && !_isBoundary(text.codeUnitAt(safeIndex - 1))) {
      safeIndex--;
    }
    while (safeIndex < text.length && text.codeUnitAt(safeIndex) == 32) {
      safeIndex++;
    }
    return safeIndex;
  }

  bool _isBoundary(int codeUnit) {
    return codeUnit == 32 ||
        codeUnit == 10 ||
        codeUnit == 9 ||
        codeUnit == 45 ||
        codeUnit == 46 ||
        codeUnit == 44 ||
        codeUnit == 59 ||
        codeUnit == 58;
  }

  Future<void> dispose() async {
    await stop();
    await _speakingRangeController.close();
  }
}
