// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Twingl Road';

  @override
  String get loadingVoices => '音声を読み込み中...';

  @override
  String get systemDefaultEnglishVoice => 'システム標準の音声を使用しています。';

  @override
  String voiceLoadError(Object error) {
    return '音声を読み込めませんでした: $error';
  }

  @override
  String voiceAvailabilityStatus(int count, Object quality) {
    return 'プレミアム/高品質の音声が$count件利用可能です。選択中: $quality。';
  }

  @override
  String usingVoice(Object voiceName) {
    return '$voiceNameを使用しています。';
  }

  @override
  String get startGuidingDialogTitle => 'ガイドを開始しますか？';

  @override
  String get startGuidingDialogMessage =>
      'ガイドが有効になります。新しい町に入るたびに、歴史、ランドマーク、地元の味わいを自動で紹介します。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get fullNarrative => '全文ナレーション';

  @override
  String get noLocationYet => 'まだ位置情報がありません';

  @override
  String get currentArea => '現在地';

  @override
  String get startAreaMonitoringPlaceholder => 'エリアガイドを開始してください。';

  @override
  String get startGuiding => 'ガイド開始';

  @override
  String get pauseGuide => 'ガイドを一時停止';

  @override
  String get checkThisTown => 'この町を確認';

  @override
  String get startTestRoute => 'Sacramento to Seattle テストルートを開始';

  @override
  String get stopTestRoute => 'テストルートを停止';

  @override
  String get prevStop => '前の地点';

  @override
  String get nextStop => '次の地点';

  @override
  String get heritage => '歴史';

  @override
  String heritageBody(Object areaName) {
    return '$areaNameを形づくった名前の由来と物語。';
  }

  @override
  String get icons => '名所';

  @override
  String get iconsBody => 'この場所にゆかりのある有名人や地域のエピソード。';

  @override
  String get views => '景色';

  @override
  String get viewsBody => '近くの美しい展望スポットや短い寄り道。';

  @override
  String get bites => '味わい';

  @override
  String get bitesBody => '記憶に残る地元の食べ物や飲み物。';

  @override
  String get goods => '特産品';

  @override
  String get goodsBody => '季節の産品、ワイン、ビール、海産物、農業。';

  @override
  String get trivia => '豆知識';

  @override
  String get triviaBody => '映画ロケ地、祭り、イベント、小さな地域の発見。';

  @override
  String get digitalMagazine => 'デジタルマガジン';

  @override
  String detailsIntro(Object areaName) {
    return '少し立ち寄って、$areaNameの奥にある物語を探ってみましょう。';
  }

  @override
  String get relatedLinks => '関連リンク';

  @override
  String get personaSettings => 'ペルソナ設定';

  @override
  String get narrativeStyle => 'ナレーションスタイル';

  @override
  String get cinematicStoryteller => 'シネマティック・ストーリーテラー';

  @override
  String get localHistorian => '地元の歴史家';

  @override
  String get friendlyRoadCompanion => '親しみやすい旅の相棒';

  @override
  String get voiceSettings => '音声設定';

  @override
  String get firstLlmPrompt => '第1 LLM プロンプト';

  @override
  String get noFirstLlmPrompt => 'まだ第1 LLM プロンプトは生成されていません。';

  @override
  String get liveGuide => 'ライブガイド';

  @override
  String get details => '詳細';

  @override
  String get more => 'その他';

  @override
  String get cruisingTowardsNextDiscovery => '次の発見へ向かっています。';

  @override
  String get liveNarrative => 'ライブナレーション';

  @override
  String get expandNarrative => 'ナレーションを展開';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get replay => 'もう一度再生';

  @override
  String get thinking => '考え中';

  @override
  String get noRelatedLinks => '関連リンクはまだ準備されていません。';

  @override
  String get voice => '音声';

  @override
  String get systemDefault => 'システム標準';

  @override
  String get moreVoice => 'さらに音声を追加しますか？';

  @override
  String get moreVoiceDescription =>
      '新しい音声は、設定 > アクセシビリティ > 読み上げコンテンツ > 声 から追加できます。';
}
