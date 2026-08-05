// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Microzed';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonDelete => '削除';

  @override
  String get commonSave => '保存';

  @override
  String get commonEdit => '編集';

  @override
  String get commonAdd => '追加';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonCopy => 'コピー';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageDialogTitle => '言語を選択';

  @override
  String get languageSystemDefault => 'システム既定';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get myPageTitle => 'マイページ';

  @override
  String get myPageEditProfileButton => '会話プロフィール編集';

  @override
  String get myPageAiPresetButton => 'AIプリセット設定';

  @override
  String get myPageTokensUsedLabel => '使用トークン';

  @override
  String get myPageHistoryButton => '履歴';

  @override
  String get myPageBackupSectionTitle => 'データバックアップ';

  @override
  String get myPageBackupSectionDescription =>
      'プロット・キャラクター・会話・ロアブック・プリセットなどすべてのデータを1つのファイルとして保存・復元できます。';

  @override
  String get myPageExportAllButton => 'すべて保存';

  @override
  String get myPageImportAllButton => 'すべて読み込み';

  @override
  String get myPageExportSuccessMessage => 'すべてのデータを保存しました。';

  @override
  String myPageExportFailureMessage(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get myPageImportDialogTitle => 'すべて読み込み';

  @override
  String get myPageImportDialogContent =>
      '現在アプリ内にあるすべてのプロット・キャラクター・会話・ロアブック・プリセットが、このバックアップ内容で完全に置き換えられます。\nこの操作は元に戻せません。続けますか?';

  @override
  String get myPageImportRestoreButton => '復元';

  @override
  String myPageImportSuccessMessage(
    Object plotCount,
    Object chatMessageCount,
    Object lorebookCount,
  ) {
    return '復元完了: プロット$plotCount件、会話メッセージ$chatMessageCount件、ロアブック$lorebookCount件';
  }

  @override
  String myPageImportFailureMessage(Object error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get myPageLicensesButton => 'オープンソースライセンス';

  @override
  String get myPageSourceCodeButton => 'GitHubリポジトリ';

  @override
  String get myPageSnapshotSettingsButton => 'スナップショット設定';

  @override
  String get myPageLocalLlmButton => 'ローカルLLM';

  @override
  String get localLlmScreenTitle => 'ローカルLLM';

  @override
  String get localLlmScreenDescription =>
      'インターネット接続なしで端末上でAIモデルを直接実行します。速度と品質は端末の性能とモデルサイズによって変わります。';

  @override
  String get localLlmRecommendedSectionTitle => 'おすすめモデル';

  @override
  String get localLlmModelDescHuihuiQwen3508b => 'IQ4 XSなので性能はあまり期待しないでください。';

  @override
  String get localLlmModelDescHuihuiQwen354b => '速度と品質のバランス型。日本語対応も比較的良好。';

  @override
  String get localLlmModelDescHuihuiGemma4E2b => '最も軽くて速い。低スペック端末向け。';

  @override
  String get localLlmModelDescHuihuiGemma4E4b => 'より高品質。ハイスペック端末/PC推奨。';

  @override
  String get localLlmImportSectionTitle => 'ファイルから読み込み';

  @override
  String get localLlmSavedPresetsSectionTitle => '保存済みローカルプリセット';

  @override
  String get localLlmCacheSectionTitle => 'ダウンロード済みモデル';

  @override
  String get localLlmCurrentStatusLabel => '現在読み込まれているモデル';

  @override
  String get localLlmNoModelLoaded => '読み込まれたモデルはありません';

  @override
  String get localLlmUnloadButton => 'アンロード';

  @override
  String get localLlmUseButton => '使用';

  @override
  String get localLlmLoadButton => '読み込む';

  @override
  String get localLlmInUseLabel => '使用中';

  @override
  String get localLlmImportButton => 'GGUFファイルを選択';

  @override
  String get localLlmImportDescription => 'すでにダウンロード済みの.ggufモデルファイルを選択できます。';

  @override
  String get localLlmNoSavedPresets => '保存されたローカルプリセットはまだありません。';

  @override
  String get localLlmNoCachedModels => 'ダウンロード済みのモデルはありません。';

  @override
  String get localLlmPresetDescription => '端末内蔵のローカルモデル';

  @override
  String localLlmLoadSuccessMessage(Object modelName) {
    return '$modelName モデルを読み込みました。';
  }

  @override
  String localLlmLoadFailureMessage(Object error) {
    return 'モデルの読み込みに失敗しました: $error';
  }

  @override
  String get preferencesTitle => '環境設定';

  @override
  String get preferencesImageDisplayModeLabel => '画像の表示方法';

  @override
  String get preferencesImageDisplayModeDescription =>
      'イントロ/スナップショット画像をチャットでどう表示するか選びます。';

  @override
  String get preferencesImageDisplaySquareOption => '正方形(今のまま)';

  @override
  String get preferencesImageDisplayFullWidthOption => '横幅いっぱいに表示';

  @override
  String get preferencesAiSectionTitle => 'AI設定';

  @override
  String get preferencesThemeSectionTitle => 'テーマ';

  @override
  String get preferencesThemeDarkOption => 'ダーク';

  @override
  String get preferencesThemeLightOption => 'ホワイト';

  @override
  String get preferencesThemeAmoledOption => 'AMOLEDブラック';

  @override
  String get preferencesThemeSystemOption => 'システムに合わせる';

  @override
  String get paletteAddButton => 'プリセット追加';

  @override
  String get paletteDeleteConfirmTitle => 'プリセット削除';

  @override
  String paletteDeleteConfirmContent(String name) {
    return '\'$name\' プリセットを削除しますか？この操作は元に戻せません。';
  }

  @override
  String get paletteEditNewTitle => 'プリセット追加';

  @override
  String get paletteEditEditTitle => 'プリセット編集';

  @override
  String get paletteEditNameEmptyMessage => 'プリセット名を入力してください。';

  @override
  String get paletteEditPreviewLabel => 'プレビュー';

  @override
  String get paletteEditNameLabel => 'プリセット名';

  @override
  String get paletteEditColorsLabel => 'カラー';

  @override
  String get paletteEditBrightnessLabel => '明るさ';

  @override
  String get paletteEditBrightnessDark => 'ダーク';

  @override
  String get paletteEditBrightnessLight => 'ライト';

  @override
  String get paletteSlotBackground => '背景';

  @override
  String get paletteSlotSurface => 'カード/表面';

  @override
  String get paletteSlotSurfaceAlt => '補助表面(入力欄など)';

  @override
  String get paletteSlotBorder => '枠線';

  @override
  String get paletteSlotPrimary => 'アクセントカラー';

  @override
  String get paletteSlotOnPrimary => 'アクセント上のテキスト';

  @override
  String get paletteSlotTextPrimary => '本文テキスト';

  @override
  String get paletteSlotTextSecondary => '補助テキスト';

  @override
  String get paletteSlotTextMuted => '薄いテキスト';

  @override
  String get paletteSlotTextFaint => 'より薄いテキスト';

  @override
  String get paletteSlotTextGhost => '最も薄いテキスト';

  @override
  String get colorPickerTitle => '色を選択';

  @override
  String get colorPickerHexLabel => '16進コード';

  @override
  String get colorPickerAlphaLabel => '不透明度';

  @override
  String get colorPickerQuickPicksLabel => 'クイック選択';

  @override
  String get preferencesVersionSectionTitle => 'バージョン情報';

  @override
  String preferencesCurrentVersionLabel(String version) {
    return '現在のバージョン $version';
  }

  @override
  String get preferencesCheckUpdateButton => 'アップデート確認';

  @override
  String preferencesUpdateAvailableMessage(String version) {
    return '新しいバージョン$versionがあります。';
  }

  @override
  String get preferencesUpToDateMessage => '最新バージョンを使用しています。';

  @override
  String get preferencesUpdateCheckFailedMessage => 'アップデートの確認に失敗しました。';

  @override
  String get preferencesViewReleaseButton => 'リリースを見る';

  @override
  String get preferencesDangerZoneTitle => '危険な操作';

  @override
  String get preferencesResetAllDescription =>
      'プロット/キャラクター/会話/ロアブック/プリセット/画像など、この端末に保存されたすべてのデータを削除し、アプリを初回インストール時の状態に戻します。ダウンロード済みのローカルLLMモデルファイルは削除されません。この操作は元に戻せません。';

  @override
  String get preferencesResetAllButton => '全データを初期化';

  @override
  String get preferencesResetConfirmContent =>
      'すべてのデータが完全に削除されます。まだバックアップしていない場合は、続ける前にマイページで「全体保存」を行ってください。';

  @override
  String get preferencesResetConfirmWord => '初期化';

  @override
  String preferencesResetTypeToConfirm(Object word) {
    return '続けるには下に「$word」と入力してください。';
  }

  @override
  String get preferencesResetSuccessMessage => 'すべてのデータを初期化しました。';

  @override
  String preferencesResetFailureMessage(Object error) {
    return '初期化に失敗しました: $error';
  }

  @override
  String get navHome => 'ホーム';

  @override
  String get navChat => '会話';

  @override
  String get navCreate => '制作';

  @override
  String get navMyPage => 'マイページ';

  @override
  String get commonNoSearchResults => '検索結果がありません';

  @override
  String get searchHintPlot => 'プロットのタイトル・紹介・ハッシュタグ検索';

  @override
  String get searchHintLorebook => 'ロアブックのタイトル検索';

  @override
  String totalCountLabel(Object count) {
    return '全$count件';
  }

  @override
  String conversationCountLabel(Object count) {
    return '会話数 $count';
  }

  @override
  String get homeNoPlotsYet => 'まだ作成したプロットがありません';

  @override
  String get conversationTabTitle => '会話';

  @override
  String get conversationTabEmpty => '進行中の会話はまだありません';

  @override
  String conversationTabSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String get conversationTabDeleteConfirmTitle => '会話を削除';

  @override
  String get conversationTabDeleteConfirmContent => '選択した会話を削除しますか?元に戻せません。';

  @override
  String get conversationTilePlaceholder => '会話を始めてみましょう';

  @override
  String get createTabPlotLabel => 'プロット';

  @override
  String get createTabLorebookLabel => 'ロアブック';

  @override
  String get createTabNoLorebooksYet => 'まだ作成したロアブックがありません';

  @override
  String get createTabLorebookNote1 => '• 会話数は、このロアブックが接続されたプロットで発生した会話の合計です。';

  @override
  String get createTabLorebookNote2 =>
      '• ロアブックを編集・削除すると、接続されたすべてのプロットに即座に反映されます。変更前に必ずもう一度ご確認ください。';

  @override
  String lorebookTileStats(Object count, Object linked) {
    return '会話数 $count ・ 接続プロット $linked';
  }

  @override
  String get createTabImportButton => '読み込み';

  @override
  String get createTabImportSheetTitle => 'SillyTavernカードを読み込み';

  @override
  String get createTabImportFromFileTitle => 'ファイルから読み込み (PNG/JSON)';

  @override
  String get createTabImportFromFileSubtitle =>
      'SillyTavernキャラクターカードファイルを選択します';

  @override
  String get createTabImportFromUrlTitle => 'リンク(URL)から取り込み';

  @override
  String get createTabImportFromUrlSubtitle => 'カードファイルのリンクやサイトURLを貼り付けます';

  @override
  String get createTabImportFromPlotDataTitle => '専用形式(.mzplot)から取り込み';

  @override
  String get createTabImportFromPlotDataSubtitle =>
      '画像を含むプロット全体のデータを読み込みます(会話履歴は除く)';

  @override
  String get createTabImportUrlDialogTitle => 'リンクから取り込み';

  @override
  String get createTabImportConfirmButton => '取り込み';

  @override
  String get createTabNoIntroWarning =>
      'このカードにはオープニングメッセージがないため、イントロタブは空のままにしました。「イントロ」タブでご自身で作成してください。';

  @override
  String createTabImportFailureMessage(Object error) {
    return '読み込みに失敗しました: $error';
  }

  @override
  String get createTabCreateButton => '作成する';

  @override
  String get createTabEditPlotMenuItem => 'プロットを編集';

  @override
  String get createTabDeleteLorebookConfirmTitle => 'ロアブックを削除しますか?';

  @override
  String get createTabDeleteLorebookConfirmContent =>
      '接続されたすべてのプロットに即座に反映されます。';

  @override
  String get createTabDeletePlotConfirmTitle => 'プロットを削除しますか?';

  @override
  String get createTabDeletePlotConfirmContent => '削除したプロットと関連する会話は元に戻せません。';

  @override
  String get chatDefaultUserName => 'ユーザー';

  @override
  String get chatDefaultCharacterName => 'キャラクター';

  @override
  String get chatSelectPresetFirstMessage => '先にAIプリセットを選択してください';

  @override
  String get chatReasoningInProgressLabel => '考え中...';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'AI応答の生成に失敗しました: $error';
  }

  @override
  String get chatGeneratingIndicator => '返信を生成中...';

  @override
  String get chatReviseDialogTitle => 'AI修正';

  @override
  String get chatReviseDialogHint => 'どう直したいか教えてください(例: もっと短く)';

  @override
  String get chatReviseConfirmButton => '修正する';

  @override
  String get chatDrawerStartFreshTitle => '最初からやり直す';

  @override
  String get chatDrawerStartFreshSubtitle => '現在の内容を保存してから最初からやり直せます';

  @override
  String get chatDrawerResumeTitle => '続きから';

  @override
  String get chatDrawerDeleteTitle => '会話を削除';

  @override
  String get chatDrawerProfileTitle => '会話プロフィール';

  @override
  String get chatDrawerChoicesTitle => '選択肢';

  @override
  String get chatDrawerChoicesDisabled => '使用しない';

  @override
  String get chatDrawerMemoryTitle => '記憶を見る';

  @override
  String get chatMemorySheetTitle => 'これまでの会話の要約';

  @override
  String get chatMemoryEmptyMessage => 'まだ要約された記憶がありません。会話が長くなると自動的に作られます。';

  @override
  String get chatDrawerExitButton => '会話ルームを退出';

  @override
  String get chatDisclaimerBanner => '回答はすべてAIが生成した内容です';

  @override
  String get chatInputHint => '内容を入力';

  @override
  String get chatModelSheetTitle => 'AIモデルを選択';

  @override
  String get chatModelSheetDescription =>
      '選択したプリセットの設定で会話が進みます。プリセットはマイページで管理できます。';

  @override
  String get chatModelSheetPresetSettingsLink => 'プリセット設定';

  @override
  String get chatModelSheetNoPresets => 'まだ作成したプリセットがありません';

  @override
  String get chatPresetSelectDefault => 'プリセットを選択';

  @override
  String get chatSheetStartFreshFromHere => 'ここから最初からやり直す';

  @override
  String get chatProfileSheetTitle => '自分の会話プロフィール';

  @override
  String get chatProfileSheetAddButton => '会話プロフィールを追加';

  @override
  String get chatSuggestSheetTitle => '次の会話の提案';

  @override
  String get chatSuggestUseHint => 'タップすると入力欄に入り、矢印を押すとすぐ送信します。';

  @override
  String chatSuggestFailureMessage(Object error) {
    return '次の会話の提案生成に失敗しました: $error';
  }

  @override
  String get chatSuggestEmptyMessage => '提案できる内容が見つかりませんでした。';

  @override
  String chatSnapshotFailureMessage(Object error) {
    return 'スナップショットの生成に失敗しました: $error';
  }

  @override
  String get chatSnapshotNotConfiguredMessage =>
      'マイページ > スナップショット設定で画像生成APIキーを先に登録してください。';

  @override
  String get characterDetailExportMenuItem => 'エクスポート';

  @override
  String get characterDetailContinueChatButton => '会話する';

  @override
  String get characterDetailCharacterSectionTitle => 'キャラクター';

  @override
  String get characterDetailIntroSectionTitle => 'イントロ';

  @override
  String get characterDetailIntroNarratorLabel => 'ナレーション';

  @override
  String get characterDetailIntroUserLabel => '私';

  @override
  String get characterDetailIntroImageLabel => '画像';

  @override
  String get plotEditTabPrompt => 'プロンプト';

  @override
  String get plotEditTabLorebook => 'ロアブック';

  @override
  String get plotEditTabAbout => '紹介';

  @override
  String plotEditDefaultCharacterName(Object index) {
    return 'キャラクター$index';
  }

  @override
  String get plotEditAppBarTitle => 'プロット';

  @override
  String get plotEditExportCardMenuItem => 'SillyTavernカードとしてエクスポート';

  @override
  String get plotEditExportDataMenuItem => '専用形式でエクスポート(全データ)';

  @override
  String get plotEditSaveButtonEdit => '更新';

  @override
  String get plotEditSaveButtonCreate => '作成';

  @override
  String get plotEditExportSuccessMessage => 'SillyTavernカードとしてエクスポートしました。';

  @override
  String get plotEditExportDataSuccessMessage => '専用形式(.mzplot)でエクスポートしました。';

  @override
  String plotEditExportFailureMessage(Object error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String plotEditCharCountLabel(Object count) {
    return '$count文字';
  }

  @override
  String get plotEditBasicSettingsTitle => '基本設定';

  @override
  String get plotEditTitleFieldLabel => 'タイトル';

  @override
  String get plotEditDescriptionFieldLabel => '説明';

  @override
  String get plotEditAddCharacterButton => 'キャラクター追加';

  @override
  String get plotEditRepresentativeBadge => '代表';

  @override
  String get plotEditCharacterImagePlaceholder => 'キャラクター画像';

  @override
  String get plotEditNameFieldLabel => '名前';

  @override
  String get plotEditLorebookSavePlotFirst =>
      'プロットを先に保存するとロアブックを接続できます。\nプロンプトタブでタイトル・キャラクターを入力し、上部の保存ボタンを押してください。';

  @override
  String get plotEditLorebookConnectTitle => 'ロアブックを接続してください';

  @override
  String get plotEditLorebookConnectDescription =>
      'ロアブックに登録したキーワードが言及されるたびに\n作成した内容がAIに伝わります';

  @override
  String plotEditLorebookConnectButton(Object linked) {
    return 'ロアブック接続 ($linked件)';
  }

  @override
  String get plotEditIntroHintNarrator => '*状況を説明してください*';

  @override
  String get plotEditIntroHintUser => 'ユーザーメッセージを入力してください';

  @override
  String plotEditIntroHintCharacter(Object name) {
    return '$nameのセリフを入力してください';
  }

  @override
  String get plotEditEditContentDialogTitle => '内容を編集';

  @override
  String get plotEditIntroSavePlotFirst =>
      'プロットを先に保存するとイントロを作成できます。\nプロンプトタブでタイトル・キャラクターを入力し、上部の保存ボタンを押してください。';

  @override
  String get plotEditIntroAiGenerateButton => 'AIで生成';

  @override
  String get plotEditIntroFirstSceneTitle => '最初の状況を作成してください';

  @override
  String get plotEditIntroEmptyMessage =>
      'まだ作成されたイントロがありません。下の入力欄から最初の行を追加してみましょう。';

  @override
  String get plotEditProfileMarkerLabel => '会話プロフィール選択タイミング';

  @override
  String get plotProfileSectionTitle => 'プレイするユーザーが使う会話プロフィールを作成してください';

  @override
  String get plotProfileSectionDescription =>
      'このプロットだけで使う専用プロフィールです。個数の制限はありません。';

  @override
  String get plotProfileSavePlotFirst =>
      'プロットを先に保存すると会話プロフィールを作成できます。\nプロンプトタブでタイトル/キャラクターを入力し、上部の保存ボタンを押してください。';

  @override
  String get plotProfileAddButton => '会話プロフィールを追加';

  @override
  String get plotProfileUseGlobalNameLabel => 'プレイするユーザーの名前を使う';

  @override
  String plotProfileUseGlobalNameDescription(String name) {
    return 'チェックするとマイページの既定プロフィール名($name)がそのまま使われます';
  }

  @override
  String get plotProfileShortIntroLabel => '短い紹介';

  @override
  String get plotProfileShortIntroDescription => 'カードに表示される一行紹介です。AIには伝わりません。';

  @override
  String get plotProfileDescriptionLabel => '説明';

  @override
  String get plotProfileDescriptionHint =>
      'キャラクターを作るときのように具体的な説明を書くといいです。\n例) 18歳、身長181cm、格好良い顔と首位を逃さない成績で皆に人気のある模範生';

  @override
  String get plotProfilePickerTitle => 'プロフィールを選択してください';

  @override
  String get plotProfilePickerSwipeHint => '横にスワイプして他のプロフィールを見る';

  @override
  String get plotProfilePickerSelectButton => '選択';

  @override
  String get plotProfilePickerListTitle => 'プロフィールを選択してください';

  @override
  String get plotEditAddImageTooltip => '画像を追加(AIには伝わりません)';

  @override
  String get plotEditComposerNarrator => 'ナレーター';

  @override
  String get plotEditAddHashtagDialogTitle => 'ハッシュタグ追加';

  @override
  String get plotEditHashtagHint => '#なしで入力してください';

  @override
  String get plotEditCoverTitle => 'カバー';

  @override
  String get plotEditCoverImagePlaceholder => 'カバー画像';

  @override
  String get plotEditShortIntroLabel => '短い紹介';

  @override
  String get plotEditShortIntroHint => 'タイトルと一緒に表示される短い紹介を入力してください';

  @override
  String get plotEditHashtagsLabel => 'ハッシュタグ';

  @override
  String plotEditHashtagAddButton(Object count) {
    return '追加 $count/10';
  }

  @override
  String get plotEditAboutSectionTitle => '紹介文';

  @override
  String get plotEditAboutSectionDescription =>
      '詳細ページに表示する内容や画像を追加してください。\nこの内容はAIには伝わりません。';

  @override
  String get plotEditAboutFieldHint =>
      '詳細ページに表示する内容を書いてください。\nこの内容はAIには伝わりません。';

  @override
  String get aiPresetScreenDescription => '会話で使うAIプリセットを作成・管理しましょう。';

  @override
  String get aiPresetScreenAddButton => 'プリセット追加';

  @override
  String get aiPresetEditTitleEdit => 'プリセットを編集';

  @override
  String get aiPresetEditTitleCreate => 'プリセットを追加';

  @override
  String get aiPresetNameHint => '例: 基本スタイル';

  @override
  String get aiPresetDescHint => 'このプリセットを一言で紹介してください';

  @override
  String get aiPresetBaseUrlHint => '例: https://api.openai.com/v1';

  @override
  String get aiPresetModelNameLabel => 'モデル名';

  @override
  String get aiPresetModelNameHint => '例: gpt-4o-mini, claude-sonnet-5';

  @override
  String get aiPresetApiKeyLabel => 'APIキー';

  @override
  String get aiPresetApiKeyStorageNote => '端末内にのみ安全に保存されます';

  @override
  String get aiPresetApiKeyHint => '取得したAPIキーを入力してください';

  @override
  String get aiPresetApiKeyGuideButton => 'キー発行案内';

  @override
  String get apiKeyGuideDialogTitle => 'APIキー発行案内';

  @override
  String get apiKeyGuideOpenButton => '開く';

  @override
  String get apiKeyGuideOpenRouterDescription =>
      '1つのAPIキーで様々なモデルを使えるルーターサービスです。';

  @override
  String get apiKeyGuideFeatherlessDescription =>
      'オープンソースモデルを定額でほぼ無制限に使えるサービスです。';

  @override
  String get apiKeyGuideFeatherlessReferralNote => 'このリンクから登録すると初月10ドル割引になります。';

  @override
  String get apiKeyGuideAtlasCloudDescription => '複数のモデルを従量課金で使えるサービスです。';

  @override
  String get apiKeyGuideAtlasCloudReferralNote => 'このリンクから登録すると5ドル追加チャージされます。';

  @override
  String get aiPresetAdvancedSettingsTitle => '詳細設定';

  @override
  String get aiPresetAdvancedSettingsDescription =>
      'すべて任意です。空欄の場合はリクエストに含まれません。';

  @override
  String get aiPresetTemperatureHint => '例: 1.0';

  @override
  String get aiPresetTopKHint => '例: 40';

  @override
  String get aiPresetMaxTokensHint => '例: 1024';

  @override
  String get aiPresetContextLengthHint => '直近何件のメッセージまで含めるか';

  @override
  String get aiPresetAdditionalPromptLabel => '追加システムプロンプト';

  @override
  String get aiPresetAdditionalPromptHint => '基本プロンプトの後に追加する指示(任意)';

  @override
  String get aiPresetSaveButton => '保存する';

  @override
  String get aiPresetReasoningEffortLabel => '推論の深さ(Reasoning effort)';

  @override
  String get aiPresetReasoningEffortDescription =>
      '推論モデルが答える前にどれくらい深く考えるかを指定します。ローカルモデルは思考モードがオンになり、リモートモデルは対応している場合のみ適用されます。';

  @override
  String get aiPresetReasoningEffortOff => 'オフ';

  @override
  String get aiPresetReasoningEffortLow => '低い';

  @override
  String get aiPresetReasoningEffortMedium => '普通';

  @override
  String get aiPresetReasoningEffortHigh => '高い';

  @override
  String get aiPresetEndpointFormatLabel => 'エンドポイント形式';

  @override
  String get aiPresetEndpointFormatDescription =>
      '選択した形式に合わせたリクエスト/レスポンス処理で通信します。';

  @override
  String get aiPresetEndpointFormatOpenAi => 'OpenAI互換';

  @override
  String get aiPresetEndpointFormatAnthropic => 'Anthropic';

  @override
  String get aiPresetSupportsVisionLabel => '画像認識(ビジョン)対応';

  @override
  String get aiPresetSupportsVisionDescription =>
      'オンにすると、ZedTalkで添付した画像をこのプリセットのモデルに一緒に送ります。実際に画像を理解できるモデルの場合のみオンにしてください。';

  @override
  String get aiPresetOpenRouterSectionTitle => 'OpenRouter専用オプション';

  @override
  String get aiPresetOpenRouterSectionDescription =>
      'Base URLがopenrouter.aiの場合のみ適用されます。';

  @override
  String get aiPresetOpenRouterZdrOnlyLabel => 'ZDR提供者のみ使用';

  @override
  String get aiPresetOpenRouterZdrOnlyDescription =>
      'データを保持しない(Zero Data Retention)提供者にのみルーティングします。';

  @override
  String get aiPresetOpenRouterExcludeChinaLabel => '中国の提供者を除外';

  @override
  String get aiPresetOpenRouterExcludeChinaDescription =>
      'アリババなど中国拠点の提供者をルーティングから除外します。';

  @override
  String get aiPresetOpenRouterExcludeTrainingLabel => '学習利用提供者を除外';

  @override
  String get aiPresetOpenRouterExcludeTrainingDescription =>
      'リクエストデータを学習に利用する可能性がある提供者を除外します。';

  @override
  String get lorebookConnectTitle => 'ロアブック接続';

  @override
  String get lorebookConnectNoneButton => '接続しない';

  @override
  String lorebookConnectConfirmButton(Object count) {
    return '接続する ($count件)';
  }

  @override
  String get lorebookDetailDeletedMessage => '削除されたロアブックです';

  @override
  String get lorebookInfoTabLabel => 'ロア情報';

  @override
  String get lorebookLinkedPlotsTabLabel => '接続プロット';

  @override
  String get lorebookPlotConnectTabLabel => 'プロット接続';

  @override
  String get lorebookDetailEditMenuItem => 'ロアブックを編集';

  @override
  String get lorebookDetailNoEntriesMessage => '作成された項目がありません';

  @override
  String get lorebookDetailNoLinkedPlotsMessage => '接続されたプロットがありません';

  @override
  String get lorebookEditAppBarTitle => 'ロアブック';

  @override
  String get lorebookEditSaveButtonCreate => '登録';

  @override
  String get lorebookEditSaveFirstMessage => 'ロアブックを先に登録するとプロットを接続できます。';

  @override
  String get lorebookEditIntroDescription =>
      '紹介文はAIには伝わりません。\nロアブックを管理する用途にご活用ください。';

  @override
  String get lorebookEditTitleFieldLabel => 'ロアブックタイトル';

  @override
  String get lorebookEditEntriesSectionTitle => '項目';

  @override
  String get lorebookEditAddEntryButton => '項目追加';

  @override
  String lorebookEditEntryCardTitle(Object index) {
    return '項目 $index';
  }

  @override
  String get lorebookEditEntryTitleHint => 'タイトルを入力してください';

  @override
  String get lorebookEditKeywordsLabel => 'キーワード';

  @override
  String get lorebookEditKeywordsHint =>
      'キーワードをカンマ(,)で区切って入力してください。\n入力したキーワードが言及されると、下に書いた内容がAIに伝わります。';

  @override
  String get lorebookEditContentLabel => '内容';

  @override
  String get lorebookEditContentHint => 'キーワード言及時にAIへ伝える内容を入力してください。';

  @override
  String get lorebookEditConnectPlotsTitle => 'プロットを接続してください';

  @override
  String get lorebookEditConnectPlotsDescription =>
      'プロットを接続すると、キーワードが言及されるたびに\nロアブックの世界観がAIに伝わります';

  @override
  String lorebookConnectButtonWithCount(Object count) {
    return '接続する ($count)';
  }

  @override
  String get profileEditNameDescription => 'キャラクターがこう呼んでくれます';

  @override
  String get profileEditDescriptionLabel => '説明(任意)';

  @override
  String get profileEditDefaultSectionTitle => 'デフォルト会話プロフィール';

  @override
  String get profileEditApplyDefaultTitle => '新しい会話開始時にこのプロフィールを適用';

  @override
  String get profileEditApplyDefaultDescription => '会話中に別のプロフィールに切り替えられます';

  @override
  String get resumeNoSavedConversations => '保存された会話がありません';

  @override
  String get resumeJustNow => 'たった今';

  @override
  String resumeMinutesAgo(Object count) {
    return '$count分前';
  }

  @override
  String resumeHoursAgo(Object count) {
    return '$count時間前';
  }

  @override
  String resumeDaysAgo(Object count) {
    return '$count日前';
  }

  @override
  String resumeSavedAtLabel(Object date) {
    return '$dateに保存された会話';
  }

  @override
  String get resumeNoSavedMessage => '保存されたメッセージがありません';

  @override
  String get tokenUsageTitle => 'トークン使用履歴';

  @override
  String get tokenUsageDeleteAllButton => '全削除';

  @override
  String get tokenUsageDeleteAllConfirmTitle => '履歴をすべて削除しますか?';

  @override
  String get tokenUsageDeleteAllConfirmContent => '削除すると元に戻せません。';

  @override
  String get tokenUsageEmptyMessage => 'まだ使用履歴がありません';

  @override
  String tokenUsageProviderLabel(Object provider, Object presetName) {
    return '提供元: $provider ・ $presetName';
  }

  @override
  String tokenUsageBreakdown(Object prompt, Object completion, Object total) {
    return '入力 $prompt ・ 出力 $completion ・ 合計 $total';
  }

  @override
  String get startFreshDialogTitle => '会話を最初からやり直しますか?';

  @override
  String get startFreshDialogDescription => '保存した会話は「続きから」で\nいつでもまた再開できます';

  @override
  String get startFreshDialogSaveCheckbox => '現在の会話を保存する';

  @override
  String get startFreshFromHereDialogTitle => 'ここから最初からやり直しますか?';

  @override
  String get startFreshFromHereDialogDescription =>
      '既存の会話は「続きから」で\nいつでもまた再開できます';

  @override
  String get systemPromptButtonLabel => 'システムプロンプト設定';

  @override
  String get systemPromptWarning =>
      '本当に必要な場合のみ修正してください。誤って修正するとAIの応答がおかしくなることがあります。';

  @override
  String get systemPromptPlaceholderHintTitle => '使用できるプレースホルダー';

  @override
  String get systemPromptPlaceholderHintBody =>
      '次の名前を二重中括弧で囲むと実際の値に自動的に置き換わります: plot_title, plot_description, characters_block, example_character_name, user_profile_name, lore_block, extra_block\nただしuserはAIが応答にそのまま残す必要があるトークンなので削除しないでください。';

  @override
  String get systemPromptResetButton => 'デフォルトに戻す';

  @override
  String get systemPromptResetConfirmTitle => 'デフォルトに戻しますか?';

  @override
  String get systemPromptResetConfirmContent =>
      '現在の修正内容は消え、デフォルトのシステムプロンプトに戻ります。';

  @override
  String get systemPromptSavedMessage => '保存しました。';

  @override
  String get systemPromptResetDoneMessage => 'デフォルトに戻しました。';

  @override
  String get snapshotSettingsTitle => 'スナップショット設定';

  @override
  String get snapshotSettingsDescription =>
      'チャットでスナップショットを押すと、今の状況をAIが要約して、下で設定したエンドポイントで画像を生成します。';

  @override
  String get snapshotSettingsProviderLabel => '画像生成エンドポイント';

  @override
  String get snapshotSettingsApiKeyLabel => 'APIキー';

  @override
  String get snapshotSettingsApiKeyHint => '選択したエンドポイントのAPIキーを入力してください';

  @override
  String get snapshotSettingsModelNameLabel => '画像モデル名';

  @override
  String get snapshotSettingsModelNameHint =>
      '例: google/gemini-2.5-flash-image';

  @override
  String get snapshotSettingsSaveButton => '保存する';

  @override
  String get snapshotSettingsSavedMessage => '保存しました。';

  @override
  String get createTabAiGenerateButton => 'AIで生成';

  @override
  String get plotAiGenerateTitle => 'AIでプロット生成';

  @override
  String get plotAiGeneratePresetLabel => '使用するAIプリセット';

  @override
  String get plotAiGeneratePresetEmptyHint => '先に環境設定 > AI設定でAIプリセットを作成してください。';

  @override
  String get plotAiGeneratePromptLabel => 'どんなプロットを作りますか?';

  @override
  String get plotAiGeneratePromptHint => 'ジャンル、背景、登場人物の特徴などを自由に説明してください';

  @override
  String get plotAiGenerateWebSearchLabel => 'Web検索で参考資料を探す';

  @override
  String get plotAiGenerateWebSearchUnsupportedHint =>
      '選択したプリセットはネイティブWeb検索に対応していません(OpenRouterまたはOpenAI系のみ対応)。';

  @override
  String get plotAiGenerateLoreLengthLabel => 'ロアの長さ';

  @override
  String get plotAiGenerateLoreLengthShort => '短め';

  @override
  String get plotAiGenerateLoreLengthMedium => '普通';

  @override
  String get plotAiGenerateLoreLengthLong => '長め';

  @override
  String get plotAiGenerateAccuracyLabel => '正確さ';

  @override
  String get plotAiGenerateAccuracyAccurate => '正確(Accurate)';

  @override
  String get plotAiGenerateAccuracyMixed => 'ミックス(Mixed)';

  @override
  String get plotAiGenerateSubmitButton => '生成する';

  @override
  String get plotAiGeneratePromptEmptyMessage => 'まずどんなプロットを作りたいか説明してください。';

  @override
  String plotAiGenerateFailureMessage(Object error) {
    return 'プロットの生成に失敗しました: $error';
  }

  @override
  String get plotAiGenerateGeneratingMessage => 'AIがプロットを生成しています...';

  @override
  String get lanSyncSectionTitle => 'LAN同期';

  @override
  String get lanSyncScreenTitle => 'LAN同期';

  @override
  String get lanSyncExportSectionTitle => 'この端末からエクスポート';

  @override
  String get lanSyncExportSectionDescription =>
      '同じWi-Fi/LANに接続した別の端末から下記情報で接続すると、全データを取得できます。';

  @override
  String get lanSyncStartHostButton => '接続待機を開始';

  @override
  String get lanSyncStopHostButton => '中止';

  @override
  String get lanSyncWaitingMessage => '他の端末からの接続を待っています...';

  @override
  String get lanSyncAddressLabel => 'アドレス';

  @override
  String get lanSyncPortLabel => 'ポート';

  @override
  String get lanSyncPinLabel => 'PIN';

  @override
  String get lanSyncExportedMessage => '転送が完了しました。';

  @override
  String lanSyncExportFailedMessage(Object error) {
    return '転送に失敗しました: $error';
  }

  @override
  String get lanSyncNoAddressWarning =>
      'この端末でLANアドレスが見つかりませんでした。Wi-Fi接続を確認してください。';

  @override
  String get lanSyncImportSectionTitle => '他の端末から取り込む';

  @override
  String get lanSyncImportSectionDescription =>
      'エクスポート側の画面に表示されたアドレス/ポート/PINを入力してください。';

  @override
  String get lanSyncHostFieldLabel => 'アドレス(IP)';

  @override
  String get lanSyncPortFieldLabel => 'ポート';

  @override
  String get lanSyncPinFieldLabel => 'PIN';

  @override
  String get lanSyncImportButton => '取り込む';

  @override
  String get lanSyncImportConfirmTitle => '全データを置き換え';

  @override
  String get lanSyncImportConfirmContent => '受信したデータでこの端末の全データを上書きします。元に戻せません。';

  @override
  String lanSyncImportFailedMessage(Object error) {
    return '取り込みに失敗しました: $error';
  }

  @override
  String createTabSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String get createTabDeleteSelectedConfirmTitle => 'プロットを削除';

  @override
  String get createTabDeleteSelectedConfirmContent =>
      '選択したプロットを削除しますか?元に戻せません。';

  @override
  String get createTabExportPackageButton => 'パッケージとしてエクスポート(.mzpack)';

  @override
  String createTabExportPackageSuccessMessage(int count) {
    return '$count件のプロットをエクスポートしました。';
  }

  @override
  String createTabExportPackageFailureMessage(Object error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get createTabImportFromPackageTitle => 'プロットパッケージから読み込む(.mzpack)';

  @override
  String get createTabImportFromPackageSubtitle => '複数のプロットを一度に読み込みます';

  @override
  String createTabImportPackageSuccessMessage(int count) {
    return '$count件のプロットを読み込みました。';
  }

  @override
  String get conversationTabTalkLabel => 'トーク';

  @override
  String get characterDetailTalkButton => 'ZedTalk';

  @override
  String get talkListEmpty => 'まだトークしたキャラクターがいません';

  @override
  String get talkAttachmentSheetTitle => '添付';

  @override
  String get talkAttachmentImageOption => '画像';

  @override
  String get talkAttachmentVideoOption => '動画';

  @override
  String get talkAttachmentDocumentOption => 'ドキュメント';

  @override
  String get talkVisionUnsupportedNote =>
      'このプリセットは画像認識に対応していないため、添付した画像はAIに送信されません。';

  @override
  String get talkPresetSheetTitle => '使用するAIプリセット';

  @override
  String get talkNoPresetMessage => 'まずAIプリセットを選んでください。';

  @override
  String get talkDeleteConfirmTitle => 'トークを削除';

  @override
  String get talkDeleteConfirmContent => '選択したトークを削除しますか?元に戻せません。';

  @override
  String get talkCharacterPickerTitle => '会話するキャラクターを選んでください';

  @override
  String get talkDrawerStartFreshTitle => '最初から始める';

  @override
  String get talkDrawerStartFreshSubtitle => '新しいトークルームを作ります';

  @override
  String get talkDrawerResumeTitle => '他のトークルーム';

  @override
  String get talkDrawerDeleteTitle => 'トークルームを削除';

  @override
  String get talkDrawerProfileTitle => '会話プロフィール';

  @override
  String get talkDrawerChoicesTitle => '選択肢';

  @override
  String get talkDrawerExitButton => 'トークルームを退出';

  @override
  String get talkResumeSheetTitle => '他のトークルーム';

  @override
  String get talkResumeSheetEmpty => 'このプロットの他のトークルームはありません';

  @override
  String get talkSheetStartFreshFromHere => 'ここから最初から始める';

  @override
  String get talkEditMessageTitle => 'メッセージを編集';

  @override
  String get lorebookImportButtonTooltip =>
      'インポート(SillyTavern World Info / JanitorAI)';

  @override
  String get lorebookExportButtonTooltip => 'SillyTavern World Infoでエクスポート';

  @override
  String lorebookImportSuccessMessage(Object count) {
    return '$count件の項目を読み込みました。保存を押すと反映されます。';
  }

  @override
  String lorebookImportFailureMessage(Object error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get lorebookExportSuccessMessage => 'World Info JSONでエクスポートしました。';

  @override
  String lorebookExportFailureMessage(Object error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get createTabImportTargetSheetTitle => 'インポート先を選んでください';

  @override
  String get createTabImportTargetNewPlot => '新しいプロットとして作成';

  @override
  String get createTabImportLorebookTargetSheetTitle => 'ロアブックをどう追加しますか?';

  @override
  String get createTabImportLorebookTargetNew => '新しいロアブックを作成';

  @override
  String get myPageSummarySettingsButton => '要約(長期記憶)設定';

  @override
  String get summarySettingsTitle => '要約(長期記憶)設定';

  @override
  String get summarySettingsDescription =>
      'AIプリセットにコンテキスト長(最近のメッセージ数の上限)が設定されていると、その範囲を超えた古い会話を自動で要約してシステムプロンプトに含めます。ここでこの機能をオフにしたり、要約プロンプトや使用するプリセットを指定できます。';

  @override
  String get summarySettingsEnabledLabel => '長期記憶の要約を使う';

  @override
  String get summarySettingsPromptLabel => '要約プロンプト';

  @override
  String get summarySettingsPromptHint => '空欄なら既定のプロンプトを使います';

  @override
  String get summarySettingsPresetLabel => '要約に使うプリセット';

  @override
  String get summarySettingsPresetDefaultOption => 'チャットと同じプリセットを使う';

  @override
  String get summarySettingsSaveButton => '保存';

  @override
  String get summarySettingsSavedMessage => '保存しました。';
}
