// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Microzed';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonSave => '저장';

  @override
  String get commonEdit => '편집';

  @override
  String get commonAdd => '추가';

  @override
  String get commonClose => '닫기';

  @override
  String get commonCopy => '복사';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageDialogTitle => '언어 선택';

  @override
  String get languageSystemDefault => '시스템 기본';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get myPageTitle => '마이페이지';

  @override
  String get myPageEditProfileButton => '대화 프로필 편집';

  @override
  String get myPageAiPresetButton => 'AI 프리셋 설정';

  @override
  String get myPageTokensUsedLabel => '소모된 토큰';

  @override
  String get myPageHistoryButton => '내역';

  @override
  String get myPageBackupSectionTitle => '데이터 백업';

  @override
  String get myPageBackupSectionDescription =>
      '플롯/캐릭터/대화/로어북/프리셋 등 모든 데이터를 파일 하나로 저장하거나 불러올 수 있어요.';

  @override
  String get myPageExportAllButton => '전체 저장';

  @override
  String get myPageImportAllButton => '전체 불러오기';

  @override
  String get myPageExportSuccessMessage => '전체 데이터를 저장했어요.';

  @override
  String myPageExportFailureMessage(Object error) {
    return '저장에 실패했어요: $error';
  }

  @override
  String get myPageImportDialogTitle => '전체 불러오기';

  @override
  String get myPageImportDialogContent =>
      '지금 앱에 있는 모든 플롯/캐릭터/대화/로어북/프리셋이 이 백업 내용으로 완전히 대체돼요.\n이 작업은 되돌릴 수 없어요. 계속할까요?';

  @override
  String get myPageImportRestoreButton => '복원';

  @override
  String myPageImportSuccessMessage(
    Object plotCount,
    Object chatMessageCount,
    Object lorebookCount,
  ) {
    return '복원 완료: 플롯 $plotCount개, 대화 메시지 $chatMessageCount개, 로어북 $lorebookCount개';
  }

  @override
  String myPageImportFailureMessage(Object error) {
    return '불러오기에 실패했어요: $error';
  }

  @override
  String get myPageLicensesButton => '오픈소스 라이선스';

  @override
  String get myPageSourceCodeButton => 'GitHub 저장소';

  @override
  String get myPageSnapshotSettingsButton => '스냅샷 설정';

  @override
  String get preferencesTitle => '환경설정';

  @override
  String get preferencesImageDisplayModeLabel => '이미지 표시 방식';

  @override
  String get preferencesImageDisplayModeDescription =>
      '인트로/스냅샷 이미지를 채팅에서 어떻게 보여줄지 골라요.';

  @override
  String get preferencesImageDisplaySquareOption => '정사각형 (지금처럼)';

  @override
  String get preferencesImageDisplayFullWidthOption => '가로 꽉 채우기';

  @override
  String get navHome => '홈';

  @override
  String get navChat => '대화';

  @override
  String get navCreate => '제작';

  @override
  String get navMyPage => '마이페이지';

  @override
  String get commonNoSearchResults => '검색 결과가 없어요';

  @override
  String get searchHintPlot => '플롯 제목, 소개, 해시태그 검색';

  @override
  String get searchHintLorebook => '로어북 제목 검색';

  @override
  String totalCountLabel(Object count) {
    return '총 $count개';
  }

  @override
  String conversationCountLabel(Object count) {
    return '대화량 $count';
  }

  @override
  String get homeNoPlotsYet => '아직 만든 플롯이 없어요';

  @override
  String get conversationTabTitle => '대화';

  @override
  String get conversationTabEmpty => '아직 진행 중인 대화가 없어요';

  @override
  String get conversationTabSortLatest => '최신순';

  @override
  String get conversationTilePlaceholder => '대화를 시작해보세요';

  @override
  String get createTabPlotLabel => '플롯';

  @override
  String get createTabLorebookLabel => '로어북';

  @override
  String get createTabNoLorebooksYet => '아직 만든 로어북이 없어요';

  @override
  String get createTabLorebookNote1 => '• 대화량은 해당 로어북이 연결된 플롯에서 생긴 대화의 총합이에요.';

  @override
  String get createTabLorebookNote2 =>
      '• 로어북을 수정하거나 삭제하면 연결된 모든 플롯에 즉시 반영돼요. 변경하실 때 꼭 한 번 더 확인해주세요.';

  @override
  String lorebookTileStats(Object count, Object linked) {
    return '대화량 $count · 연결 플롯 $linked';
  }

  @override
  String get createTabImportButton => '불러오기';

  @override
  String get createTabImportSheetTitle => 'SillyTavern 카드 불러오기';

  @override
  String get createTabImportFromFileTitle => '파일에서 불러오기 (PNG/JSON)';

  @override
  String get createTabImportFromFileSubtitle => 'SillyTavern 캐릭터 카드 파일을 선택해요';

  @override
  String get createTabImportFromUrlTitle => '링크(URL)에서 가져오기';

  @override
  String get createTabImportFromUrlSubtitle => '카드 파일 링크나 사이트 주소를 붙여넣어요';

  @override
  String get createTabImportUrlDialogTitle => '링크에서 가져오기';

  @override
  String get createTabImportConfirmButton => '가져오기';

  @override
  String get createTabNoIntroWarning =>
      '이 카드엔 오프닝 메시지가 없어서 인트로 탭을 비워뒀어요. \"인트로\" 탭에서 직접 작성해주세요.';

  @override
  String createTabImportFailureMessage(Object error) {
    return '불러오기에 실패했어요: $error';
  }

  @override
  String get createTabCreateButton => '제작하기';

  @override
  String get createTabEditPlotMenuItem => '플롯 수정';

  @override
  String get createTabDeleteLorebookConfirmTitle => '로어북을 삭제할까요?';

  @override
  String get createTabDeleteLorebookConfirmContent => '연결된 모든 플롯에 즉시 반영돼요.';

  @override
  String get createTabDeletePlotConfirmTitle => '플롯을 삭제할까요?';

  @override
  String get createTabDeletePlotConfirmContent => '삭제한 플롯과 관련 대화는 되돌릴 수 없어요.';

  @override
  String get chatDefaultUserName => '유저';

  @override
  String get chatDefaultCharacterName => '캐릭터';

  @override
  String get chatSelectPresetFirstMessage => 'AI 프리셋을 먼저 선택해주세요';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'AI 응답 생성에 실패했어요: $error';
  }

  @override
  String get chatReviseDialogTitle => 'AI 수정';

  @override
  String get chatReviseDialogHint => '어떻게 고칠지 알려주세요 (예: 더 짧게)';

  @override
  String get chatReviseConfirmButton => '수정하기';

  @override
  String get chatDrawerStartFreshTitle => '새로하기';

  @override
  String get chatDrawerStartFreshSubtitle => '현재 내용을 저장하고 다시 시작할 수 있어요';

  @override
  String get chatDrawerResumeTitle => '이어하기';

  @override
  String get chatDrawerDeleteTitle => '대화 삭제';

  @override
  String get chatDrawerProfileTitle => '대화 프로필';

  @override
  String get chatDrawerChoicesTitle => '선택지';

  @override
  String get chatDrawerChoicesDisabled => '사용 안함';

  @override
  String get chatDrawerExitButton => '대화방 나가기';

  @override
  String get chatDisclaimerBanner => '답변은 모두 AI가 생성한 내용이에요';

  @override
  String get chatInputHint => '내용 입력하기';

  @override
  String get chatModelSheetTitle => 'AI 모델 선택';

  @override
  String get chatModelSheetDescription =>
      '선택한 프리셋의 설정으로 대화가 진행돼요. 프리셋은 마이페이지에서 관리할 수 있어요.';

  @override
  String get chatModelSheetPresetSettingsLink => '프리셋 설정';

  @override
  String get chatModelSheetNoPresets => '아직 만든 프리셋이 없어요';

  @override
  String get chatPresetSelectDefault => '프리셋 선택';

  @override
  String get chatSheetStartFreshFromHere => '여기서부터 새로하기';

  @override
  String get chatProfileSheetTitle => '내 대화 프로필';

  @override
  String get chatProfileSheetAddButton => '대화 프로필 추가';

  @override
  String get chatSuggestSheetTitle => '다음 대화 추천';

  @override
  String get chatSuggestUseHint => '탭하면 입력창에 채워지고, 화살표를 누르면 바로 보내요.';

  @override
  String chatSuggestFailureMessage(Object error) {
    return '다음 대화 추천 생성에 실패했어요: $error';
  }

  @override
  String get chatSuggestEmptyMessage => '추천할 만한 대화를 찾지 못했어요.';

  @override
  String chatSnapshotFailureMessage(Object error) {
    return '스냅샷 생성에 실패했어요: $error';
  }

  @override
  String get chatSnapshotNotConfiguredMessage =>
      '마이페이지 > 스냅샷 설정에서 이미지 생성 API 키를 먼저 등록해주세요.';

  @override
  String get characterDetailExportMenuItem => '내보내기';

  @override
  String get characterDetailContinueChatButton => '대화하기';

  @override
  String get characterDetailCharacterSectionTitle => '캐릭터';

  @override
  String get characterDetailIntroSectionTitle => '인트로';

  @override
  String get plotEditTabPrompt => '프롬프트';

  @override
  String get plotEditTabLorebook => '로어북';

  @override
  String get plotEditTabAbout => '소개';

  @override
  String plotEditDefaultCharacterName(Object index) {
    return '캐릭터 $index';
  }

  @override
  String get plotEditAppBarTitle => '플롯';

  @override
  String get plotEditExportCardMenuItem => 'SillyTavern 카드로 내보내기';

  @override
  String get plotEditDraftSaveButton => '임시저장';

  @override
  String get plotEditSaveButtonEdit => '수정';

  @override
  String get plotEditSaveButtonCreate => '제작';

  @override
  String get plotEditExportSuccessMessage => 'SillyTavern 카드로 내보냈어요.';

  @override
  String plotEditExportFailureMessage(Object error) {
    return '내보내기에 실패했어요: $error';
  }

  @override
  String plotEditCharCountLabel(Object count) {
    return '$count자';
  }

  @override
  String get plotEditBasicSettingsTitle => '기본 설정';

  @override
  String get plotEditTitleFieldLabel => '제목';

  @override
  String get plotEditDescriptionFieldLabel => '설명';

  @override
  String get plotEditAddCharacterButton => '캐릭터 추가';

  @override
  String get plotEditRepresentativeBadge => '대표';

  @override
  String get plotEditCharacterImagePlaceholder => '캐릭터 이미지';

  @override
  String get plotEditNameFieldLabel => '이름';

  @override
  String get plotEditLorebookSavePlotFirst =>
      '플롯을 먼저 저장하면 로어북을 연결할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.';

  @override
  String get plotEditLorebookConnectTitle => '로어북을 연결해 주세요';

  @override
  String get plotEditLorebookConnectDescription =>
      '로어북에 등록한 키워드가 언급될 때마다\n작성한 내용이 AI에게 전달돼요';

  @override
  String plotEditLorebookConnectButton(Object linked, Object max) {
    return '로어북 연결 ($linked/$max)';
  }

  @override
  String get plotEditIntroHintNarrator => '*상황을 설명해주세요*';

  @override
  String get plotEditIntroHintUser => '유저 메시지를 입력해주세요';

  @override
  String plotEditIntroHintCharacter(Object name) {
    return '$name의 대사를 입력해주세요';
  }

  @override
  String get plotEditEditContentDialogTitle => '내용 수정';

  @override
  String get plotEditIntroSavePlotFirst =>
      '플롯을 먼저 저장하면 인트로를 작성할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.';

  @override
  String get plotEditIntroFirstSceneTitle => '첫 상황을 만들어 주세요';

  @override
  String get plotEditIntroEmptyMessage =>
      '아직 작성된 인트로가 없어요. 아래 입력창에서 첫 줄을 추가해보세요.';

  @override
  String get plotEditProfileMarkerLabel => '대화 프로필 선택 시점';

  @override
  String get plotEditAddImageTooltip => '이미지 추가 (AI에게 전달되지 않아요)';

  @override
  String get plotEditComposerNarrator => '내레이터';

  @override
  String get plotEditAddHashtagDialogTitle => '해시태그 추가';

  @override
  String get plotEditHashtagHint => '# 없이 입력해주세요';

  @override
  String get plotEditCoverTitle => '커버';

  @override
  String get plotEditPreviewButton => '미리보기';

  @override
  String get plotEditCoverImagePlaceholder => '커버 이미지';

  @override
  String get plotEditShortIntroLabel => '짧은 소개';

  @override
  String get plotEditShortIntroHint => '제목과 함께 보일 짧은 소개를 입력해주세요';

  @override
  String get plotEditHashtagsLabel => '해시태그';

  @override
  String get plotEditHashtagsDescription => '해시태그가 있으면 10배 더 많이 노출될 거예요';

  @override
  String plotEditHashtagAddButton(Object count) {
    return '추가 $count/10';
  }

  @override
  String get plotEditAboutSectionTitle => '소개글';

  @override
  String get plotEditAboutSectionDescription =>
      '상세 페이지에 표시할 내용, 이미지를 추가해 주세요.\n이 내용은 AI에게 전달되지 않아요.';

  @override
  String get plotEditAboutFieldHint =>
      '상세 페이지에 표시할 내용을 써주세요.\n이 내용은 AI에게 전달되지 않아요.';

  @override
  String get aiPresetScreenDescription => '대화에서 사용할 AI 프리셋을 만들고 관리하세요.';

  @override
  String get aiPresetScreenAddButton => '프리셋 추가';

  @override
  String get aiPresetEditTitleEdit => '프리셋 수정';

  @override
  String get aiPresetEditTitleCreate => '프리셋 추가';

  @override
  String get aiPresetNameHint => '예: 기본 스타일';

  @override
  String get aiPresetDescHint => '이 프리셋을 한 줄로 소개해주세요';

  @override
  String get aiPresetBaseUrlHint => '예: https://api.openai.com/v1';

  @override
  String get aiPresetModelNameLabel => '모델명';

  @override
  String get aiPresetModelNameHint => '예: gpt-4o-mini, claude-sonnet-5';

  @override
  String get aiPresetApiKeyLabel => 'API 키';

  @override
  String get aiPresetApiKeyStorageNote => '기기에만 안전하게 저장돼요';

  @override
  String get aiPresetApiKeyHint => '직접 발급받은 API 키를 입력해주세요';

  @override
  String get aiPresetAdvancedSettingsTitle => '고급 설정';

  @override
  String get aiPresetAdvancedSettingsDescription =>
      '전부 선택 사항이에요. 비워두면 요청에 포함하지 않아요.';

  @override
  String get aiPresetTemperatureHint => '예: 1.0';

  @override
  String get aiPresetTopKHint => '예: 40';

  @override
  String get aiPresetMaxTokensHint => '예: 1024';

  @override
  String get aiPresetContextLengthHint => '최근 메시지 몇 개까지';

  @override
  String get aiPresetAdditionalPromptLabel => '추가 시스템 프롬프트';

  @override
  String get aiPresetAdditionalPromptHint => '기본 프롬프트 뒤에 덧붙일 지침(선택)';

  @override
  String get aiPresetSaveButton => '저장하기';

  @override
  String get lorebookConnectTitle => '로어북 연결';

  @override
  String lorebookConnectNoneButton(Object max) {
    return '연결 안 함 (0/$max)';
  }

  @override
  String lorebookConnectConfirmButton(Object count, Object max) {
    return '연결하기 ($count/$max)';
  }

  @override
  String get lorebookDetailDeletedMessage => '삭제된 로어북이에요';

  @override
  String get lorebookInfoTabLabel => '로어 정보';

  @override
  String get lorebookLinkedPlotsTabLabel => '연결 플롯';

  @override
  String get lorebookPlotConnectTabLabel => '플롯 연결';

  @override
  String get lorebookDetailEditMenuItem => '로어북 수정';

  @override
  String get lorebookDetailNoEntriesMessage => '작성된 항목이 없어요';

  @override
  String get lorebookDetailNoLinkedPlotsMessage => '연결된 플롯이 없어요';

  @override
  String get lorebookEditAppBarTitle => '로어북';

  @override
  String get lorebookEditSaveButtonCreate => '등록';

  @override
  String get lorebookEditSaveFirstMessage => '로어북을 먼저 등록하면 플롯을 연결할 수 있어요.';

  @override
  String get lorebookEditIntroDescription =>
      '소개글은 AI에게 전달되지 않아요.\n로어북을 관리하는 용도로 활용하세요.';

  @override
  String get lorebookEditTitleFieldLabel => '로어북 제목';

  @override
  String get lorebookEditEntriesSectionTitle => '항목';

  @override
  String get lorebookEditAddEntryButton => '항목 추가';

  @override
  String lorebookEditEntryCardTitle(Object index) {
    return '항목 $index';
  }

  @override
  String get lorebookEditEntryTitleHint => '제목을 입력하세요';

  @override
  String get lorebookEditKeywordsLabel => '키워드';

  @override
  String get lorebookEditKeywordsHint =>
      '키워드를 쉼표(,)로 구분해서 입력해주세요.\n입력한 키워드가 언급되면 아래 작성한 내용이 AI에게 전달돼요.';

  @override
  String get lorebookEditContentLabel => '내용';

  @override
  String get lorebookEditContentHint => '키워드 언급 시 AI에게 전달할 내용을 입력해 주세요.';

  @override
  String get lorebookEditConnectPlotsTitle => '플롯을 연결해 주세요';

  @override
  String get lorebookEditConnectPlotsDescription =>
      '플롯을 연결하면 키워드가 언급될 때마다\n로어북의 세계관이 AI에게 전달돼요';

  @override
  String lorebookConnectButtonWithCount(Object count) {
    return '연결하기 ($count)';
  }

  @override
  String get profileEditNameDescription => '캐릭터가 날 이렇게 불러 거예요';

  @override
  String get profileEditDescriptionLabel => '설명(선택)';

  @override
  String get profileEditDefaultSectionTitle => '기본 대화 프로필';

  @override
  String get profileEditApplyDefaultTitle => '새로운 대화 시작할 때 이 프로필 적용하기';

  @override
  String get profileEditApplyDefaultDescription => '대화 중에 다른 프로필로 바꿀 수 있어요';

  @override
  String get resumeNoSavedConversations => '저장된 대화가 없어요';

  @override
  String get resumeJustNow => '방금 전';

  @override
  String resumeMinutesAgo(Object count) {
    return '$count분 전';
  }

  @override
  String resumeHoursAgo(Object count) {
    return '$count시간 전';
  }

  @override
  String resumeDaysAgo(Object count) {
    return '$count일 전';
  }

  @override
  String resumeSavedAtLabel(Object date) {
    return '$date에 저장된 대화';
  }

  @override
  String get resumeNoSavedMessage => '저장된 메시지가 없어요';

  @override
  String get tokenUsageTitle => '토큰 사용 내역';

  @override
  String get tokenUsageDeleteAllButton => '전체 삭제';

  @override
  String get tokenUsageDeleteAllConfirmTitle => '내역을 전부 삭제할까요?';

  @override
  String get tokenUsageDeleteAllConfirmContent => '삭제하면 되돌릴 수 없어요.';

  @override
  String get tokenUsageEmptyMessage => '아직 사용 내역이 없어요';

  @override
  String tokenUsageProviderLabel(Object provider, Object presetName) {
    return '제공자: $provider · $presetName';
  }

  @override
  String tokenUsageBreakdown(Object prompt, Object completion, Object total) {
    return '입력 $prompt · 출력 $completion · 합계 $total';
  }

  @override
  String get startFreshDialogTitle => '대화를 새로 시작할까요?';

  @override
  String get startFreshDialogDescription =>
      '저장한 대화는 \'이어하기\'에서\n언제든 다시 할 수 있어요';

  @override
  String get startFreshDialogSaveCheckbox => '현재 대화 저장하기';

  @override
  String get startFreshFromHereDialogTitle => '여기서부터 새로 시작할까요?';

  @override
  String get startFreshFromHereDialogDescription =>
      '기존 대화는 \'이어하기\'에서\n언제든 다시 할 수 있어요';

  @override
  String get systemPromptButtonLabel => '시스템 프롬프트 설정';

  @override
  String get systemPromptWarning =>
      '꼭 필요한 경우에만 수정해 주세요. 잘못 수정하면 AI 응답이 이상해질 수 있어요.';

  @override
  String get systemPromptPlaceholderHintTitle => '사용 가능한 자리표시자';

  @override
  String get systemPromptPlaceholderHintBody =>
      '다음 이름을 중괄호 두 겹으로 감싸서 쓰면 실제 값으로 자동 치환돼요: plot_title, plot_description, characters_block, example_character_name, user_profile_name, lore_block, extra_block\n단, user는 AI가 응답에 그대로 남겨야 하는 토큰이니 지우지 마세요.';

  @override
  String get systemPromptResetButton => '기본값으로 되돌리기';

  @override
  String get systemPromptResetConfirmTitle => '기본값으로 되돌릴까요?';

  @override
  String get systemPromptResetConfirmContent =>
      '지금 수정한 내용은 사라지고 기본 시스템 프롬프트로 돌아가요.';

  @override
  String get systemPromptSavedMessage => '저장했어요.';

  @override
  String get systemPromptResetDoneMessage => '기본값으로 되돌렸어요.';

  @override
  String get snapshotSettingsTitle => '스냅샷 설정';

  @override
  String get snapshotSettingsDescription =>
      '채팅에서 스냅샷을 누르면 지금 상황을 AI가 요약해서, 아래 설정한 엔드포인트로 이미지를 생성해요.';

  @override
  String get snapshotSettingsProviderLabel => '이미지 생성 엔드포인트';

  @override
  String get snapshotSettingsApiKeyLabel => 'API 키';

  @override
  String get snapshotSettingsApiKeyHint => '선택한 엔드포인트의 API 키를 입력해주세요';

  @override
  String get snapshotSettingsModelNameLabel => '이미지 모델명';

  @override
  String get snapshotSettingsModelNameHint =>
      '예: google/gemini-2.5-flash-image';

  @override
  String get snapshotSettingsSaveButton => '저장하기';

  @override
  String get snapshotSettingsSavedMessage => '저장했어요.';
}
