// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Microzed';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCopy => 'Copy';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDialogTitle => 'Choose language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get myPageTitle => 'My Page';

  @override
  String get myPageEditProfileButton => 'Edit chat profile';

  @override
  String get myPageAiPresetButton => 'AI preset settings';

  @override
  String get myPageTokensUsedLabel => 'Tokens used';

  @override
  String get myPageHistoryButton => 'History';

  @override
  String get myPageBackupSectionTitle => 'Data backup';

  @override
  String get myPageBackupSectionDescription =>
      'Save or restore all your data — plots, characters, chats, lorebooks, presets — as a single file.';

  @override
  String get myPageExportAllButton => 'Export all';

  @override
  String get myPageImportAllButton => 'Import all';

  @override
  String get myPageExportSuccessMessage => 'All data saved.';

  @override
  String myPageExportFailureMessage(Object error) {
    return 'Failed to save: $error';
  }

  @override
  String get myPageImportDialogTitle => 'Import all';

  @override
  String get myPageImportDialogContent =>
      'All plots/characters/chats/lorebooks/presets currently in the app will be completely replaced by this backup.\nThis cannot be undone. Continue?';

  @override
  String get myPageImportRestoreButton => 'Restore';

  @override
  String myPageImportSuccessMessage(
    Object plotCount,
    Object chatMessageCount,
    Object lorebookCount,
  ) {
    return 'Restore complete: $plotCount plots, $chatMessageCount chat messages, $lorebookCount lorebooks';
  }

  @override
  String myPageImportFailureMessage(Object error) {
    return 'Failed to import: $error';
  }

  @override
  String get myPageLicensesButton => 'Open-source licenses';

  @override
  String get myPageSourceCodeButton => 'GitHub repository';

  @override
  String get myPageSnapshotSettingsButton => 'Snapshot settings';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get preferencesImageDisplayModeLabel => 'Image display';

  @override
  String get preferencesImageDisplayModeDescription =>
      'Choose how intro/snapshot images are shown in chat.';

  @override
  String get preferencesImageDisplaySquareOption => 'Square (current)';

  @override
  String get preferencesImageDisplayFullWidthOption => 'Fill width';

  @override
  String get navHome => 'Home';

  @override
  String get navChat => 'Chat';

  @override
  String get navCreate => 'Create';

  @override
  String get navMyPage => 'My Page';

  @override
  String get commonNoSearchResults => 'No search results';

  @override
  String get searchHintPlot => 'Search by title, description, hashtags';

  @override
  String get searchHintLorebook => 'Search lorebook titles';

  @override
  String totalCountLabel(Object count) {
    return '$count total';
  }

  @override
  String conversationCountLabel(Object count) {
    return '$count chats';
  }

  @override
  String get homeNoPlotsYet => 'You haven\'t created any plots yet';

  @override
  String get conversationTabTitle => 'Chats';

  @override
  String get conversationTabEmpty => 'No conversations yet';

  @override
  String get conversationTabSortLatest => 'Latest';

  @override
  String get conversationTilePlaceholder => 'Start a conversation';

  @override
  String get createTabPlotLabel => 'Plots';

  @override
  String get createTabLorebookLabel => 'Lorebooks';

  @override
  String get createTabNoLorebooksYet =>
      'You haven\'t created any lorebooks yet';

  @override
  String get createTabLorebookNote1 =>
      '• Chat count is the total of all conversations across plots linked to this lorebook.';

  @override
  String get createTabLorebookNote2 =>
      '• Editing or deleting a lorebook applies instantly to every linked plot. Please double-check before making changes.';

  @override
  String lorebookTileStats(Object count, Object linked) {
    return '$count chats · $linked linked plots';
  }

  @override
  String get createTabImportButton => 'Import';

  @override
  String get createTabImportSheetTitle => 'Import a SillyTavern card';

  @override
  String get createTabImportFromFileTitle => 'Import from file (PNG/JSON)';

  @override
  String get createTabImportFromFileSubtitle =>
      'Choose a SillyTavern character card file';

  @override
  String get createTabImportFromUrlTitle => 'Import from a link (URL)';

  @override
  String get createTabImportFromUrlSubtitle =>
      'Paste a card file link or site URL';

  @override
  String get createTabImportUrlDialogTitle => 'Import from a link';

  @override
  String get createTabImportConfirmButton => 'Import';

  @override
  String get createTabNoIntroWarning =>
      'This card has no opening message, so the intro tab was left blank. Please write one yourself in the \"Intro\" tab.';

  @override
  String createTabImportFailureMessage(Object error) {
    return 'Failed to import: $error';
  }

  @override
  String get createTabCreateButton => 'Create';

  @override
  String get createTabEditPlotMenuItem => 'Edit plot';

  @override
  String get createTabDeleteLorebookConfirmTitle => 'Delete this lorebook?';

  @override
  String get createTabDeleteLorebookConfirmContent =>
      'This will apply instantly to every linked plot.';

  @override
  String get chatDefaultUserName => 'User';

  @override
  String get chatDefaultCharacterName => 'Character';

  @override
  String get chatSelectPresetFirstMessage => 'Please choose an AI preset first';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'Failed to generate AI reply: $error';
  }

  @override
  String get chatReviseDialogTitle => 'Revise with AI';

  @override
  String get chatReviseDialogHint =>
      'Tell it how to change this (e.g. make it shorter)';

  @override
  String get chatReviseConfirmButton => 'Revise';

  @override
  String get chatDrawerStartFreshTitle => 'Start fresh';

  @override
  String get chatDrawerStartFreshSubtitle =>
      'Save the current chat and start over';

  @override
  String get chatDrawerResumeTitle => 'Resume';

  @override
  String get chatDrawerDeleteTitle => 'Delete chat';

  @override
  String get chatDrawerProfileTitle => 'Chat profile';

  @override
  String get chatDrawerChoicesTitle => 'Choices';

  @override
  String get chatDrawerChoicesDisabled => 'Off';

  @override
  String get chatDrawerExitButton => 'Leave chat room';

  @override
  String get chatDisclaimerBanner => 'All replies are AI-generated content';

  @override
  String get chatInputHint => 'Type a message';

  @override
  String get chatModelSheetTitle => 'Choose AI model';

  @override
  String get chatModelSheetDescription =>
      'The chat runs on the selected preset\'s settings. You can manage presets from My Page.';

  @override
  String get chatModelSheetPresetSettingsLink => 'Preset settings';

  @override
  String get chatModelSheetNoPresets => 'You haven\'t created any presets yet';

  @override
  String get chatPresetSelectDefault => 'Choose a preset';

  @override
  String get chatSheetStartFreshFromHere => 'Start fresh from here';

  @override
  String get chatProfileSheetTitle => 'My chat profiles';

  @override
  String get chatProfileSheetAddButton => 'Add chat profile';

  @override
  String get chatSuggestSheetTitle => 'Suggested replies';

  @override
  String get chatSuggestUseHint =>
      'Tap to fill the input, or tap the arrow to send right away.';

  @override
  String chatSuggestFailureMessage(Object error) {
    return 'Failed to generate suggestions: $error';
  }

  @override
  String get chatSuggestEmptyMessage =>
      'Couldn\'t come up with any suggestions.';

  @override
  String chatSnapshotFailureMessage(Object error) {
    return 'Failed to generate snapshot: $error';
  }

  @override
  String get chatSnapshotNotConfiguredMessage =>
      'Set up an image generation API key first, in My Page > Snapshot settings.';

  @override
  String get characterDetailExportMenuItem => 'Export';

  @override
  String get characterDetailContinueChatButton => 'Chat';

  @override
  String get characterDetailCharacterSectionTitle => 'Character';

  @override
  String get characterDetailIntroSectionTitle => 'Intro';

  @override
  String get plotEditTabPrompt => 'Prompt';

  @override
  String get plotEditTabLorebook => 'Lorebook';

  @override
  String get plotEditTabAbout => 'About';

  @override
  String plotEditDefaultCharacterName(Object index) {
    return 'Character $index';
  }

  @override
  String get plotEditAppBarTitle => 'Plot';

  @override
  String get plotEditExportCardMenuItem => 'Export as SillyTavern card';

  @override
  String get plotEditDraftSaveButton => 'Save draft';

  @override
  String get plotEditSaveButtonEdit => 'Save';

  @override
  String get plotEditSaveButtonCreate => 'Create';

  @override
  String get plotEditExportSuccessMessage => 'Exported as a SillyTavern card.';

  @override
  String plotEditExportFailureMessage(Object error) {
    return 'Failed to export: $error';
  }

  @override
  String plotEditCharCountLabel(Object count) {
    return '$count chars';
  }

  @override
  String get plotEditBasicSettingsTitle => 'Basic settings';

  @override
  String get plotEditTitleFieldLabel => 'Title';

  @override
  String get plotEditDescriptionFieldLabel => 'Description';

  @override
  String get plotEditAddCharacterButton => 'Add character';

  @override
  String get plotEditRepresentativeBadge => 'Main';

  @override
  String get plotEditCharacterImagePlaceholder => 'Character image';

  @override
  String get plotEditNameFieldLabel => 'Name';

  @override
  String get plotEditLorebookSavePlotFirst =>
      'Save the plot first to connect a lorebook.\nEnter the title/characters in the Prompt tab and tap the save button above.';

  @override
  String get plotEditLorebookConnectTitle => 'Connect a lorebook';

  @override
  String get plotEditLorebookConnectDescription =>
      'Whenever a keyword registered in the lorebook is mentioned,\nits content is sent to the AI';

  @override
  String plotEditLorebookConnectButton(Object linked, Object max) {
    return 'Connect lorebook ($linked/$max)';
  }

  @override
  String get plotEditIntroHintNarrator => '*Describe the situation*';

  @override
  String get plotEditIntroHintUser => 'Type the user\'s message';

  @override
  String plotEditIntroHintCharacter(Object name) {
    return 'Type $name\'s line';
  }

  @override
  String get plotEditEditContentDialogTitle => 'Edit content';

  @override
  String get plotEditIntroSavePlotFirst =>
      'Save the plot first to write an intro.\nEnter the title/characters in the Prompt tab and tap the save button above.';

  @override
  String get plotEditIntroFirstSceneTitle => 'Create the opening scene';

  @override
  String get plotEditIntroEmptyMessage =>
      'No intro written yet. Add the first line in the input box below.';

  @override
  String get plotEditProfileMarkerLabel => 'Chat profile picked here';

  @override
  String get plotEditAddImageTooltip => 'Add image (not sent to the AI)';

  @override
  String get plotEditComposerNarrator => 'Narrator';

  @override
  String get plotEditAddHashtagDialogTitle => 'Add hashtag';

  @override
  String get plotEditHashtagHint => 'Enter without the #';

  @override
  String get plotEditCoverTitle => 'Cover';

  @override
  String get plotEditPreviewButton => 'Preview';

  @override
  String get plotEditCoverImagePlaceholder => 'Cover image';

  @override
  String get plotEditShortIntroLabel => 'Short intro';

  @override
  String get plotEditShortIntroHint =>
      'Write a short intro to show alongside the title';

  @override
  String get plotEditHashtagsLabel => 'Hashtags';

  @override
  String get plotEditHashtagsDescription =>
      'Hashtags can get you up to 10x more exposure';

  @override
  String plotEditHashtagAddButton(Object count) {
    return 'Add $count/10';
  }

  @override
  String get plotEditAboutSectionTitle => 'About';

  @override
  String get plotEditAboutSectionDescription =>
      'Add content and images to show on the detail page.\nThis isn\'t sent to the AI.';

  @override
  String get plotEditAboutFieldHint =>
      'Write content to show on the detail page.\nThis isn\'t sent to the AI.';

  @override
  String get aiPresetScreenDescription =>
      'Create and manage the AI presets used in chats.';

  @override
  String get aiPresetScreenAddButton => 'Add preset';

  @override
  String get aiPresetEditTitleEdit => 'Edit preset';

  @override
  String get aiPresetEditTitleCreate => 'Add preset';

  @override
  String get aiPresetNameHint => 'e.g. Default style';

  @override
  String get aiPresetDescHint => 'Describe this preset in one line';

  @override
  String get aiPresetBaseUrlHint => 'e.g. https://api.openai.com/v1';

  @override
  String get aiPresetModelNameLabel => 'Model name';

  @override
  String get aiPresetModelNameHint => 'e.g. gpt-4o-mini, claude-sonnet-5';

  @override
  String get aiPresetApiKeyLabel => 'API key';

  @override
  String get aiPresetApiKeyStorageNote => 'Stored securely on this device only';

  @override
  String get aiPresetApiKeyHint => 'Enter your own API key';

  @override
  String get aiPresetAdvancedSettingsTitle => 'Advanced settings';

  @override
  String get aiPresetAdvancedSettingsDescription =>
      'All optional. Leave blank to omit from requests.';

  @override
  String get aiPresetTemperatureHint => 'e.g. 1.0';

  @override
  String get aiPresetTopKHint => 'e.g. 40';

  @override
  String get aiPresetMaxTokensHint => 'e.g. 1024';

  @override
  String get aiPresetContextLengthHint => 'How many recent messages to include';

  @override
  String get aiPresetAdditionalPromptLabel => 'Additional system prompt';

  @override
  String get aiPresetAdditionalPromptHint =>
      'Instructions to append after the base prompt (optional)';

  @override
  String get aiPresetSaveButton => 'Save';

  @override
  String get lorebookConnectTitle => 'Connect lorebook';

  @override
  String lorebookConnectNoneButton(Object max) {
    return 'Not connected (0/$max)';
  }

  @override
  String lorebookConnectConfirmButton(Object count, Object max) {
    return 'Connect ($count/$max)';
  }

  @override
  String get lorebookDetailDeletedMessage => 'This lorebook has been deleted';

  @override
  String get lorebookInfoTabLabel => 'Lore info';

  @override
  String get lorebookLinkedPlotsTabLabel => 'Linked plots';

  @override
  String get lorebookPlotConnectTabLabel => 'Connect plots';

  @override
  String get lorebookDetailEditMenuItem => 'Edit lorebook';

  @override
  String get lorebookDetailNoEntriesMessage => 'No entries written yet';

  @override
  String get lorebookDetailNoLinkedPlotsMessage => 'No linked plots';

  @override
  String get lorebookEditAppBarTitle => 'Lorebook';

  @override
  String get lorebookEditSaveButtonCreate => 'Create';

  @override
  String get lorebookEditSaveFirstMessage =>
      'Create the lorebook first to connect plots.';

  @override
  String get lorebookEditIntroDescription =>
      'The intro isn\'t sent to the AI.\nUse it to help manage the lorebook.';

  @override
  String get lorebookEditTitleFieldLabel => 'Lorebook title';

  @override
  String get lorebookEditEntriesSectionTitle => 'Entries';

  @override
  String get lorebookEditAddEntryButton => 'Add entry';

  @override
  String lorebookEditEntryCardTitle(Object index) {
    return 'Entry $index';
  }

  @override
  String get lorebookEditEntryTitleHint => 'Enter a title';

  @override
  String get lorebookEditKeywordsLabel => 'Keywords';

  @override
  String get lorebookEditKeywordsHint =>
      'Separate keywords with commas.\nWhenever one is mentioned, the content below is sent to the AI.';

  @override
  String get lorebookEditContentLabel => 'Content';

  @override
  String get lorebookEditContentHint =>
      'Enter the content to send to the AI when a keyword is mentioned.';

  @override
  String get lorebookEditConnectPlotsTitle => 'Connect plots';

  @override
  String get lorebookEditConnectPlotsDescription =>
      'Once connected, the lorebook\'s world info\nis sent to the AI whenever a keyword is mentioned';

  @override
  String lorebookConnectButtonWithCount(Object count) {
    return 'Connect ($count)';
  }

  @override
  String get profileEditNameDescription =>
      'This is what characters will call me';

  @override
  String get profileEditDescriptionLabel => 'Description (optional)';

  @override
  String get profileEditDefaultSectionTitle => 'Default chat profile';

  @override
  String get profileEditApplyDefaultTitle => 'Apply this profile to new chats';

  @override
  String get profileEditApplyDefaultDescription =>
      'You can switch profiles mid-chat';

  @override
  String get resumeNoSavedConversations => 'No saved conversations';

  @override
  String get resumeJustNow => 'Just now';

  @override
  String resumeMinutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String resumeHoursAgo(Object count) {
    return '$count hr ago';
  }

  @override
  String resumeDaysAgo(Object count) {
    return '$count d ago';
  }

  @override
  String resumeSavedAtLabel(Object date) {
    return 'Chat saved at $date';
  }

  @override
  String get resumeNoSavedMessage => 'No saved messages';

  @override
  String get tokenUsageTitle => 'Token usage history';

  @override
  String get tokenUsageDeleteAllButton => 'Delete all';

  @override
  String get tokenUsageDeleteAllConfirmTitle => 'Delete all history?';

  @override
  String get tokenUsageDeleteAllConfirmContent => 'This cannot be undone.';

  @override
  String get tokenUsageEmptyMessage => 'No usage history yet';

  @override
  String tokenUsageProviderLabel(Object provider, Object presetName) {
    return 'Provider: $provider · $presetName';
  }

  @override
  String tokenUsageBreakdown(Object prompt, Object completion, Object total) {
    return 'In $prompt · Out $completion · Total $total';
  }

  @override
  String get startFreshDialogTitle => 'Start this chat over?';

  @override
  String get startFreshDialogDescription =>
      'Saved chats can always be resumed later\nfrom \"Resume\"';

  @override
  String get startFreshDialogSaveCheckbox => 'Save the current chat';

  @override
  String get startFreshFromHereDialogTitle => 'Start over from here?';

  @override
  String get startFreshFromHereDialogDescription =>
      'The existing chat can always be resumed later\nfrom \"Resume\"';

  @override
  String get systemPromptButtonLabel => 'System prompt settings';

  @override
  String get systemPromptWarning =>
      'Please only edit this if truly necessary. Editing it incorrectly can make the AI\'s replies behave strangely.';

  @override
  String get systemPromptPlaceholderHintTitle => 'Available placeholders';

  @override
  String get systemPromptPlaceholderHintBody =>
      'Wrap any of these names in double curly braces to have them replaced with real values: plot_title, plot_description, characters_block, example_character_name, user_profile_name, lore_block, extra_block\nDon\'\'t remove the \"user\" token, though — the AI needs to leave that one as-is in its replies.';

  @override
  String get systemPromptResetButton => 'Reset to default';

  @override
  String get systemPromptResetConfirmTitle => 'Reset to default?';

  @override
  String get systemPromptResetConfirmContent =>
      'Your current edits will be discarded and the default system prompt will be restored.';

  @override
  String get systemPromptSavedMessage => 'Saved.';

  @override
  String get systemPromptResetDoneMessage => 'Reset to default.';

  @override
  String get snapshotSettingsTitle => 'Snapshot settings';

  @override
  String get snapshotSettingsDescription =>
      'When you tap snapshot in a chat, the AI summarizes the current scene and generates an image using the endpoint set up below.';

  @override
  String get snapshotSettingsProviderLabel => 'Image generation endpoint';

  @override
  String get snapshotSettingsApiKeyLabel => 'API key';

  @override
  String get snapshotSettingsApiKeyHint =>
      'Enter the API key for the endpoint you chose';

  @override
  String get snapshotSettingsModelNameLabel => 'Image model name';

  @override
  String get snapshotSettingsModelNameHint =>
      'e.g. google/gemini-2.5-flash-image';

  @override
  String get snapshotSettingsSaveButton => 'Save';

  @override
  String get snapshotSettingsSavedMessage => 'Saved.';
}
