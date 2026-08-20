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
  String get myPageLocalLlmButton => '로컬 LLM';

  @override
  String get localLlmScreenTitle => '로컬 LLM';

  @override
  String get localLlmScreenDescription =>
      '인터넷 연결 없이 기기에서 직접 AI 모델을 돌려요. 응답 속도와 품질은 기기 사양과 모델 크기에 따라 달라져요.';

  @override
  String get localLlmRecommendedSectionTitle => '추천 모델';

  @override
  String get localLlmModelDescHuihuiQwen3508b => 'IQ4 XS임 성능 기대 ㄴㄴ';

  @override
  String get localLlmModelDescHuihuiQwen354b => '속도와 품질의 균형. 한국어 대응이 비교적 좋음.';

  @override
  String get localLlmModelDescHuihuiGemma4E2b => '가장 가볍고 빠름. 저사양 기기에 적합.';

  @override
  String get localLlmModelDescHuihuiGemma4E4b => '더 나은 품질. 고사양 기기/PC 권장.';

  @override
  String get localLlmImportSectionTitle => '내 파일에서 가져오기';

  @override
  String get localLlmSavedPresetsSectionTitle => '저장된 로컬 프리셋';

  @override
  String get localLlmCacheSectionTitle => '다운로드된 모델 관리';

  @override
  String get localLlmCurrentStatusLabel => '현재 로드된 모델';

  @override
  String get localLlmNoModelLoaded => '로드된 모델 없음';

  @override
  String get localLlmUnloadButton => '언로드';

  @override
  String get localLlmUseButton => '사용';

  @override
  String get localLlmLoadButton => '불러오기';

  @override
  String get localLlmInUseLabel => '사용 중';

  @override
  String get localLlmImportButton => 'GGUF 파일 선택';

  @override
  String get localLlmImportDescription => '직접 받아둔 .gguf 모델 파일을 선택해서 쓸 수 있어요.';

  @override
  String get localLlmNoSavedPresets => '아직 저장된 로컬 프리셋이 없어요.';

  @override
  String get localLlmNoCachedModels => '다운로드된 모델이 없어요.';

  @override
  String get localLlmPresetDescription => '기기에 내장된 로컬 모델';

  @override
  String localLlmLoadSuccessMessage(Object modelName) {
    return '$modelName 모델을 불러왔어요.';
  }

  @override
  String localLlmLoadFailureMessage(Object error) {
    return '모델을 불러오지 못했어요: $error';
  }

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
  String get preferencesAiSectionTitle => 'AI 설정';

  @override
  String get preferencesThemeSectionTitle => '테마';

  @override
  String get preferencesThemeDarkOption => '다크';

  @override
  String get preferencesThemeLightOption => '화이트';

  @override
  String get preferencesThemeAmoledOption => 'AMOLED 블랙';

  @override
  String get preferencesThemeSystemOption => '시스템 자동';

  @override
  String get paletteAddButton => '프리셋 추가';

  @override
  String get paletteDeleteConfirmTitle => '프리셋 삭제';

  @override
  String paletteDeleteConfirmContent(String name) {
    return '\'$name\' 프리셋을 삭제할까요? 이 작업은 되돌릴 수 없어요.';
  }

  @override
  String get paletteEditNewTitle => '프리셋 추가';

  @override
  String get paletteEditEditTitle => '프리셋 편집';

  @override
  String get paletteEditNameEmptyMessage => '프리셋 이름을 입력해주세요.';

  @override
  String get paletteEditPreviewLabel => '미리보기';

  @override
  String get paletteEditNameLabel => '프리셋 이름';

  @override
  String get paletteEditColorsLabel => '색상';

  @override
  String get paletteEditBrightnessLabel => '밝기';

  @override
  String get paletteEditBrightnessDark => '다크';

  @override
  String get paletteEditBrightnessLight => '라이트';

  @override
  String get paletteSlotBackground => '배경';

  @override
  String get paletteSlotSurface => '카드/표면';

  @override
  String get paletteSlotSurfaceAlt => '보조 표면(입력창 등)';

  @override
  String get paletteSlotBorder => '테두리';

  @override
  String get paletteSlotPrimary => '포인트 색상';

  @override
  String get paletteSlotOnPrimary => '포인트 위 텍스트';

  @override
  String get paletteSlotTextPrimary => '본문 텍스트';

  @override
  String get paletteSlotTextSecondary => '보조 텍스트';

  @override
  String get paletteSlotTextMuted => '흐린 텍스트';

  @override
  String get paletteSlotTextFaint => '더 흐린 텍스트';

  @override
  String get paletteSlotTextGhost => '가장 흐린 텍스트';

  @override
  String get colorPickerTitle => '색상 선택';

  @override
  String get colorPickerHexLabel => '헥스코드';

  @override
  String get colorPickerAlphaLabel => '투명도';

  @override
  String get colorPickerQuickPicksLabel => '빠른 선택';

  @override
  String get preferencesVersionSectionTitle => '버전 정보';

  @override
  String preferencesCurrentVersionLabel(String version) {
    return '현재 버전 $version';
  }

  @override
  String get preferencesCheckUpdateButton => '업데이트 확인';

  @override
  String preferencesUpdateAvailableMessage(String version) {
    return '새 버전 $version이(가) 있어요.';
  }

  @override
  String get preferencesUpToDateMessage => '최신 버전을 사용하고 있어요.';

  @override
  String get preferencesUpdateCheckFailedMessage => '업데이트 확인에 실패했어요.';

  @override
  String get preferencesViewReleaseButton => '릴리스 보기';

  @override
  String get preferencesDangerZoneTitle => '위험 구역';

  @override
  String get preferencesResetAllDescription =>
      '플롯/캐릭터/대화/로어북/프리셋/이미지 등 이 기기에 저장된 모든 데이터를 지우고 앱을 처음 설치했을 때 상태로 되돌려요. 다운로드해둔 로컬 LLM 모델 파일은 지우지 않아요. 이 작업은 되돌릴 수 없어요.';

  @override
  String get preferencesResetAllButton => '전체 초기화';

  @override
  String get preferencesResetConfirmContent =>
      '모든 데이터가 영구적으로 삭제돼요. 미리 백업해두지 않았다면 계속하기 전에 마이페이지에서 \'전체 저장\'을 먼저 해주세요.';

  @override
  String get preferencesResetConfirmWord => '초기화';

  @override
  String preferencesResetTypeToConfirm(Object word) {
    return '계속하려면 아래에 \"$word\"를 입력해주세요.';
  }

  @override
  String get preferencesResetSuccessMessage => '모든 데이터를 초기화했어요.';

  @override
  String preferencesResetFailureMessage(Object error) {
    return '초기화에 실패했어요: $error';
  }

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
  String get homeTabFilterRecommended => '추천';

  @override
  String get homeNoPlotsYet => '아직 만든 플롯이 없어요';

  @override
  String get conversationTabTitle => '대화';

  @override
  String get conversationTabEmpty => '아직 진행 중인 대화가 없어요';

  @override
  String conversationTabSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get conversationTabDeleteConfirmTitle => '대화방 삭제';

  @override
  String get conversationTabDeleteConfirmContent =>
      '선택한 대화방을 삭제할까요? 되돌릴 수 없어요.';

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
  String get createTabImportFromPlotDataTitle => '전용 형식(.mzplot)에서 가져오기';

  @override
  String get createTabImportFromPlotDataSubtitle =>
      '이미지를 포함한 플롯 전체 데이터를 불러와요(대화 기록 제외)';

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
  String get createTabPlotTypeFilterAll => '전체';

  @override
  String get createTabPlotTypeFilterStoryChat => '스토리챗';

  @override
  String get createTabPlotTypeFilterVisualNovel => '비주얼 노벨';

  @override
  String get createTabPlotTypeChooserTitle => '플롯';

  @override
  String get createTabPlotTypeStoryChatTitle => '스토리챗';

  @override
  String get createTabPlotTypeStoryChatSubtitle => '말풍선 형태로 대화하는 롤플레이';

  @override
  String get createTabPlotTypeVisualNovelTitle => '비주얼 노벨';

  @override
  String get createTabPlotTypeVisualNovelSubtitle => '배경/캐릭터 일러스트와 함께 진행하는 이야기';

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
  String get chatReasoningInProgressLabel => '생각하는 중...';

  @override
  String chatGenerateFailureMessage(Object error) {
    return 'AI 응답 생성에 실패했어요: $error';
  }

  @override
  String get chatGeneratingIndicator => '답변 생성 중...';

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
  String get chatDrawerMemoryTitle => '기억 보기';

  @override
  String get chatMemorySheetTitle => '이전 대화 요약';

  @override
  String get chatMemoryEmptyMessage => '아직 요약된 기억이 없어요. 대화가 길어지면 자동으로 만들어져요.';

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
  String get characterDetailIntroNarratorLabel => '내레이션';

  @override
  String get characterDetailIntroUserLabel => '나';

  @override
  String get characterDetailIntroImageLabel => '이미지';

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
  String get plotEditExportDataMenuItem => '전용 형식으로 내보내기 (전체 데이터)';

  @override
  String get plotEditSaveButtonEdit => '수정';

  @override
  String get plotEditSaveButtonCreate => '제작';

  @override
  String get plotEditExportSuccessMessage => 'SillyTavern 카드로 내보냈어요.';

  @override
  String get plotEditExportDataSuccessMessage => '전용 형식(.mzplot)으로 내보냈어요.';

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
  String plotEditLorebookConnectButton(Object linked) {
    return '로어북 연결 ($linked개)';
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
  String get plotEditIntroAiGenerateButton => 'AI로 생성';

  @override
  String get plotEditIntroFirstSceneTitle => '첫 상황을 만들어 주세요';

  @override
  String get plotEditIntroEmptyMessage =>
      '아직 작성된 인트로가 없어요. 아래 입력창에서 첫 줄을 추가해보세요.';

  @override
  String get plotEditProfileMarkerLabel => '대화 프로필 선택 시점';

  @override
  String get plotProfileSectionTitle => '플레이하는 유저가 사용할 대화 프로필을 만들어 주세요';

  @override
  String get plotProfileSectionDescription =>
      '이 플롯에서만 쓰는 전용 프로필이에요. 개수 제한은 없어요.';

  @override
  String get plotProfileSavePlotFirst =>
      '플롯을 먼저 저장하면 대화 프로필을 만들 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.';

  @override
  String get plotProfileAddButton => '대화 프로필 추가';

  @override
  String get plotProfileUseGlobalNameLabel => '플레이하는 유저 이름 사용하기';

  @override
  String plotProfileUseGlobalNameDescription(String name) {
    return '체크하면 마이페이지 기본 프로필 이름($name)을 그대로 가져와요';
  }

  @override
  String get plotProfileShortIntroLabel => '짧은 소개';

  @override
  String get plotProfileShortIntroDescription =>
      '카드에 표시되는 한 줄 소개예요. AI에게는 전달되지 않아요.';

  @override
  String get plotProfileDescriptionLabel => '설명';

  @override
  String get plotProfileDescriptionHint =>
      '캐릭터를 만들 때처럼 구체적인 설명을 써주시면 좋아요.\n예) 18살, 키 181cm, 잘생긴 얼굴과 1등을 놓치지 않는 성적으로 모두에게 인기있는 모범생';

  @override
  String get plotProfilePickerTitle => '프로필을 선택하세요';

  @override
  String get plotProfilePickerSwipeHint => '옆으로 넘겨서 다른 프로필 보기';

  @override
  String get plotProfilePickerSelectButton => '선택';

  @override
  String get plotProfilePickerListTitle => '프로필을 선택하세요';

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
  String get plotEditCoverImagePlaceholder => '커버 이미지';

  @override
  String get plotEditShortIntroLabel => '짧은 소개';

  @override
  String get plotEditShortIntroHint => '제목과 함께 보일 짧은 소개를 입력해주세요';

  @override
  String get plotEditHashtagsLabel => '해시태그';

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
  String get aiPresetApiKeyGuideButton => '키 발급 안내';

  @override
  String get apiKeyGuideDialogTitle => 'API 키 발급 안내';

  @override
  String get apiKeyGuideOpenButton => '바로가기';

  @override
  String get apiKeyGuideOpenRouterDescription =>
      '다양한 모델을 하나의 API 키로 쓸 수 있는 라우터 서비스예요.';

  @override
  String get apiKeyGuideFeatherlessDescription =>
      '오픈소스 모델을 정액제로 무제한에 가깝게 쓸 수 있는 서비스예요.';

  @override
  String get apiKeyGuideFeatherlessReferralNote =>
      '이 링크로 가입하면 첫 달 10달러 할인 혜택을 받아요.';

  @override
  String get apiKeyGuideAtlasCloudDescription => '여러 모델을 종량제로 제공하는 서비스예요.';

  @override
  String get apiKeyGuideAtlasCloudReferralNote => '이 링크로 가입하면 5달러를 추가로 충전해줘요.';

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
  String get aiPresetReasoningEffortLabel => '추론 노력(Reasoning effort)';

  @override
  String get aiPresetReasoningEffortDescription =>
      '추론 모델에게 답하기 전 얼마나 깊게 생각할지 지정해요. 로컬 모델은 사고 모드가 켜지고, 원격 모델은 지원하는 경우에만 적용돼요.';

  @override
  String get aiPresetReasoningEffortOff => '끔';

  @override
  String get aiPresetReasoningEffortLow => '낮음';

  @override
  String get aiPresetReasoningEffortMedium => '보통';

  @override
  String get aiPresetReasoningEffortHigh => '높음';

  @override
  String get aiPresetEndpointFormatLabel => '엔드포인트 형식';

  @override
  String get aiPresetEndpointFormatDescription => '선택한 형식에 맞는 요청/응답 파서로 통신해요.';

  @override
  String get aiPresetEndpointFormatOpenAi => 'OpenAI 호환';

  @override
  String get aiPresetEndpointFormatAnthropic => 'Anthropic';

  @override
  String get aiPresetSupportsVisionLabel => '이미지 인식(비전) 지원';

  @override
  String get aiPresetSupportsVisionDescription =>
      '켜두면 ZedTalk에서 첨부한 이미지를 이 프리셋의 모델에게 함께 보내요. 실제로 이미지를 이해하는 모델일 때만 켜주세요.';

  @override
  String get aiPresetOpenRouterSectionTitle => 'OpenRouter 전용 옵션';

  @override
  String get aiPresetOpenRouterSectionDescription =>
      'Base URL이 openrouter.ai일 때만 적용돼요.';

  @override
  String get aiPresetOpenRouterZdrOnlyLabel => 'ZDR 제공자만 사용';

  @override
  String get aiPresetOpenRouterZdrOnlyDescription =>
      '데이터를 저장하지 않는(Zero Data Retention) 제공자로만 라우팅해요.';

  @override
  String get aiPresetOpenRouterExcludeChinaLabel => '중국 제공자 제외';

  @override
  String get aiPresetOpenRouterExcludeChinaDescription =>
      '알리바바 등 중국 소재 제공자는 라우팅에서 제외해요.';

  @override
  String get aiPresetOpenRouterExcludeTrainingLabel => '데이터 학습 제공자 제외';

  @override
  String get aiPresetOpenRouterExcludeTrainingDescription =>
      '요청 데이터를 학습에 활용할 수 있는 제공자는 제외해요.';

  @override
  String get lorebookConnectTitle => '로어북 연결';

  @override
  String get lorebookConnectNoneButton => '연결 안 함';

  @override
  String lorebookConnectConfirmButton(Object count) {
    return '연결하기 ($count개)';
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
  String get profileEditScopeSectionTitle => '적용 범위';

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

  @override
  String get createTabAiGenerateButton => 'AI로 생성';

  @override
  String get plotAiGenerateTitle => 'AI로 플롯 생성';

  @override
  String get plotAiGeneratePresetLabel => '사용할 AI 프리셋';

  @override
  String get plotAiGeneratePresetEmptyHint =>
      '먼저 환경설정 > AI 설정에서 AI 프리셋을 만들어주세요.';

  @override
  String get plotAiGeneratePromptLabel => '어떤 플롯을 만들까요?';

  @override
  String get plotAiGeneratePromptHint => '장르, 배경, 등장인물 특징 등을 자유롭게 설명해주세요';

  @override
  String get plotAiGenerateWebSearchLabel => '웹 검색으로 참고자료 찾기';

  @override
  String get plotAiGenerateWebSearchUnsupportedHint =>
      '선택한 프리셋에서는 네이티브 웹 검색을 지원하지 않아요(OpenRouter 또는 OpenAI 계열만 가능).';

  @override
  String get plotAiGenerateLoreLengthLabel => '로어 길이';

  @override
  String get plotAiGenerateLoreLengthShort => '짧게';

  @override
  String get plotAiGenerateLoreLengthMedium => '보통';

  @override
  String get plotAiGenerateLoreLengthLong => '길게';

  @override
  String get plotAiGenerateAccuracyLabel => '정확도';

  @override
  String get plotAiGenerateAccuracyAccurate => '정확함(Accurate)';

  @override
  String get plotAiGenerateAccuracyMixed => '혼합(Mixed)';

  @override
  String get plotAiGenerateSubmitButton => '생성하기';

  @override
  String get plotAiGeneratePromptEmptyMessage => '어떤 플롯을 만들지 먼저 설명해주세요.';

  @override
  String plotAiGenerateFailureMessage(Object error) {
    return '플롯 생성에 실패했어요: $error';
  }

  @override
  String get plotAiGenerateGeneratingMessage => 'AI가 플롯을 만들고 있어요...';

  @override
  String get lanSyncSectionTitle => 'LAN 동기화';

  @override
  String get lanSyncScreenTitle => 'LAN 동기화';

  @override
  String get lanSyncExportSectionTitle => '이 기기에서 내보내기';

  @override
  String get lanSyncExportSectionDescription =>
      '같은 Wi-Fi/LAN에 연결된 다른 기기에서 아래 정보로 접속하면 전체 데이터를 가져갈 수 있어요.';

  @override
  String get lanSyncStartHostButton => '연결 대기 시작';

  @override
  String get lanSyncStopHostButton => '중지';

  @override
  String get lanSyncWaitingMessage => '다른 기기의 접속을 기다리는 중...';

  @override
  String get lanSyncAddressLabel => '주소';

  @override
  String get lanSyncPortLabel => '포트';

  @override
  String get lanSyncPinLabel => 'PIN';

  @override
  String get lanSyncExportedMessage => '전송을 완료했어요.';

  @override
  String lanSyncExportFailedMessage(Object error) {
    return '전송에 실패했어요: $error';
  }

  @override
  String get lanSyncNoAddressWarning =>
      '이 기기에서 LAN 주소를 찾지 못했어요. Wi-Fi 연결을 확인해주세요.';

  @override
  String get lanSyncImportSectionTitle => '다른 기기에서 가져오기';

  @override
  String get lanSyncImportSectionDescription =>
      '내보내는 쪽 화면에 표시된 주소/포트/PIN을 입력해주세요.';

  @override
  String get lanSyncHostFieldLabel => '주소(IP)';

  @override
  String get lanSyncPortFieldLabel => '포트';

  @override
  String get lanSyncPinFieldLabel => 'PIN';

  @override
  String get lanSyncImportButton => '가져오기';

  @override
  String get lanSyncImportConfirmTitle => '전체 데이터 교체';

  @override
  String get lanSyncImportConfirmContent =>
      '받아온 데이터로 이 기기의 전체 데이터를 덮어써요. 되돌릴 수 없어요.';

  @override
  String lanSyncImportFailedMessage(Object error) {
    return '가져오기에 실패했어요: $error';
  }

  @override
  String createTabSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get createTabDeleteSelectedConfirmTitle => '플롯 삭제';

  @override
  String get createTabDeleteSelectedConfirmContent =>
      '선택한 플롯을 삭제할까요? 되돌릴 수 없어요.';

  @override
  String get createTabExportPackageButton => '패키지로 내보내기(.mzpack)';

  @override
  String createTabExportPackageSuccessMessage(int count) {
    return '$count개 플롯을 내보냈어요.';
  }

  @override
  String createTabExportPackageFailureMessage(Object error) {
    return '내보내기에 실패했어요: $error';
  }

  @override
  String get createTabImportFromPackageTitle => '플롯 패키지에서 가져오기(.mzpack)';

  @override
  String get createTabImportFromPackageSubtitle => '여러 플롯을 한 번에 불러와요';

  @override
  String createTabImportPackageSuccessMessage(int count) {
    return '$count개 플롯을 가져왔어요.';
  }

  @override
  String get conversationTabTalkLabel => '톡';

  @override
  String get characterDetailTalkButton => 'ZedTalk';

  @override
  String get talkListEmpty => '아직 톡한 캐릭터가 없어요';

  @override
  String get talkAttachmentSheetTitle => '첨부';

  @override
  String get talkAttachmentImageOption => '이미지';

  @override
  String get talkAttachmentVideoOption => '동영상';

  @override
  String get talkAttachmentDocumentOption => '문서';

  @override
  String get talkVisionUnsupportedNote =>
      '이 프리셋은 이미지 인식을 지원하지 않아서, 첨부한 이미지는 AI에게 전달되지 않아요.';

  @override
  String get talkPresetSheetTitle => '사용할 AI 프리셋';

  @override
  String get talkNoPresetMessage => '먼저 AI 프리셋을 골라주세요.';

  @override
  String get talkDeleteConfirmTitle => '톡 삭제';

  @override
  String get talkDeleteConfirmContent => '선택한 톡을 삭제할까요? 되돌릴 수 없어요.';

  @override
  String get talkCharacterPickerTitle => '대화할 캐릭터를 선택하세요';

  @override
  String get talkDrawerStartFreshTitle => '새로 시작';

  @override
  String get talkDrawerStartFreshSubtitle => '새 톡방을 만들어요';

  @override
  String get talkDrawerResumeTitle => '다른 톡방 보기';

  @override
  String get talkDrawerDeleteTitle => '톡방 삭제';

  @override
  String get talkDrawerProfileTitle => '대화 프로필';

  @override
  String get talkDrawerChoicesTitle => '선택지';

  @override
  String get talkDrawerExitButton => '톡방 나가기';

  @override
  String get talkResumeSheetTitle => '다른 톡방';

  @override
  String get talkResumeSheetEmpty => '이 플롯의 다른 톡방이 없어요';

  @override
  String get talkSheetStartFreshFromHere => '여기서 새로 시작';

  @override
  String get talkEditMessageTitle => '메시지 수정';

  @override
  String get lorebookImportButtonTooltip =>
      '가져오기 (SillyTavern World Info / JanitorAI)';

  @override
  String get lorebookExportButtonTooltip => 'SillyTavern World Info로 내보내기';

  @override
  String lorebookImportSuccessMessage(Object count) {
    return '$count개 항목을 불러왔어요. 저장을 눌러야 실제로 반영돼요.';
  }

  @override
  String lorebookImportFailureMessage(Object error) {
    return '가져오기에 실패했어요: $error';
  }

  @override
  String get lorebookExportSuccessMessage => 'World Info JSON으로 내보냈어요.';

  @override
  String lorebookExportFailureMessage(Object error) {
    return '내보내기에 실패했어요: $error';
  }

  @override
  String get createTabImportTargetSheetTitle => '가져올 위치를 선택하세요';

  @override
  String get createTabImportTargetNewPlot => '새 플롯으로 만들기';

  @override
  String get createTabImportLorebookTargetSheetTitle => '로어북을 어떻게 추가할까요?';

  @override
  String get createTabImportLorebookTargetNew => '새 로어북 만들기';

  @override
  String get myPageSummarySettingsButton => '요약(장기 기억) 설정';

  @override
  String get summarySettingsTitle => '요약(장기 기억) 설정';

  @override
  String get summarySettingsDescription =>
      'AI 프리셋에 컨텍스트 길이(최근 메시지 개수 상한)를 설정해두면, 그 범위를 벗어나는 오래된 대화를 자동으로 요약해서 시스템 프롬프트에 함께 실어요. 여기서 이 기능을 끄거나, 요약 프롬프트/사용할 프리셋을 직접 고를 수 있어요.';

  @override
  String get summarySettingsEnabledLabel => '장기 기억 요약 사용';

  @override
  String get summarySettingsPromptLabel => '요약 프롬프트';

  @override
  String get summarySettingsPromptHint => '비워두면 기본 프롬프트를 사용해요';

  @override
  String get summarySettingsPresetLabel => '요약에 사용할 프리셋';

  @override
  String get summarySettingsPresetDefaultOption => '채팅과 동일한 프리셋 사용';

  @override
  String get summarySettingsSaveButton => '저장';

  @override
  String get summarySettingsSavedMessage => '저장했어요.';

  @override
  String get vnEditAppBarTitleCreate => '비주얼 노벨 만들기';

  @override
  String get vnEditAppBarTitleEdit => '비주얼 노벨 편집';

  @override
  String get vnEditSaveButtonCreate => '제작';

  @override
  String get vnEditSaveButtonEdit => '수정';

  @override
  String get vnEditSavedMessage => '저장했어요';

  @override
  String get vnEditTitleRequiredMessage => '제목을 입력해주세요';

  @override
  String get vnEditTabContents => '콘텐츠';

  @override
  String get vnEditTabInfo => '소개';

  @override
  String get vnEditTabPlaySettings => '플레이 설정';

  @override
  String get vnEditTitleFieldLabel => '제목';

  @override
  String get vnEditTitleFieldHint => '플롯의 제목을 입력해주세요';

  @override
  String vnEditCharCountLabel(int count) {
    return '$count자';
  }

  @override
  String get vnEditWorldviewLabel => '세계관';

  @override
  String get vnEditWorldviewHint => '나만의 독창적인 세계관을 직접 써주세요';

  @override
  String get vnEditHashtagsLabel => '해시태그';

  @override
  String vnEditHashtagAddButton(int count) {
    return '추가 $count/10';
  }

  @override
  String get vnEditAddHashtagDialogTitle => '해시태그 추가';

  @override
  String get vnEditHashtagHint => '# 없이 입력해주세요';

  @override
  String get vnEditCharactersSectionTitle => '등장인물';

  @override
  String get vnEditCharactersEmptyMessage => '플롯을 함께 이끌어갈 인물들을 추가해 주세요';

  @override
  String get vnEditAddCharacterButton => '새 인물 추가';

  @override
  String get vnEditPlayableSectionTitle => '플레이어블 캐릭터';

  @override
  String get vnEditPlayableEmptyMessage => '플레이어가 선택할 수 있는 플롯의 주인공을 만들어주세요';

  @override
  String get vnEditSelectExistingCharacterButton => '등장인물 중 선택';

  @override
  String get vnEditSelectExistingCharacterDialogTitle => '등장인물 중 선택';

  @override
  String get vnEditSelectExistingCharacterEmptyMessage => '선택할 수 있는 등장인물이 없어요';

  @override
  String get vnEditBackgroundsSectionTitle => '배경';

  @override
  String get vnEditBackgroundsEmptyMessage => '플롯의 몰입도를 높여줄 배경을 만들어 주세요';

  @override
  String get vnEditAddBackgroundButton => '새 배경 추가';

  @override
  String get vnEditAddBackgroundDialogTitle => '새 배경 추가';

  @override
  String get vnEditEditBackgroundDialogTitle => '배경 수정';

  @override
  String get vnEditBackgroundImageLabel => '배경 이미지';

  @override
  String get vnEditBackgroundTitleLabel => '제목';

  @override
  String get vnEditBackgroundTitleHint => '예) 학교 교실_낮';

  @override
  String get vnEditSavePlotFirstMessage => '제목과 세계관을 입력하고 상단의 저장 버튼을 눌러주세요';

  @override
  String get vnEditDeleteCharacterConfirmMessage =>
      '이 인물을 삭제할까요? 표정 이미지도 함께 삭제돼요.';

  @override
  String get vnEditDeleteBackgroundConfirmMessage => '이 배경을 삭제할까요?';

  @override
  String get vnEditCharacterFormTitleCreate => '새 인물';

  @override
  String get vnEditCharacterFormTitleEdit => '인물 수정';

  @override
  String get vnEditCharacterNameLabel => '이름';

  @override
  String get vnEditCharacterNameHint => '이름을 입력해 주세요';

  @override
  String get vnEditCharacterShortDescLabel => '짧은 설명';

  @override
  String get vnEditCharacterShortDescHint => '인물의 특징을 담은 짧은 소개를 적어 주세요';

  @override
  String get vnEditCharacterPersonaLabel => '인물 설명';

  @override
  String get vnEditCharacterPersonaHint =>
      '말투, 성격, 버릇처럼 AI가 인물을 표현할 때 참고할 특징을 적어 주세요';

  @override
  String get vnEditCharacterImageLabel => '인물 이미지';

  @override
  String get vnEditCharacterImagePlaceholder => '전신 이미지 추가';

  @override
  String get vnEditSpritePlacementSectionTitle => '인물 배치';

  @override
  String get vnEditSpritePlacementPreviewEmptyMessage =>
      '인물 이미지를 추가하면 미리볼 수 있어요';

  @override
  String vnEditSpriteScaleLabel(String scale) {
    return '크기 배율 ${scale}x';
  }

  @override
  String get vnEditSpriteOffsetXLabel => '가로 위치';

  @override
  String get vnEditSpriteOffsetYLabel => '세로 위치';

  @override
  String get vnEditExpressionSectionTitle => '표정 이미지 (선택)';

  @override
  String get vnEditExpressionSavePlotFirstMessage =>
      '먼저 인물을 저장하면 표정을 추가할 수 있어요';

  @override
  String get vnEditExpressionAddTile => '이미지 추가';

  @override
  String get vnEditExpressionJoy => '기쁨';

  @override
  String get vnEditExpressionSad => '슬픔';

  @override
  String get vnEditExpressionAngry => '분노';

  @override
  String get vnEditExpressionWorried => '걱정';

  @override
  String get vnEditExpressionSurprised => '놀람';

  @override
  String get vnEditExpressionConfused => '의문';

  @override
  String get vnEditExpressionDefault => '기본 이미지';

  @override
  String get vnEditCharacterPickEntryLabel => '플레이어블 캐릭터 선택';

  @override
  String get vnEditCharacterPickEntryHint =>
      '인트로 재생 중 이 위치에서 플레이어가 캐릭터를 고릅니다. 드래그로 순서만 바꿀 수 있어요.';

  @override
  String get vnEditIntroEmptyMessage => '아직 작성된 턴이 없어요. 아래 버튼으로 첫 턴을 추가해보세요.';

  @override
  String get vnEditAddTurnButton => '턴 추가하기';

  @override
  String get vnEditSceneTypeDialogue => '대화형';

  @override
  String get vnEditSceneTypeDirection => '연출형';

  @override
  String get vnEditSpeakerNarratorLabel => '내레이터';

  @override
  String get vnEditNoChangeLabel => '변화 없음';

  @override
  String get vnEditIntroContentHint => '내용을 입력해주세요';

  @override
  String get vnEditDirectionCaptionHint => '짧은 연출 문구를 입력해주세요';

  @override
  String vnEditChoicesSectionTitle(int count) {
    return '선택지 $count/4';
  }

  @override
  String get vnEditAddChoiceButton => '선택지 추가';

  @override
  String get vnEditChoiceContentHint => '선택지 내용을 입력해주세요';

  @override
  String get vnEditUseDiceLabel => '주사위 사용';

  @override
  String get vnEditDifficultyEasy => '쉬움';

  @override
  String get vnEditDifficultyMedium => '중간';

  @override
  String get vnEditDifficultyHard => '어려움';

  @override
  String get vnEditCoverTitle => '커버';

  @override
  String get vnEditCoverImagePlaceholder => '커버 이미지';

  @override
  String get vnEditShortIntroLabel => '짧은 소개';

  @override
  String get vnEditShortIntroHint => '제목과 함께 보일 짧은 소개를 입력해주세요';

  @override
  String get vnEditPlaySettingsSectionTitle => '플레이 방식';

  @override
  String get vnEditInputModeLabel => '기본 입력 방식';

  @override
  String get vnEditInputModeChoice => '선택지';

  @override
  String get vnEditInputModeFreeText => '직접 입력';

  @override
  String get vnEditInputModeChoiceDescription => '미리 준비된 선택지 중 하나를 골라 답변해요';

  @override
  String get vnEditInputModeFreeTextDescription => '플레이어가 직접 답변을 입력해요';

  @override
  String get vnEditAiAssistLabel => 'AI 입력 어시스트';

  @override
  String get vnEditAiAssistDescription =>
      'AI가 플레이어의 입력을 다듬어 주고, 플레이어블 캐릭터 이미지를 함께 표시해요.';

  @override
  String get vnEditDiceEventLabel => '주사위 이벤트';

  @override
  String get vnEditDiceEventDescription =>
      '중요한 순간에 플레이어가 직접 주사위를 굴려요.\n결과에 따라 성공 여부가 결정돼요.';

  @override
  String get vnPlayAddPlayableCharacterCardTitle => '새 플레이어블\n캐릭터';

  @override
  String get vnPlayAiAssistTooltip => 'AI 입력 도움받기';

  @override
  String get vnPlayBackToChoicesButton => '선택지로 돌아가기';

  @override
  String get vnPlayBackTooltip => '뒤로';

  @override
  String get vnPlayCancelGenerationTooltip => '생성 중지';

  @override
  String get vnPlayCharacterPickerTitle => '플레이할 캐릭터를 선택해주세요';

  @override
  String get vnPlayDefaultCharacterName => '캐릭터';

  @override
  String get vnPlayDeleteSessionConfirmMessage => '이 대화를 삭제할까요? 되돌릴 수 없어요.';

  @override
  String get vnPlayDeleteSessionMenuItem => '삭제';

  @override
  String get vnPlayDiceBonusLabel => '보너스';

  @override
  String get vnPlayDiceConfirmButton => '확인';

  @override
  String get vnPlayDiceGoalLabel => '목표';

  @override
  String vnPlayDiceResultDetail(int roll, int bonus, int total, int target) {
    return '$roll + $bonus = $total / 목표 $target';
  }

  @override
  String get vnPlayDiceResultFailure => '실패...';

  @override
  String get vnPlayDiceResultSuccess => '성공!';

  @override
  String get vnPlayDiceRollButton => '운명의 주사위를 던진다';

  @override
  String get vnPlayDiceSheetTitle => '운명의 주사위';

  @override
  String get vnPlayDiceTargetLabel => '성공 기준';

  @override
  String get vnPlayEditCharacterTooltip => '캐릭터 수정';

  @override
  String get vnPlayEmptyStateMessage => '아직 이야기가 시작되지 않았어요';

  @override
  String get vnPlayFreeInputHint => '행동이나 대사를 입력하세요...';

  @override
  String vnPlayGenerateFailureMessage(Object error) {
    return '이야기를 만드는 데 실패했어요: $error';
  }

  @override
  String get vnPlayGeneratingIndicator => '이야기를 만드는 중...';

  @override
  String get vnPlayHistoryEmptyMessage => '아직 대화 기록이 없어요';

  @override
  String get vnPlayHistoryMenuItem => '히스토리 보기';

  @override
  String get vnPlayProfileMenuItem => '대화 프로필';

  @override
  String get vnPlayProfileSheetTitle => '대화 프로필 선택';

  @override
  String get vnPlayProfileSheetEmpty => '비주얼 노벨에서 쓸 수 있는 프로필이 없어요';

  @override
  String get vnPlayHistoryNarratorLabel => '내레이션';

  @override
  String get vnPlayHistoryCharacterPickLabel => '캐릭터 선택';

  @override
  String get vnPlayHistorySheetTitle => '대화 기록';

  @override
  String get vnPlayHistoryTooltip => '히스토리';

  @override
  String get vnPlayJumpToPlotDetailMenuItem => '플롯 상세페이지 바로가기';

  @override
  String get vnPlayManualInputToggle => '직접 입력';

  @override
  String get vnPlayPresetDropdownPlaceholder => '프리셋 선택';

  @override
  String get vnPlayPresetManageLink => '프리셋 설정';

  @override
  String get vnPlayPresetSheetDescription =>
      '선택한 프리셋의 설정으로 이야기가 진행돼요. 프리셋은 마이페이지에서 관리할 수 있어요.';

  @override
  String get vnPlayPresetSheetEmpty => '아직 만든 프리셋이 없어요';

  @override
  String get vnPlayPresetSheetTitle => 'AI 프리셋';

  @override
  String get vnPlayRegenerateSuggestionsTooltip => '다시 제안받기';

  @override
  String get vnPlaySelectCharacterButton => '선택';

  @override
  String get vnPlaySelectPresetMessage => 'AI 프리셋을 먼저 선택해주세요';

  @override
  String get vnPlaySessionLoadFailedMessage => '세션을 불러오지 못했어요';

  @override
  String get vnPlaySettingsSheetTitle => '설정';

  @override
  String get vnPlaySettingsTooltip => '설정';

  @override
  String get vnPlayStartFreshMenuItem => '새로하기';

  @override
  String get vnPlayStepBackTooltip => '이전';

  @override
  String get vnPlayStepForwardTooltip => '다음';

  @override
  String get vnPlaySuggestionEditTooltip => '수정';

  @override
  String get vnPlaySuggestionsEmptyMessage => '제안할 선택지가 없어요';

  @override
  String get vnPlaySuggestionsLoadingLabel => '다음 행동을 생각하는 중...';

  @override
  String get vnPlayUntitledPlotTitle => '제목 없음';
}
