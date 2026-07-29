import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'Microzed'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @commonCopy.
  ///
  /// In ko, this message translates to:
  /// **'복사'**
  String get commonCopy;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기본'**
  String get languageSystemDefault;

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @myPageTitle.
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get myPageTitle;

  /// No description provided for @myPageEditProfileButton.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필 편집'**
  String get myPageEditProfileButton;

  /// No description provided for @myPageAiPresetButton.
  ///
  /// In ko, this message translates to:
  /// **'AI 프리셋 설정'**
  String get myPageAiPresetButton;

  /// No description provided for @myPageTokensUsedLabel.
  ///
  /// In ko, this message translates to:
  /// **'소모된 토큰'**
  String get myPageTokensUsedLabel;

  /// No description provided for @myPageHistoryButton.
  ///
  /// In ko, this message translates to:
  /// **'내역'**
  String get myPageHistoryButton;

  /// No description provided for @myPageBackupSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업'**
  String get myPageBackupSectionTitle;

  /// No description provided for @myPageBackupSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'플롯/캐릭터/대화/로어북/프리셋 등 모든 데이터를 파일 하나로 저장하거나 불러올 수 있어요.'**
  String get myPageBackupSectionDescription;

  /// No description provided for @myPageExportAllButton.
  ///
  /// In ko, this message translates to:
  /// **'전체 저장'**
  String get myPageExportAllButton;

  /// No description provided for @myPageImportAllButton.
  ///
  /// In ko, this message translates to:
  /// **'전체 불러오기'**
  String get myPageImportAllButton;

  /// No description provided for @myPageExportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'전체 데이터를 저장했어요.'**
  String get myPageExportSuccessMessage;

  /// No description provided for @myPageExportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했어요: {error}'**
  String myPageExportFailureMessage(Object error);

  /// No description provided for @myPageImportDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'전체 불러오기'**
  String get myPageImportDialogTitle;

  /// No description provided for @myPageImportDialogContent.
  ///
  /// In ko, this message translates to:
  /// **'지금 앱에 있는 모든 플롯/캐릭터/대화/로어북/프리셋이 이 백업 내용으로 완전히 대체돼요.\n이 작업은 되돌릴 수 없어요. 계속할까요?'**
  String get myPageImportDialogContent;

  /// No description provided for @myPageImportRestoreButton.
  ///
  /// In ko, this message translates to:
  /// **'복원'**
  String get myPageImportRestoreButton;

  /// No description provided for @myPageImportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'복원 완료: 플롯 {plotCount}개, 대화 메시지 {chatMessageCount}개, 로어북 {lorebookCount}개'**
  String myPageImportSuccessMessage(
    Object plotCount,
    Object chatMessageCount,
    Object lorebookCount,
  );

  /// No description provided for @myPageImportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'불러오기에 실패했어요: {error}'**
  String myPageImportFailureMessage(Object error);

  /// No description provided for @myPageLicensesButton.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get myPageLicensesButton;

  /// No description provided for @myPageSourceCodeButton.
  ///
  /// In ko, this message translates to:
  /// **'GitHub 저장소'**
  String get myPageSourceCodeButton;

  /// No description provided for @myPageSnapshotSettingsButton.
  ///
  /// In ko, this message translates to:
  /// **'스냅샷 설정'**
  String get myPageSnapshotSettingsButton;

  /// No description provided for @myPageLocalLlmButton.
  ///
  /// In ko, this message translates to:
  /// **'로컬 LLM'**
  String get myPageLocalLlmButton;

  /// No description provided for @localLlmScreenTitle.
  ///
  /// In ko, this message translates to:
  /// **'로컬 LLM'**
  String get localLlmScreenTitle;

  /// No description provided for @localLlmScreenDescription.
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결 없이 기기에서 직접 AI 모델을 돌려요. 응답 속도와 품질은 기기 사양과 모델 크기에 따라 달라져요.'**
  String get localLlmScreenDescription;

  /// No description provided for @localLlmRecommendedSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'추천 모델'**
  String get localLlmRecommendedSectionTitle;

  /// No description provided for @localLlmImportSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 파일에서 가져오기'**
  String get localLlmImportSectionTitle;

  /// No description provided for @localLlmSavedPresetsSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'저장된 로컬 프리셋'**
  String get localLlmSavedPresetsSectionTitle;

  /// No description provided for @localLlmCacheSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'다운로드된 모델 관리'**
  String get localLlmCacheSectionTitle;

  /// No description provided for @localLlmCurrentStatusLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재 로드된 모델'**
  String get localLlmCurrentStatusLabel;

  /// No description provided for @localLlmNoModelLoaded.
  ///
  /// In ko, this message translates to:
  /// **'로드된 모델 없음'**
  String get localLlmNoModelLoaded;

  /// No description provided for @localLlmUnloadButton.
  ///
  /// In ko, this message translates to:
  /// **'언로드'**
  String get localLlmUnloadButton;

  /// No description provided for @localLlmUseButton.
  ///
  /// In ko, this message translates to:
  /// **'사용'**
  String get localLlmUseButton;

  /// No description provided for @localLlmLoadButton.
  ///
  /// In ko, this message translates to:
  /// **'불러오기'**
  String get localLlmLoadButton;

  /// No description provided for @localLlmInUseLabel.
  ///
  /// In ko, this message translates to:
  /// **'사용 중'**
  String get localLlmInUseLabel;

  /// No description provided for @localLlmImportButton.
  ///
  /// In ko, this message translates to:
  /// **'GGUF 파일 선택'**
  String get localLlmImportButton;

  /// No description provided for @localLlmImportDescription.
  ///
  /// In ko, this message translates to:
  /// **'직접 받아둔 .gguf 모델 파일을 선택해서 쓸 수 있어요.'**
  String get localLlmImportDescription;

  /// No description provided for @localLlmNoSavedPresets.
  ///
  /// In ko, this message translates to:
  /// **'아직 저장된 로컬 프리셋이 없어요.'**
  String get localLlmNoSavedPresets;

  /// No description provided for @localLlmNoCachedModels.
  ///
  /// In ko, this message translates to:
  /// **'다운로드된 모델이 없어요.'**
  String get localLlmNoCachedModels;

  /// No description provided for @localLlmPresetDescription.
  ///
  /// In ko, this message translates to:
  /// **'기기에 내장된 로컬 모델'**
  String get localLlmPresetDescription;

  /// No description provided for @localLlmLoadSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'{modelName} 모델을 불러왔어요.'**
  String localLlmLoadSuccessMessage(Object modelName);

  /// No description provided for @localLlmLoadFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'모델을 불러오지 못했어요: {error}'**
  String localLlmLoadFailureMessage(Object error);

  /// No description provided for @preferencesTitle.
  ///
  /// In ko, this message translates to:
  /// **'환경설정'**
  String get preferencesTitle;

  /// No description provided for @preferencesImageDisplayModeLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미지 표시 방식'**
  String get preferencesImageDisplayModeLabel;

  /// No description provided for @preferencesImageDisplayModeDescription.
  ///
  /// In ko, this message translates to:
  /// **'인트로/스냅샷 이미지를 채팅에서 어떻게 보여줄지 골라요.'**
  String get preferencesImageDisplayModeDescription;

  /// No description provided for @preferencesImageDisplaySquareOption.
  ///
  /// In ko, this message translates to:
  /// **'정사각형 (지금처럼)'**
  String get preferencesImageDisplaySquareOption;

  /// No description provided for @preferencesImageDisplayFullWidthOption.
  ///
  /// In ko, this message translates to:
  /// **'가로 꽉 채우기'**
  String get preferencesImageDisplayFullWidthOption;

  /// No description provided for @preferencesDangerZoneTitle.
  ///
  /// In ko, this message translates to:
  /// **'위험 구역'**
  String get preferencesDangerZoneTitle;

  /// No description provided for @preferencesResetAllDescription.
  ///
  /// In ko, this message translates to:
  /// **'플롯/캐릭터/대화/로어북/프리셋/이미지 등 이 기기에 저장된 모든 데이터를 지우고 앱을 처음 설치했을 때 상태로 되돌려요. 다운로드해둔 로컬 LLM 모델 파일은 지우지 않아요. 이 작업은 되돌릴 수 없어요.'**
  String get preferencesResetAllDescription;

  /// No description provided for @preferencesResetAllButton.
  ///
  /// In ko, this message translates to:
  /// **'전체 초기화'**
  String get preferencesResetAllButton;

  /// No description provided for @preferencesResetConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터가 영구적으로 삭제돼요. 미리 백업해두지 않았다면 계속하기 전에 마이페이지에서 \'전체 저장\'을 먼저 해주세요.'**
  String get preferencesResetConfirmContent;

  /// No description provided for @preferencesResetConfirmWord.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get preferencesResetConfirmWord;

  /// No description provided for @preferencesResetTypeToConfirm.
  ///
  /// In ko, this message translates to:
  /// **'계속하려면 아래에 \"{word}\"를 입력해주세요.'**
  String preferencesResetTypeToConfirm(Object word);

  /// No description provided for @preferencesResetSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터를 초기화했어요.'**
  String get preferencesResetSuccessMessage;

  /// No description provided for @preferencesResetFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'초기화에 실패했어요: {error}'**
  String preferencesResetFailureMessage(Object error);

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In ko, this message translates to:
  /// **'대화'**
  String get navChat;

  /// No description provided for @navCreate.
  ///
  /// In ko, this message translates to:
  /// **'제작'**
  String get navCreate;

  /// No description provided for @navMyPage.
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get navMyPage;

  /// No description provided for @commonNoSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없어요'**
  String get commonNoSearchResults;

  /// No description provided for @searchHintPlot.
  ///
  /// In ko, this message translates to:
  /// **'플롯 제목, 소개, 해시태그 검색'**
  String get searchHintPlot;

  /// No description provided for @searchHintLorebook.
  ///
  /// In ko, this message translates to:
  /// **'로어북 제목 검색'**
  String get searchHintLorebook;

  /// No description provided for @totalCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}개'**
  String totalCountLabel(Object count);

  /// No description provided for @conversationCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'대화량 {count}'**
  String conversationCountLabel(Object count);

  /// No description provided for @homeNoPlotsYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 만든 플롯이 없어요'**
  String get homeNoPlotsYet;

  /// No description provided for @conversationTabTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화'**
  String get conversationTabTitle;

  /// No description provided for @conversationTabEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 진행 중인 대화가 없어요'**
  String get conversationTabEmpty;

  /// No description provided for @conversationTabSortLatest.
  ///
  /// In ko, this message translates to:
  /// **'최신순'**
  String get conversationTabSortLatest;

  /// No description provided for @conversationTilePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'대화를 시작해보세요'**
  String get conversationTilePlaceholder;

  /// No description provided for @createTabPlotLabel.
  ///
  /// In ko, this message translates to:
  /// **'플롯'**
  String get createTabPlotLabel;

  /// No description provided for @createTabLorebookLabel.
  ///
  /// In ko, this message translates to:
  /// **'로어북'**
  String get createTabLorebookLabel;

  /// No description provided for @createTabNoLorebooksYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 만든 로어북이 없어요'**
  String get createTabNoLorebooksYet;

  /// No description provided for @createTabLorebookNote1.
  ///
  /// In ko, this message translates to:
  /// **'• 대화량은 해당 로어북이 연결된 플롯에서 생긴 대화의 총합이에요.'**
  String get createTabLorebookNote1;

  /// No description provided for @createTabLorebookNote2.
  ///
  /// In ko, this message translates to:
  /// **'• 로어북을 수정하거나 삭제하면 연결된 모든 플롯에 즉시 반영돼요. 변경하실 때 꼭 한 번 더 확인해주세요.'**
  String get createTabLorebookNote2;

  /// No description provided for @lorebookTileStats.
  ///
  /// In ko, this message translates to:
  /// **'대화량 {count} · 연결 플롯 {linked}'**
  String lorebookTileStats(Object count, Object linked);

  /// No description provided for @createTabImportButton.
  ///
  /// In ko, this message translates to:
  /// **'불러오기'**
  String get createTabImportButton;

  /// No description provided for @createTabImportSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'SillyTavern 카드 불러오기'**
  String get createTabImportSheetTitle;

  /// No description provided for @createTabImportFromFileTitle.
  ///
  /// In ko, this message translates to:
  /// **'파일에서 불러오기 (PNG/JSON)'**
  String get createTabImportFromFileTitle;

  /// No description provided for @createTabImportFromFileSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'SillyTavern 캐릭터 카드 파일을 선택해요'**
  String get createTabImportFromFileSubtitle;

  /// No description provided for @createTabImportFromUrlTitle.
  ///
  /// In ko, this message translates to:
  /// **'링크(URL)에서 가져오기'**
  String get createTabImportFromUrlTitle;

  /// No description provided for @createTabImportFromUrlSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'카드 파일 링크나 사이트 주소를 붙여넣어요'**
  String get createTabImportFromUrlSubtitle;

  /// No description provided for @createTabImportFromPlotDataTitle.
  ///
  /// In ko, this message translates to:
  /// **'전용 형식(.mzplot)에서 가져오기'**
  String get createTabImportFromPlotDataTitle;

  /// No description provided for @createTabImportFromPlotDataSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'이미지를 포함한 플롯 전체 데이터를 불러와요(대화 기록 제외)'**
  String get createTabImportFromPlotDataSubtitle;

  /// No description provided for @createTabImportUrlDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'링크에서 가져오기'**
  String get createTabImportUrlDialogTitle;

  /// No description provided for @createTabImportConfirmButton.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get createTabImportConfirmButton;

  /// No description provided for @createTabNoIntroWarning.
  ///
  /// In ko, this message translates to:
  /// **'이 카드엔 오프닝 메시지가 없어서 인트로 탭을 비워뒀어요. \"인트로\" 탭에서 직접 작성해주세요.'**
  String get createTabNoIntroWarning;

  /// No description provided for @createTabImportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'불러오기에 실패했어요: {error}'**
  String createTabImportFailureMessage(Object error);

  /// No description provided for @createTabCreateButton.
  ///
  /// In ko, this message translates to:
  /// **'제작하기'**
  String get createTabCreateButton;

  /// No description provided for @createTabEditPlotMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'플롯 수정'**
  String get createTabEditPlotMenuItem;

  /// No description provided for @createTabDeleteLorebookConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'로어북을 삭제할까요?'**
  String get createTabDeleteLorebookConfirmTitle;

  /// No description provided for @createTabDeleteLorebookConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'연결된 모든 플롯에 즉시 반영돼요.'**
  String get createTabDeleteLorebookConfirmContent;

  /// No description provided for @createTabDeletePlotConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 삭제할까요?'**
  String get createTabDeletePlotConfirmTitle;

  /// No description provided for @createTabDeletePlotConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'삭제한 플롯과 관련 대화는 되돌릴 수 없어요.'**
  String get createTabDeletePlotConfirmContent;

  /// No description provided for @chatDefaultUserName.
  ///
  /// In ko, this message translates to:
  /// **'유저'**
  String get chatDefaultUserName;

  /// No description provided for @chatDefaultCharacterName.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터'**
  String get chatDefaultCharacterName;

  /// No description provided for @chatSelectPresetFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'AI 프리셋을 먼저 선택해주세요'**
  String get chatSelectPresetFirstMessage;

  /// No description provided for @chatReasoningInProgressLabel.
  ///
  /// In ko, this message translates to:
  /// **'생각하는 중...'**
  String get chatReasoningInProgressLabel;

  /// No description provided for @chatGenerateFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'AI 응답 생성에 실패했어요: {error}'**
  String chatGenerateFailureMessage(Object error);

  /// No description provided for @chatReviseDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 수정'**
  String get chatReviseDialogTitle;

  /// No description provided for @chatReviseDialogHint.
  ///
  /// In ko, this message translates to:
  /// **'어떻게 고칠지 알려주세요 (예: 더 짧게)'**
  String get chatReviseDialogHint;

  /// No description provided for @chatReviseConfirmButton.
  ///
  /// In ko, this message translates to:
  /// **'수정하기'**
  String get chatReviseConfirmButton;

  /// No description provided for @chatDrawerStartFreshTitle.
  ///
  /// In ko, this message translates to:
  /// **'새로하기'**
  String get chatDrawerStartFreshTitle;

  /// No description provided for @chatDrawerStartFreshSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'현재 내용을 저장하고 다시 시작할 수 있어요'**
  String get chatDrawerStartFreshSubtitle;

  /// No description provided for @chatDrawerResumeTitle.
  ///
  /// In ko, this message translates to:
  /// **'이어하기'**
  String get chatDrawerResumeTitle;

  /// No description provided for @chatDrawerDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 삭제'**
  String get chatDrawerDeleteTitle;

  /// No description provided for @chatDrawerProfileTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필'**
  String get chatDrawerProfileTitle;

  /// No description provided for @chatDrawerChoicesTitle.
  ///
  /// In ko, this message translates to:
  /// **'선택지'**
  String get chatDrawerChoicesTitle;

  /// No description provided for @chatDrawerChoicesDisabled.
  ///
  /// In ko, this message translates to:
  /// **'사용 안함'**
  String get chatDrawerChoicesDisabled;

  /// No description provided for @chatDrawerExitButton.
  ///
  /// In ko, this message translates to:
  /// **'대화방 나가기'**
  String get chatDrawerExitButton;

  /// No description provided for @chatDisclaimerBanner.
  ///
  /// In ko, this message translates to:
  /// **'답변은 모두 AI가 생성한 내용이에요'**
  String get chatDisclaimerBanner;

  /// No description provided for @chatInputHint.
  ///
  /// In ko, this message translates to:
  /// **'내용 입력하기'**
  String get chatInputHint;

  /// No description provided for @chatModelSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 모델 선택'**
  String get chatModelSheetTitle;

  /// No description provided for @chatModelSheetDescription.
  ///
  /// In ko, this message translates to:
  /// **'선택한 프리셋의 설정으로 대화가 진행돼요. 프리셋은 마이페이지에서 관리할 수 있어요.'**
  String get chatModelSheetDescription;

  /// No description provided for @chatModelSheetPresetSettingsLink.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 설정'**
  String get chatModelSheetPresetSettingsLink;

  /// No description provided for @chatModelSheetNoPresets.
  ///
  /// In ko, this message translates to:
  /// **'아직 만든 프리셋이 없어요'**
  String get chatModelSheetNoPresets;

  /// No description provided for @chatPresetSelectDefault.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 선택'**
  String get chatPresetSelectDefault;

  /// No description provided for @chatSheetStartFreshFromHere.
  ///
  /// In ko, this message translates to:
  /// **'여기서부터 새로하기'**
  String get chatSheetStartFreshFromHere;

  /// No description provided for @chatProfileSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 대화 프로필'**
  String get chatProfileSheetTitle;

  /// No description provided for @chatProfileSheetAddButton.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필 추가'**
  String get chatProfileSheetAddButton;

  /// No description provided for @chatSuggestSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'다음 대화 추천'**
  String get chatSuggestSheetTitle;

  /// No description provided for @chatSuggestUseHint.
  ///
  /// In ko, this message translates to:
  /// **'탭하면 입력창에 채워지고, 화살표를 누르면 바로 보내요.'**
  String get chatSuggestUseHint;

  /// No description provided for @chatSuggestFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'다음 대화 추천 생성에 실패했어요: {error}'**
  String chatSuggestFailureMessage(Object error);

  /// No description provided for @chatSuggestEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'추천할 만한 대화를 찾지 못했어요.'**
  String get chatSuggestEmptyMessage;

  /// No description provided for @chatSnapshotFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'스냅샷 생성에 실패했어요: {error}'**
  String chatSnapshotFailureMessage(Object error);

  /// No description provided for @chatSnapshotNotConfiguredMessage.
  ///
  /// In ko, this message translates to:
  /// **'마이페이지 > 스냅샷 설정에서 이미지 생성 API 키를 먼저 등록해주세요.'**
  String get chatSnapshotNotConfiguredMessage;

  /// No description provided for @characterDetailExportMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get characterDetailExportMenuItem;

  /// No description provided for @characterDetailContinueChatButton.
  ///
  /// In ko, this message translates to:
  /// **'대화하기'**
  String get characterDetailContinueChatButton;

  /// No description provided for @characterDetailCharacterSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터'**
  String get characterDetailCharacterSectionTitle;

  /// No description provided for @characterDetailIntroSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'인트로'**
  String get characterDetailIntroSectionTitle;

  /// No description provided for @plotEditTabPrompt.
  ///
  /// In ko, this message translates to:
  /// **'프롬프트'**
  String get plotEditTabPrompt;

  /// No description provided for @plotEditTabLorebook.
  ///
  /// In ko, this message translates to:
  /// **'로어북'**
  String get plotEditTabLorebook;

  /// No description provided for @plotEditTabAbout.
  ///
  /// In ko, this message translates to:
  /// **'소개'**
  String get plotEditTabAbout;

  /// No description provided for @plotEditDefaultCharacterName.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 {index}'**
  String plotEditDefaultCharacterName(Object index);

  /// No description provided for @plotEditAppBarTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯'**
  String get plotEditAppBarTitle;

  /// No description provided for @plotEditExportCardMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'SillyTavern 카드로 내보내기'**
  String get plotEditExportCardMenuItem;

  /// No description provided for @plotEditExportDataMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'전용 형식으로 내보내기 (전체 데이터)'**
  String get plotEditExportDataMenuItem;

  /// No description provided for @plotEditDraftSaveButton.
  ///
  /// In ko, this message translates to:
  /// **'임시저장'**
  String get plotEditDraftSaveButton;

  /// No description provided for @plotEditSaveButtonEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get plotEditSaveButtonEdit;

  /// No description provided for @plotEditSaveButtonCreate.
  ///
  /// In ko, this message translates to:
  /// **'제작'**
  String get plotEditSaveButtonCreate;

  /// No description provided for @plotEditExportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'SillyTavern 카드로 내보냈어요.'**
  String get plotEditExportSuccessMessage;

  /// No description provided for @plotEditExportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'내보내기에 실패했어요: {error}'**
  String plotEditExportFailureMessage(Object error);

  /// No description provided for @plotEditCharCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}자'**
  String plotEditCharCountLabel(Object count);

  /// No description provided for @plotEditBasicSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 설정'**
  String get plotEditBasicSettingsTitle;

  /// No description provided for @plotEditTitleFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get plotEditTitleFieldLabel;

  /// No description provided for @plotEditDescriptionFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get plotEditDescriptionFieldLabel;

  /// No description provided for @plotEditAddCharacterButton.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 추가'**
  String get plotEditAddCharacterButton;

  /// No description provided for @plotEditRepresentativeBadge.
  ///
  /// In ko, this message translates to:
  /// **'대표'**
  String get plotEditRepresentativeBadge;

  /// No description provided for @plotEditCharacterImagePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 이미지'**
  String get plotEditCharacterImagePlaceholder;

  /// No description provided for @plotEditNameFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get plotEditNameFieldLabel;

  /// No description provided for @plotEditLorebookSavePlotFirst.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 먼저 저장하면 로어북을 연결할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.'**
  String get plotEditLorebookSavePlotFirst;

  /// No description provided for @plotEditLorebookConnectTitle.
  ///
  /// In ko, this message translates to:
  /// **'로어북을 연결해 주세요'**
  String get plotEditLorebookConnectTitle;

  /// No description provided for @plotEditLorebookConnectDescription.
  ///
  /// In ko, this message translates to:
  /// **'로어북에 등록한 키워드가 언급될 때마다\n작성한 내용이 AI에게 전달돼요'**
  String get plotEditLorebookConnectDescription;

  /// No description provided for @plotEditLorebookConnectButton.
  ///
  /// In ko, this message translates to:
  /// **'로어북 연결 ({linked}개)'**
  String plotEditLorebookConnectButton(Object linked);

  /// No description provided for @plotEditIntroHintNarrator.
  ///
  /// In ko, this message translates to:
  /// **'*상황을 설명해주세요*'**
  String get plotEditIntroHintNarrator;

  /// No description provided for @plotEditIntroHintUser.
  ///
  /// In ko, this message translates to:
  /// **'유저 메시지를 입력해주세요'**
  String get plotEditIntroHintUser;

  /// No description provided for @plotEditIntroHintCharacter.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 대사를 입력해주세요'**
  String plotEditIntroHintCharacter(Object name);

  /// No description provided for @plotEditEditContentDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'내용 수정'**
  String get plotEditEditContentDialogTitle;

  /// No description provided for @plotEditIntroSavePlotFirst.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 먼저 저장하면 인트로를 작성할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.'**
  String get plotEditIntroSavePlotFirst;

  /// No description provided for @plotEditIntroFirstSceneTitle.
  ///
  /// In ko, this message translates to:
  /// **'첫 상황을 만들어 주세요'**
  String get plotEditIntroFirstSceneTitle;

  /// No description provided for @plotEditIntroEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 작성된 인트로가 없어요. 아래 입력창에서 첫 줄을 추가해보세요.'**
  String get plotEditIntroEmptyMessage;

  /// No description provided for @plotEditProfileMarkerLabel.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필 선택 시점'**
  String get plotEditProfileMarkerLabel;

  /// No description provided for @plotProfileSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'플레이하는 유저가 사용할 대화 프로필을 만들어 주세요'**
  String get plotProfileSectionTitle;

  /// No description provided for @plotProfileSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'이 플롯에서만 쓰는 전용 프로필이에요. 개수 제한은 없어요.'**
  String get plotProfileSectionDescription;

  /// No description provided for @plotProfileSavePlotFirst.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 먼저 저장하면 대화 프로필을 만들 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.'**
  String get plotProfileSavePlotFirst;

  /// No description provided for @plotProfileAddButton.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필 추가'**
  String get plotProfileAddButton;

  /// No description provided for @plotProfileUseGlobalNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'플레이하는 유저 이름 사용하기'**
  String get plotProfileUseGlobalNameLabel;

  /// No description provided for @plotProfileUseGlobalNameDescription.
  ///
  /// In ko, this message translates to:
  /// **'체크하면 마이페이지 기본 프로필 이름({name})을 그대로 가져와요'**
  String plotProfileUseGlobalNameDescription(String name);

  /// No description provided for @plotProfileShortIntroLabel.
  ///
  /// In ko, this message translates to:
  /// **'짧은 소개'**
  String get plotProfileShortIntroLabel;

  /// No description provided for @plotProfileShortIntroDescription.
  ///
  /// In ko, this message translates to:
  /// **'카드에 표시되는 한 줄 소개예요. AI에게는 전달되지 않아요.'**
  String get plotProfileShortIntroDescription;

  /// No description provided for @plotProfileDescriptionLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get plotProfileDescriptionLabel;

  /// No description provided for @plotProfileDescriptionHint.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터를 만들 때처럼 구체적인 설명을 써주시면 좋아요.\n예) 18살, 키 181cm, 잘생긴 얼굴과 1등을 놓치지 않는 성적으로 모두에게 인기있는 모범생'**
  String get plotProfileDescriptionHint;

  /// No description provided for @plotProfilePickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필을 선택하세요'**
  String get plotProfilePickerTitle;

  /// No description provided for @plotProfilePickerSwipeHint.
  ///
  /// In ko, this message translates to:
  /// **'옆으로 넘겨서 다른 프로필 보기'**
  String get plotProfilePickerSwipeHint;

  /// No description provided for @plotProfilePickerSelectButton.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get plotProfilePickerSelectButton;

  /// No description provided for @plotProfilePickerListTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필을 선택하세요'**
  String get plotProfilePickerListTitle;

  /// No description provided for @plotEditAddImageTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이미지 추가 (AI에게 전달되지 않아요)'**
  String get plotEditAddImageTooltip;

  /// No description provided for @plotEditComposerNarrator.
  ///
  /// In ko, this message translates to:
  /// **'내레이터'**
  String get plotEditComposerNarrator;

  /// No description provided for @plotEditAddHashtagDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'해시태그 추가'**
  String get plotEditAddHashtagDialogTitle;

  /// No description provided for @plotEditHashtagHint.
  ///
  /// In ko, this message translates to:
  /// **'# 없이 입력해주세요'**
  String get plotEditHashtagHint;

  /// No description provided for @plotEditCoverTitle.
  ///
  /// In ko, this message translates to:
  /// **'커버'**
  String get plotEditCoverTitle;

  /// No description provided for @plotEditPreviewButton.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get plotEditPreviewButton;

  /// No description provided for @plotEditCoverImagePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'커버 이미지'**
  String get plotEditCoverImagePlaceholder;

  /// No description provided for @plotEditShortIntroLabel.
  ///
  /// In ko, this message translates to:
  /// **'짧은 소개'**
  String get plotEditShortIntroLabel;

  /// No description provided for @plotEditShortIntroHint.
  ///
  /// In ko, this message translates to:
  /// **'제목과 함께 보일 짧은 소개를 입력해주세요'**
  String get plotEditShortIntroHint;

  /// No description provided for @plotEditHashtagsLabel.
  ///
  /// In ko, this message translates to:
  /// **'해시태그'**
  String get plotEditHashtagsLabel;

  /// No description provided for @plotEditHashtagAddButton.
  ///
  /// In ko, this message translates to:
  /// **'추가 {count}/10'**
  String plotEditHashtagAddButton(Object count);

  /// No description provided for @plotEditAboutSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'소개글'**
  String get plotEditAboutSectionTitle;

  /// No description provided for @plotEditAboutSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'상세 페이지에 표시할 내용, 이미지를 추가해 주세요.\n이 내용은 AI에게 전달되지 않아요.'**
  String get plotEditAboutSectionDescription;

  /// No description provided for @plotEditAboutFieldHint.
  ///
  /// In ko, this message translates to:
  /// **'상세 페이지에 표시할 내용을 써주세요.\n이 내용은 AI에게 전달되지 않아요.'**
  String get plotEditAboutFieldHint;

  /// No description provided for @aiPresetScreenDescription.
  ///
  /// In ko, this message translates to:
  /// **'대화에서 사용할 AI 프리셋을 만들고 관리하세요.'**
  String get aiPresetScreenDescription;

  /// No description provided for @aiPresetScreenAddButton.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 추가'**
  String get aiPresetScreenAddButton;

  /// No description provided for @aiPresetEditTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 수정'**
  String get aiPresetEditTitleEdit;

  /// No description provided for @aiPresetEditTitleCreate.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 추가'**
  String get aiPresetEditTitleCreate;

  /// No description provided for @aiPresetNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 기본 스타일'**
  String get aiPresetNameHint;

  /// No description provided for @aiPresetDescHint.
  ///
  /// In ko, this message translates to:
  /// **'이 프리셋을 한 줄로 소개해주세요'**
  String get aiPresetDescHint;

  /// No description provided for @aiPresetBaseUrlHint.
  ///
  /// In ko, this message translates to:
  /// **'예: https://api.openai.com/v1'**
  String get aiPresetBaseUrlHint;

  /// No description provided for @aiPresetModelNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'모델명'**
  String get aiPresetModelNameLabel;

  /// No description provided for @aiPresetModelNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: gpt-4o-mini, claude-sonnet-5'**
  String get aiPresetModelNameHint;

  /// No description provided for @aiPresetApiKeyLabel.
  ///
  /// In ko, this message translates to:
  /// **'API 키'**
  String get aiPresetApiKeyLabel;

  /// No description provided for @aiPresetApiKeyStorageNote.
  ///
  /// In ko, this message translates to:
  /// **'기기에만 안전하게 저장돼요'**
  String get aiPresetApiKeyStorageNote;

  /// No description provided for @aiPresetApiKeyHint.
  ///
  /// In ko, this message translates to:
  /// **'직접 발급받은 API 키를 입력해주세요'**
  String get aiPresetApiKeyHint;

  /// No description provided for @aiPresetAdvancedSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'고급 설정'**
  String get aiPresetAdvancedSettingsTitle;

  /// No description provided for @aiPresetAdvancedSettingsDescription.
  ///
  /// In ko, this message translates to:
  /// **'전부 선택 사항이에요. 비워두면 요청에 포함하지 않아요.'**
  String get aiPresetAdvancedSettingsDescription;

  /// No description provided for @aiPresetTemperatureHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 1.0'**
  String get aiPresetTemperatureHint;

  /// No description provided for @aiPresetTopKHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 40'**
  String get aiPresetTopKHint;

  /// No description provided for @aiPresetMaxTokensHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 1024'**
  String get aiPresetMaxTokensHint;

  /// No description provided for @aiPresetContextLengthHint.
  ///
  /// In ko, this message translates to:
  /// **'최근 메시지 몇 개까지'**
  String get aiPresetContextLengthHint;

  /// No description provided for @aiPresetAdditionalPromptLabel.
  ///
  /// In ko, this message translates to:
  /// **'추가 시스템 프롬프트'**
  String get aiPresetAdditionalPromptLabel;

  /// No description provided for @aiPresetAdditionalPromptHint.
  ///
  /// In ko, this message translates to:
  /// **'기본 프롬프트 뒤에 덧붙일 지침(선택)'**
  String get aiPresetAdditionalPromptHint;

  /// No description provided for @aiPresetSaveButton.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get aiPresetSaveButton;

  /// No description provided for @aiPresetReasoningEffortLabel.
  ///
  /// In ko, this message translates to:
  /// **'추론 노력(Reasoning effort)'**
  String get aiPresetReasoningEffortLabel;

  /// No description provided for @aiPresetReasoningEffortDescription.
  ///
  /// In ko, this message translates to:
  /// **'추론 모델에게 답하기 전 얼마나 깊게 생각할지 지정해요. 로컬 모델은 사고 모드가 켜지고, 원격 모델은 지원하는 경우에만 적용돼요.'**
  String get aiPresetReasoningEffortDescription;

  /// No description provided for @aiPresetReasoningEffortOff.
  ///
  /// In ko, this message translates to:
  /// **'끔'**
  String get aiPresetReasoningEffortOff;

  /// No description provided for @aiPresetReasoningEffortLow.
  ///
  /// In ko, this message translates to:
  /// **'낮음'**
  String get aiPresetReasoningEffortLow;

  /// No description provided for @aiPresetReasoningEffortMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get aiPresetReasoningEffortMedium;

  /// No description provided for @aiPresetReasoningEffortHigh.
  ///
  /// In ko, this message translates to:
  /// **'높음'**
  String get aiPresetReasoningEffortHigh;

  /// No description provided for @lorebookConnectTitle.
  ///
  /// In ko, this message translates to:
  /// **'로어북 연결'**
  String get lorebookConnectTitle;

  /// No description provided for @lorebookConnectNoneButton.
  ///
  /// In ko, this message translates to:
  /// **'연결 안 함'**
  String get lorebookConnectNoneButton;

  /// No description provided for @lorebookConnectConfirmButton.
  ///
  /// In ko, this message translates to:
  /// **'연결하기 ({count}개)'**
  String lorebookConnectConfirmButton(Object count);

  /// No description provided for @lorebookDetailDeletedMessage.
  ///
  /// In ko, this message translates to:
  /// **'삭제된 로어북이에요'**
  String get lorebookDetailDeletedMessage;

  /// No description provided for @lorebookInfoTabLabel.
  ///
  /// In ko, this message translates to:
  /// **'로어 정보'**
  String get lorebookInfoTabLabel;

  /// No description provided for @lorebookLinkedPlotsTabLabel.
  ///
  /// In ko, this message translates to:
  /// **'연결 플롯'**
  String get lorebookLinkedPlotsTabLabel;

  /// No description provided for @lorebookPlotConnectTabLabel.
  ///
  /// In ko, this message translates to:
  /// **'플롯 연결'**
  String get lorebookPlotConnectTabLabel;

  /// No description provided for @lorebookDetailEditMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'로어북 수정'**
  String get lorebookDetailEditMenuItem;

  /// No description provided for @lorebookDetailNoEntriesMessage.
  ///
  /// In ko, this message translates to:
  /// **'작성된 항목이 없어요'**
  String get lorebookDetailNoEntriesMessage;

  /// No description provided for @lorebookDetailNoLinkedPlotsMessage.
  ///
  /// In ko, this message translates to:
  /// **'연결된 플롯이 없어요'**
  String get lorebookDetailNoLinkedPlotsMessage;

  /// No description provided for @lorebookEditAppBarTitle.
  ///
  /// In ko, this message translates to:
  /// **'로어북'**
  String get lorebookEditAppBarTitle;

  /// No description provided for @lorebookEditSaveButtonCreate.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get lorebookEditSaveButtonCreate;

  /// No description provided for @lorebookEditSaveFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'로어북을 먼저 등록하면 플롯을 연결할 수 있어요.'**
  String get lorebookEditSaveFirstMessage;

  /// No description provided for @lorebookEditIntroDescription.
  ///
  /// In ko, this message translates to:
  /// **'소개글은 AI에게 전달되지 않아요.\n로어북을 관리하는 용도로 활용하세요.'**
  String get lorebookEditIntroDescription;

  /// No description provided for @lorebookEditTitleFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'로어북 제목'**
  String get lorebookEditTitleFieldLabel;

  /// No description provided for @lorebookEditEntriesSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'항목'**
  String get lorebookEditEntriesSectionTitle;

  /// No description provided for @lorebookEditAddEntryButton.
  ///
  /// In ko, this message translates to:
  /// **'항목 추가'**
  String get lorebookEditAddEntryButton;

  /// No description provided for @lorebookEditEntryCardTitle.
  ///
  /// In ko, this message translates to:
  /// **'항목 {index}'**
  String lorebookEditEntryCardTitle(Object index);

  /// No description provided for @lorebookEditEntryTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력하세요'**
  String get lorebookEditEntryTitleHint;

  /// No description provided for @lorebookEditKeywordsLabel.
  ///
  /// In ko, this message translates to:
  /// **'키워드'**
  String get lorebookEditKeywordsLabel;

  /// No description provided for @lorebookEditKeywordsHint.
  ///
  /// In ko, this message translates to:
  /// **'키워드를 쉼표(,)로 구분해서 입력해주세요.\n입력한 키워드가 언급되면 아래 작성한 내용이 AI에게 전달돼요.'**
  String get lorebookEditKeywordsHint;

  /// No description provided for @lorebookEditContentLabel.
  ///
  /// In ko, this message translates to:
  /// **'내용'**
  String get lorebookEditContentLabel;

  /// No description provided for @lorebookEditContentHint.
  ///
  /// In ko, this message translates to:
  /// **'키워드 언급 시 AI에게 전달할 내용을 입력해 주세요.'**
  String get lorebookEditContentHint;

  /// No description provided for @lorebookEditConnectPlotsTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 연결해 주세요'**
  String get lorebookEditConnectPlotsTitle;

  /// No description provided for @lorebookEditConnectPlotsDescription.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 연결하면 키워드가 언급될 때마다\n로어북의 세계관이 AI에게 전달돼요'**
  String get lorebookEditConnectPlotsDescription;

  /// No description provided for @lorebookConnectButtonWithCount.
  ///
  /// In ko, this message translates to:
  /// **'연결하기 ({count})'**
  String lorebookConnectButtonWithCount(Object count);

  /// No description provided for @profileEditNameDescription.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터가 날 이렇게 불러 거예요'**
  String get profileEditNameDescription;

  /// No description provided for @profileEditDescriptionLabel.
  ///
  /// In ko, this message translates to:
  /// **'설명(선택)'**
  String get profileEditDescriptionLabel;

  /// No description provided for @profileEditDefaultSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 대화 프로필'**
  String get profileEditDefaultSectionTitle;

  /// No description provided for @profileEditApplyDefaultTitle.
  ///
  /// In ko, this message translates to:
  /// **'새로운 대화 시작할 때 이 프로필 적용하기'**
  String get profileEditApplyDefaultTitle;

  /// No description provided for @profileEditApplyDefaultDescription.
  ///
  /// In ko, this message translates to:
  /// **'대화 중에 다른 프로필로 바꿀 수 있어요'**
  String get profileEditApplyDefaultDescription;

  /// No description provided for @resumeNoSavedConversations.
  ///
  /// In ko, this message translates to:
  /// **'저장된 대화가 없어요'**
  String get resumeNoSavedConversations;

  /// No description provided for @resumeJustNow.
  ///
  /// In ko, this message translates to:
  /// **'방금 전'**
  String get resumeJustNow;

  /// No description provided for @resumeMinutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}분 전'**
  String resumeMinutesAgo(Object count);

  /// No description provided for @resumeHoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}시간 전'**
  String resumeHoursAgo(Object count);

  /// No description provided for @resumeDaysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{count}일 전'**
  String resumeDaysAgo(Object count);

  /// No description provided for @resumeSavedAtLabel.
  ///
  /// In ko, this message translates to:
  /// **'{date}에 저장된 대화'**
  String resumeSavedAtLabel(Object date);

  /// No description provided for @resumeNoSavedMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장된 메시지가 없어요'**
  String get resumeNoSavedMessage;

  /// No description provided for @tokenUsageTitle.
  ///
  /// In ko, this message translates to:
  /// **'토큰 사용 내역'**
  String get tokenUsageTitle;

  /// No description provided for @tokenUsageDeleteAllButton.
  ///
  /// In ko, this message translates to:
  /// **'전체 삭제'**
  String get tokenUsageDeleteAllButton;

  /// No description provided for @tokenUsageDeleteAllConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'내역을 전부 삭제할까요?'**
  String get tokenUsageDeleteAllConfirmTitle;

  /// No description provided for @tokenUsageDeleteAllConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'삭제하면 되돌릴 수 없어요.'**
  String get tokenUsageDeleteAllConfirmContent;

  /// No description provided for @tokenUsageEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 사용 내역이 없어요'**
  String get tokenUsageEmptyMessage;

  /// No description provided for @tokenUsageProviderLabel.
  ///
  /// In ko, this message translates to:
  /// **'제공자: {provider} · {presetName}'**
  String tokenUsageProviderLabel(Object provider, Object presetName);

  /// No description provided for @tokenUsageBreakdown.
  ///
  /// In ko, this message translates to:
  /// **'입력 {prompt} · 출력 {completion} · 합계 {total}'**
  String tokenUsageBreakdown(Object prompt, Object completion, Object total);

  /// No description provided for @startFreshDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화를 새로 시작할까요?'**
  String get startFreshDialogTitle;

  /// No description provided for @startFreshDialogDescription.
  ///
  /// In ko, this message translates to:
  /// **'저장한 대화는 \'이어하기\'에서\n언제든 다시 할 수 있어요'**
  String get startFreshDialogDescription;

  /// No description provided for @startFreshDialogSaveCheckbox.
  ///
  /// In ko, this message translates to:
  /// **'현재 대화 저장하기'**
  String get startFreshDialogSaveCheckbox;

  /// No description provided for @startFreshFromHereDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'여기서부터 새로 시작할까요?'**
  String get startFreshFromHereDialogTitle;

  /// No description provided for @startFreshFromHereDialogDescription.
  ///
  /// In ko, this message translates to:
  /// **'기존 대화는 \'이어하기\'에서\n언제든 다시 할 수 있어요'**
  String get startFreshFromHereDialogDescription;

  /// No description provided for @systemPromptButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'시스템 프롬프트 설정'**
  String get systemPromptButtonLabel;

  /// No description provided for @systemPromptWarning.
  ///
  /// In ko, this message translates to:
  /// **'꼭 필요한 경우에만 수정해 주세요. 잘못 수정하면 AI 응답이 이상해질 수 있어요.'**
  String get systemPromptWarning;

  /// No description provided for @systemPromptPlaceholderHintTitle.
  ///
  /// In ko, this message translates to:
  /// **'사용 가능한 자리표시자'**
  String get systemPromptPlaceholderHintTitle;

  /// No description provided for @systemPromptPlaceholderHintBody.
  ///
  /// In ko, this message translates to:
  /// **'다음 이름을 중괄호 두 겹으로 감싸서 쓰면 실제 값으로 자동 치환돼요: plot_title, plot_description, characters_block, example_character_name, user_profile_name, lore_block, extra_block\n단, user는 AI가 응답에 그대로 남겨야 하는 토큰이니 지우지 마세요.'**
  String get systemPromptPlaceholderHintBody;

  /// No description provided for @systemPromptResetButton.
  ///
  /// In ko, this message translates to:
  /// **'기본값으로 되돌리기'**
  String get systemPromptResetButton;

  /// No description provided for @systemPromptResetConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본값으로 되돌릴까요?'**
  String get systemPromptResetConfirmTitle;

  /// No description provided for @systemPromptResetConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'지금 수정한 내용은 사라지고 기본 시스템 프롬프트로 돌아가요.'**
  String get systemPromptResetConfirmContent;

  /// No description provided for @systemPromptSavedMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장했어요.'**
  String get systemPromptSavedMessage;

  /// No description provided for @systemPromptResetDoneMessage.
  ///
  /// In ko, this message translates to:
  /// **'기본값으로 되돌렸어요.'**
  String get systemPromptResetDoneMessage;

  /// No description provided for @snapshotSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'스냅샷 설정'**
  String get snapshotSettingsTitle;

  /// No description provided for @snapshotSettingsDescription.
  ///
  /// In ko, this message translates to:
  /// **'채팅에서 스냅샷을 누르면 지금 상황을 AI가 요약해서, 아래 설정한 엔드포인트로 이미지를 생성해요.'**
  String get snapshotSettingsDescription;

  /// No description provided for @snapshotSettingsProviderLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미지 생성 엔드포인트'**
  String get snapshotSettingsProviderLabel;

  /// No description provided for @snapshotSettingsApiKeyLabel.
  ///
  /// In ko, this message translates to:
  /// **'API 키'**
  String get snapshotSettingsApiKeyLabel;

  /// No description provided for @snapshotSettingsApiKeyHint.
  ///
  /// In ko, this message translates to:
  /// **'선택한 엔드포인트의 API 키를 입력해주세요'**
  String get snapshotSettingsApiKeyHint;

  /// No description provided for @snapshotSettingsModelNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미지 모델명'**
  String get snapshotSettingsModelNameLabel;

  /// No description provided for @snapshotSettingsModelNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: google/gemini-2.5-flash-image'**
  String get snapshotSettingsModelNameHint;

  /// No description provided for @snapshotSettingsSaveButton.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get snapshotSettingsSaveButton;

  /// No description provided for @snapshotSettingsSavedMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장했어요.'**
  String get snapshotSettingsSavedMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
