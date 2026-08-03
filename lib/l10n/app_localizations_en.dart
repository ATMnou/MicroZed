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
  String get myPageLocalLlmButton => 'Local LLM';

  @override
  String get localLlmScreenTitle => 'Local LLM';

  @override
  String get localLlmScreenDescription =>
      'Run an AI model directly on your device, no internet needed. Speed and quality depend on your device and the model size.';

  @override
  String get localLlmRecommendedSectionTitle => 'Recommended models';

  @override
  String get localLlmModelDescHuihuiQwen3508b =>
      'IQ4 XS, don\'t expect much performance.';

  @override
  String get localLlmModelDescHuihuiQwen354b =>
      'Balanced speed and quality. Handles Korean reasonably well.';

  @override
  String get localLlmModelDescHuihuiGemma4E2b =>
      'Lightest and fastest. Good for low-spec devices.';

  @override
  String get localLlmModelDescHuihuiGemma4E4b =>
      'Better quality. Recommended for high-spec devices/PC.';

  @override
  String get localLlmImportSectionTitle => 'Import from a file';

  @override
  String get localLlmSavedPresetsSectionTitle => 'Saved local presets';

  @override
  String get localLlmCacheSectionTitle => 'Downloaded models';

  @override
  String get localLlmCurrentStatusLabel => 'Currently loaded model';

  @override
  String get localLlmNoModelLoaded => 'No model loaded';

  @override
  String get localLlmUnloadButton => 'Unload';

  @override
  String get localLlmUseButton => 'Use';

  @override
  String get localLlmLoadButton => 'Load';

  @override
  String get localLlmInUseLabel => 'In use';

  @override
  String get localLlmImportButton => 'Choose GGUF file';

  @override
  String get localLlmImportDescription =>
      'Pick a .gguf model file you\'ve already downloaded.';

  @override
  String get localLlmNoSavedPresets => 'No saved local presets yet.';

  @override
  String get localLlmNoCachedModels => 'No downloaded models yet.';

  @override
  String get localLlmPresetDescription => 'On-device local model';

  @override
  String localLlmLoadSuccessMessage(Object modelName) {
    return 'Loaded $modelName.';
  }

  @override
  String localLlmLoadFailureMessage(Object error) {
    return 'Failed to load the model: $error';
  }

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
  String get preferencesAiSectionTitle => 'AI settings';

  @override
  String get preferencesThemeSectionTitle => 'Theme';

  @override
  String get preferencesThemeDarkOption => 'Dark';

  @override
  String get preferencesThemeLightOption => 'Light';

  @override
  String get preferencesThemeAmoledOption => 'AMOLED black';

  @override
  String get preferencesThemeSystemOption => 'System default';

  @override
  String get preferencesVersionSectionTitle => 'Version';

  @override
  String preferencesCurrentVersionLabel(String version) {
    return 'Current version $version';
  }

  @override
  String get preferencesCheckUpdateButton => 'Check for updates';

  @override
  String preferencesUpdateAvailableMessage(String version) {
    return 'Version $version is available.';
  }

  @override
  String get preferencesUpToDateMessage => 'You\'re on the latest version.';

  @override
  String get preferencesUpdateCheckFailedMessage =>
      'Couldn\'t check for updates.';

  @override
  String get preferencesViewReleaseButton => 'View release';

  @override
  String get preferencesDangerZoneTitle => 'Danger zone';

  @override
  String get preferencesResetAllDescription =>
      'Erases all data stored on this device — plots, characters, chats, lorebooks, presets, images — and returns the app to its freshly-installed state. Downloaded local LLM model files are kept. This cannot be undone.';

  @override
  String get preferencesResetAllButton => 'Reset everything';

  @override
  String get preferencesResetConfirmContent =>
      'All data will be permanently deleted. If you haven\'t backed up yet, use \"Export all\" on My Page before continuing.';

  @override
  String get preferencesResetConfirmWord => 'RESET';

  @override
  String preferencesResetTypeToConfirm(Object word) {
    return 'Type \"$word\" below to continue.';
  }

  @override
  String get preferencesResetSuccessMessage => 'All data has been reset.';

  @override
  String preferencesResetFailureMessage(Object error) {
    return 'Reset failed: $error';
  }

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
  String conversationTabSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get conversationTabDeleteConfirmTitle => 'Delete chats';

  @override
  String get conversationTabDeleteConfirmContent =>
      'Delete the selected chats? This can\'t be undone.';

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
  String get createTabImportFromPlotDataTitle =>
      'Import from native format (.mzplot)';

  @override
  String get createTabImportFromPlotDataSubtitle =>
      'Loads the whole plot including images (chat history excluded)';

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
  String get createTabDeletePlotConfirmTitle => 'Delete this plot?';

  @override
  String get createTabDeletePlotConfirmContent =>
      'The plot and its conversations can\'t be recovered once deleted.';

  @override
  String get chatDefaultUserName => 'User';

  @override
  String get chatDefaultCharacterName => 'Character';

  @override
  String get chatSelectPresetFirstMessage => 'Please choose an AI preset first';

  @override
  String get chatReasoningInProgressLabel => 'Thinking...';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'Failed to generate AI reply: $error';
  }

  @override
  String get chatGeneratingIndicator => 'Generating reply...';

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
  String get chatDrawerMemoryTitle => 'View memory';

  @override
  String get chatMemorySheetTitle => 'Previous conversation summary';

  @override
  String get chatMemoryEmptyMessage =>
      'No summarized memory yet. It\'s created automatically as the chat gets longer.';

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
  String get characterDetailIntroNarratorLabel => 'Narration';

  @override
  String get characterDetailIntroUserLabel => 'Me';

  @override
  String get characterDetailIntroImageLabel => 'Image';

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
  String get plotEditExportDataMenuItem => 'Export in native format (all data)';

  @override
  String get plotEditSaveButtonEdit => 'Save';

  @override
  String get plotEditSaveButtonCreate => 'Create';

  @override
  String get plotEditExportSuccessMessage => 'Exported as a SillyTavern card.';

  @override
  String get plotEditExportDataSuccessMessage =>
      'Exported in native format (.mzplot).';

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
  String plotEditLorebookConnectButton(Object linked) {
    return 'Connect lorebook ($linked)';
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
  String get plotProfileSectionTitle =>
      'Create a conversation profile for the playing user';

  @override
  String get plotProfileSectionDescription =>
      'These profiles are only used for this plot. There\'s no limit on how many you can make.';

  @override
  String get plotProfileSavePlotFirst =>
      'Save the plot first to create conversation profiles.\nEnter a title/character on the Prompt tab and tap the save button above.';

  @override
  String get plotProfileAddButton => 'Add conversation profile';

  @override
  String get plotProfileUseGlobalNameLabel => 'Use the playing user\'s name';

  @override
  String plotProfileUseGlobalNameDescription(String name) {
    return 'When checked, this uses your My Page default profile\'s name ($name)';
  }

  @override
  String get plotProfileShortIntroLabel => 'Short intro';

  @override
  String get plotProfileShortIntroDescription =>
      'A one-line blurb shown on the card. Not sent to the AI.';

  @override
  String get plotProfileDescriptionLabel => 'Description';

  @override
  String get plotProfileDescriptionHint =>
      'Write specific details like when making a character.\nE.g. 18 years old, 181cm tall, handsome and top of the class, popular with everyone';

  @override
  String get plotProfilePickerTitle => 'Choose a profile';

  @override
  String get plotProfilePickerSwipeHint =>
      'Swipe sideways to see other profiles';

  @override
  String get plotProfilePickerSelectButton => 'Select';

  @override
  String get plotProfilePickerListTitle => 'Choose a profile';

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
  String get plotEditCoverImagePlaceholder => 'Cover image';

  @override
  String get plotEditShortIntroLabel => 'Short intro';

  @override
  String get plotEditShortIntroHint =>
      'Write a short intro to show alongside the title';

  @override
  String get plotEditHashtagsLabel => 'Hashtags';

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
  String get aiPresetReasoningEffortLabel => 'Reasoning effort';

  @override
  String get aiPresetReasoningEffortDescription =>
      'How deeply a reasoning model should think before answering. Local models get thinking mode turned on; remote models only apply this if they support it.';

  @override
  String get aiPresetReasoningEffortOff => 'Off';

  @override
  String get aiPresetReasoningEffortLow => 'Low';

  @override
  String get aiPresetReasoningEffortMedium => 'Medium';

  @override
  String get aiPresetReasoningEffortHigh => 'High';

  @override
  String get aiPresetEndpointFormatLabel => 'Endpoint format';

  @override
  String get aiPresetEndpointFormatDescription =>
      'Uses the request/response parser matching the selected format.';

  @override
  String get aiPresetEndpointFormatOpenAi => 'OpenAI-compatible';

  @override
  String get aiPresetEndpointFormatAnthropic => 'Anthropic';

  @override
  String get aiPresetSupportsVisionLabel =>
      'Supports image recognition (vision)';

  @override
  String get aiPresetSupportsVisionDescription =>
      'When on, ZedTalk sends attached images to this preset\'s model. Only enable it for models that actually understand images.';

  @override
  String get aiPresetOpenRouterSectionTitle => 'OpenRouter-only options';

  @override
  String get aiPresetOpenRouterSectionDescription =>
      'Only applies when the base URL is openrouter.ai.';

  @override
  String get aiPresetOpenRouterZdrOnlyLabel => 'ZDR providers only';

  @override
  String get aiPresetOpenRouterZdrOnlyDescription =>
      'Route only to providers with Zero Data Retention.';

  @override
  String get aiPresetOpenRouterExcludeChinaLabel => 'Exclude Chinese providers';

  @override
  String get aiPresetOpenRouterExcludeChinaDescription =>
      'Exclude China-based providers (e.g. Alibaba) from routing.';

  @override
  String get aiPresetOpenRouterExcludeTrainingLabel =>
      'Exclude training-data providers';

  @override
  String get aiPresetOpenRouterExcludeTrainingDescription =>
      'Exclude providers that may use request data for training.';

  @override
  String get lorebookConnectTitle => 'Connect lorebook';

  @override
  String get lorebookConnectNoneButton => 'Not connected';

  @override
  String lorebookConnectConfirmButton(Object count) {
    return 'Connect ($count)';
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

  @override
  String get createTabAiGenerateButton => 'Generate with AI';

  @override
  String get plotAiGenerateTitle => 'Generate plot with AI';

  @override
  String get plotAiGeneratePresetLabel => 'AI preset to use';

  @override
  String get plotAiGeneratePresetEmptyHint =>
      'Create an AI preset in Preferences > AI settings first.';

  @override
  String get plotAiGeneratePromptLabel => 'What plot do you want to make?';

  @override
  String get plotAiGeneratePromptHint =>
      'Describe the genre, setting, characters, etc. freely';

  @override
  String get plotAiGenerateWebSearchLabel =>
      'Look up references via web search';

  @override
  String get plotAiGenerateWebSearchUnsupportedHint =>
      'The selected preset doesn\'t support native web search (only OpenRouter or OpenAI-family endpoints do).';

  @override
  String get plotAiGenerateLoreLengthLabel => 'Lore length';

  @override
  String get plotAiGenerateLoreLengthShort => 'Short';

  @override
  String get plotAiGenerateLoreLengthMedium => 'Medium';

  @override
  String get plotAiGenerateLoreLengthLong => 'Long';

  @override
  String get plotAiGenerateAccuracyLabel => 'Accuracy';

  @override
  String get plotAiGenerateAccuracyAccurate => 'Accurate';

  @override
  String get plotAiGenerateAccuracyMixed => 'Mixed';

  @override
  String get plotAiGenerateSubmitButton => 'Generate';

  @override
  String get plotAiGeneratePromptEmptyMessage =>
      'Describe what plot you want first.';

  @override
  String plotAiGenerateFailureMessage(Object error) {
    return 'Failed to generate plot: $error';
  }

  @override
  String get plotAiGenerateGeneratingMessage => 'AI is generating the plot...';

  @override
  String get lanSyncSectionTitle => 'LAN sync';

  @override
  String get lanSyncScreenTitle => 'LAN sync';

  @override
  String get lanSyncExportSectionTitle => 'Export from this device';

  @override
  String get lanSyncExportSectionDescription =>
      'Connect from another device on the same Wi-Fi/LAN using the info below to pull all data.';

  @override
  String get lanSyncStartHostButton => 'Start waiting for connection';

  @override
  String get lanSyncStopHostButton => 'Stop';

  @override
  String get lanSyncWaitingMessage =>
      'Waiting for another device to connect...';

  @override
  String get lanSyncAddressLabel => 'Address';

  @override
  String get lanSyncPortLabel => 'Port';

  @override
  String get lanSyncPinLabel => 'PIN';

  @override
  String get lanSyncExportedMessage => 'Transfer complete.';

  @override
  String lanSyncExportFailedMessage(Object error) {
    return 'Transfer failed: $error';
  }

  @override
  String get lanSyncNoAddressWarning =>
      'Couldn\'t find a LAN address on this device. Check your Wi-Fi connection.';

  @override
  String get lanSyncImportSectionTitle => 'Import from another device';

  @override
  String get lanSyncImportSectionDescription =>
      'Enter the address/port/PIN shown on the exporting device\'s screen.';

  @override
  String get lanSyncHostFieldLabel => 'Address (IP)';

  @override
  String get lanSyncPortFieldLabel => 'Port';

  @override
  String get lanSyncPinFieldLabel => 'PIN';

  @override
  String get lanSyncImportButton => 'Import';

  @override
  String get lanSyncImportConfirmTitle => 'Replace all data';

  @override
  String get lanSyncImportConfirmContent =>
      'This overwrites all data on this device with what\'s received. This can\'t be undone.';

  @override
  String lanSyncImportFailedMessage(Object error) {
    return 'Import failed: $error';
  }

  @override
  String createTabSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get createTabDeleteSelectedConfirmTitle => 'Delete plots';

  @override
  String get createTabDeleteSelectedConfirmContent =>
      'Delete the selected plots? This can\'t be undone.';

  @override
  String get createTabExportPackageButton => 'Export as package (.mzpack)';

  @override
  String createTabExportPackageSuccessMessage(int count) {
    return 'Exported $count plots.';
  }

  @override
  String createTabExportPackageFailureMessage(Object error) {
    return 'Failed to export: $error';
  }

  @override
  String get createTabImportFromPackageTitle =>
      'Import from plot package (.mzpack)';

  @override
  String get createTabImportFromPackageSubtitle =>
      'Import multiple plots at once';

  @override
  String createTabImportPackageSuccessMessage(int count) {
    return 'Imported $count plots.';
  }

  @override
  String get conversationTabTalkLabel => 'Talk';

  @override
  String get characterDetailTalkButton => 'ZedTalk';

  @override
  String get talkListEmpty => 'No ZedTalk chats yet';

  @override
  String get talkAttachmentSheetTitle => 'Attach';

  @override
  String get talkAttachmentImageOption => 'Image';

  @override
  String get talkAttachmentVideoOption => 'Video';

  @override
  String get talkAttachmentDocumentOption => 'Document';

  @override
  String get talkVisionUnsupportedNote =>
      'This preset doesn\'t support image recognition, so the attached image won\'t be sent to the AI.';

  @override
  String get talkPresetSheetTitle => 'AI preset to use';

  @override
  String get talkNoPresetMessage => 'Choose an AI preset first.';

  @override
  String get talkDeleteConfirmTitle => 'Delete chats';

  @override
  String get talkDeleteConfirmContent =>
      'Delete the selected ZedTalk chats? This can\'t be undone.';
}
