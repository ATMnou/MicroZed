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
  String get myPageSourceLinkComingSoon => 'ソースリンク(準備中)';

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
  String get conversationTabSortLatest => '新着順';

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
  String get chatDefaultUserName => 'ユーザー';

  @override
  String get chatDefaultCharacterName => 'キャラクター';

  @override
  String get chatSelectPresetFirstMessage => '先にAIプリセットを選択してください';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'AI応答の生成に失敗しました: $error';
  }

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
  String get characterDetailExportMenuItem => 'エクスポート';

  @override
  String get characterDetailContinueChatButton => '続きを話す';

  @override
  String get characterDetailCharacterSectionTitle => 'キャラクター';

  @override
  String get characterDetailIntroSectionTitle => 'イントロ';

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
  String get plotEditDraftSaveButton => '下書き保存';

  @override
  String get plotEditSaveButtonEdit => '更新';

  @override
  String get plotEditSaveButtonCreate => '作成';

  @override
  String get plotEditExportSuccessMessage => 'SillyTavernカードとしてエクスポートしました。';

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
  String plotEditLorebookConnectButton(Object linked, Object max) {
    return 'ロアブック接続 ($linked/$max)';
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
  String get plotEditIntroFirstSceneTitle => '最初の状況を作成してください';

  @override
  String get plotEditIntroEmptyMessage =>
      'まだ作成されたイントロがありません。下の入力欄から最初の行を追加してみましょう。';

  @override
  String get plotEditProfileMarkerLabel => '会話プロフィール選択タイミング';

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
  String get plotEditPreviewButton => 'プレビュー';

  @override
  String get plotEditCoverImagePlaceholder => 'カバー画像';

  @override
  String get plotEditShortIntroLabel => '短い紹介';

  @override
  String get plotEditShortIntroHint => 'タイトルと一緒に表示される短い紹介を入力してください';

  @override
  String get plotEditHashtagsLabel => 'ハッシュタグ';

  @override
  String get plotEditHashtagsDescription => 'ハッシュタグがあると露出が10倍増えます';

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
  String get lorebookConnectTitle => 'ロアブック接続';

  @override
  String lorebookConnectNoneButton(Object max) {
    return '接続しない (0/$max)';
  }

  @override
  String lorebookConnectConfirmButton(Object count, Object max) {
    return '接続する ($count/$max)';
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
}
