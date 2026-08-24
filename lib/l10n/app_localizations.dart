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

  /// No description provided for @localLlmModelDescHuihuiQwen3508b.
  ///
  /// In ko, this message translates to:
  /// **'IQ4 XS임 성능 기대 ㄴㄴ'**
  String get localLlmModelDescHuihuiQwen3508b;

  /// No description provided for @localLlmModelDescHuihuiQwen354b.
  ///
  /// In ko, this message translates to:
  /// **'속도와 품질의 균형. 한국어 대응이 비교적 좋음.'**
  String get localLlmModelDescHuihuiQwen354b;

  /// No description provided for @localLlmModelDescHuihuiGemma4E2b.
  ///
  /// In ko, this message translates to:
  /// **'가장 가볍고 빠름. 저사양 기기에 적합.'**
  String get localLlmModelDescHuihuiGemma4E2b;

  /// No description provided for @localLlmModelDescHuihuiGemma4E4b.
  ///
  /// In ko, this message translates to:
  /// **'더 나은 품질. 고사양 기기/PC 권장.'**
  String get localLlmModelDescHuihuiGemma4E4b;

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

  /// No description provided for @preferencesAiSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 설정'**
  String get preferencesAiSectionTitle;

  /// No description provided for @preferencesThemeSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get preferencesThemeSectionTitle;

  /// No description provided for @preferencesThemeDarkOption.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get preferencesThemeDarkOption;

  /// No description provided for @preferencesThemeLightOption.
  ///
  /// In ko, this message translates to:
  /// **'화이트'**
  String get preferencesThemeLightOption;

  /// No description provided for @preferencesThemeAmoledOption.
  ///
  /// In ko, this message translates to:
  /// **'AMOLED 블랙'**
  String get preferencesThemeAmoledOption;

  /// No description provided for @preferencesThemeSystemOption.
  ///
  /// In ko, this message translates to:
  /// **'시스템 자동'**
  String get preferencesThemeSystemOption;

  /// No description provided for @paletteAddButton.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 추가'**
  String get paletteAddButton;

  /// No description provided for @paletteDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 삭제'**
  String get paletteDeleteConfirmTitle;

  /// No description provided for @paletteDeleteConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 프리셋을 삭제할까요? 이 작업은 되돌릴 수 없어요.'**
  String paletteDeleteConfirmContent(String name);

  /// No description provided for @paletteEditNewTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 추가'**
  String get paletteEditNewTitle;

  /// No description provided for @paletteEditEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 편집'**
  String get paletteEditEditTitle;

  /// No description provided for @paletteEditNameEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 이름을 입력해주세요.'**
  String get paletteEditNameEmptyMessage;

  /// No description provided for @paletteEditPreviewLabel.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get paletteEditPreviewLabel;

  /// No description provided for @paletteEditNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 이름'**
  String get paletteEditNameLabel;

  /// No description provided for @paletteEditColorsLabel.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get paletteEditColorsLabel;

  /// No description provided for @paletteEditBrightnessLabel.
  ///
  /// In ko, this message translates to:
  /// **'밝기'**
  String get paletteEditBrightnessLabel;

  /// No description provided for @paletteEditBrightnessDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get paletteEditBrightnessDark;

  /// No description provided for @paletteEditBrightnessLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get paletteEditBrightnessLight;

  /// No description provided for @paletteSlotBackground.
  ///
  /// In ko, this message translates to:
  /// **'배경'**
  String get paletteSlotBackground;

  /// No description provided for @paletteSlotSurface.
  ///
  /// In ko, this message translates to:
  /// **'카드/표면'**
  String get paletteSlotSurface;

  /// No description provided for @paletteSlotSurfaceAlt.
  ///
  /// In ko, this message translates to:
  /// **'보조 표면(입력창 등)'**
  String get paletteSlotSurfaceAlt;

  /// No description provided for @paletteSlotBorder.
  ///
  /// In ko, this message translates to:
  /// **'테두리'**
  String get paletteSlotBorder;

  /// No description provided for @paletteSlotPrimary.
  ///
  /// In ko, this message translates to:
  /// **'포인트 색상'**
  String get paletteSlotPrimary;

  /// No description provided for @paletteSlotOnPrimary.
  ///
  /// In ko, this message translates to:
  /// **'포인트 위 텍스트'**
  String get paletteSlotOnPrimary;

  /// No description provided for @paletteSlotTextPrimary.
  ///
  /// In ko, this message translates to:
  /// **'본문 텍스트'**
  String get paletteSlotTextPrimary;

  /// No description provided for @paletteSlotTextSecondary.
  ///
  /// In ko, this message translates to:
  /// **'보조 텍스트'**
  String get paletteSlotTextSecondary;

  /// No description provided for @paletteSlotTextMuted.
  ///
  /// In ko, this message translates to:
  /// **'흐린 텍스트'**
  String get paletteSlotTextMuted;

  /// No description provided for @paletteSlotTextFaint.
  ///
  /// In ko, this message translates to:
  /// **'더 흐린 텍스트'**
  String get paletteSlotTextFaint;

  /// No description provided for @paletteSlotTextGhost.
  ///
  /// In ko, this message translates to:
  /// **'가장 흐린 텍스트'**
  String get paletteSlotTextGhost;

  /// No description provided for @colorPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'색상 선택'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerHexLabel.
  ///
  /// In ko, this message translates to:
  /// **'헥스코드'**
  String get colorPickerHexLabel;

  /// No description provided for @colorPickerAlphaLabel.
  ///
  /// In ko, this message translates to:
  /// **'투명도'**
  String get colorPickerAlphaLabel;

  /// No description provided for @colorPickerQuickPicksLabel.
  ///
  /// In ko, this message translates to:
  /// **'빠른 선택'**
  String get colorPickerQuickPicksLabel;

  /// No description provided for @preferencesVersionSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'버전 정보'**
  String get preferencesVersionSectionTitle;

  /// No description provided for @preferencesCurrentVersionLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재 버전 {version}'**
  String preferencesCurrentVersionLabel(String version);

  /// No description provided for @preferencesCheckUpdateButton.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 확인'**
  String get preferencesCheckUpdateButton;

  /// No description provided for @preferencesUpdateAvailableMessage.
  ///
  /// In ko, this message translates to:
  /// **'새 버전 {version}이(가) 있어요.'**
  String preferencesUpdateAvailableMessage(String version);

  /// No description provided for @preferencesUpToDateMessage.
  ///
  /// In ko, this message translates to:
  /// **'최신 버전을 사용하고 있어요.'**
  String get preferencesUpToDateMessage;

  /// No description provided for @preferencesUpdateCheckFailedMessage.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 확인에 실패했어요.'**
  String get preferencesUpdateCheckFailedMessage;

  /// No description provided for @preferencesViewReleaseButton.
  ///
  /// In ko, this message translates to:
  /// **'릴리스 보기'**
  String get preferencesViewReleaseButton;

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

  /// No description provided for @homeTabFilterRecommended.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get homeTabFilterRecommended;

  /// No description provided for @homeTabFilterGames.
  ///
  /// In ko, this message translates to:
  /// **'게임'**
  String get homeTabFilterGames;

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

  /// No description provided for @conversationTabSelectedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택됨'**
  String conversationTabSelectedCount(int count);

  /// No description provided for @conversationTabDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화방 삭제'**
  String get conversationTabDeleteConfirmTitle;

  /// No description provided for @conversationTabDeleteConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'선택한 대화방을 삭제할까요? 되돌릴 수 없어요.'**
  String get conversationTabDeleteConfirmContent;

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

  /// No description provided for @createTabPlotTypeFilterAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get createTabPlotTypeFilterAll;

  /// No description provided for @createTabPlotTypeFilterStoryChat.
  ///
  /// In ko, this message translates to:
  /// **'스토리챗'**
  String get createTabPlotTypeFilterStoryChat;

  /// No description provided for @createTabPlotTypeFilterVisualNovel.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨'**
  String get createTabPlotTypeFilterVisualNovel;

  /// No description provided for @createTabPlotTypeChooserTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯'**
  String get createTabPlotTypeChooserTitle;

  /// No description provided for @createTabPlotTypeStoryChatTitle.
  ///
  /// In ko, this message translates to:
  /// **'스토리챗'**
  String get createTabPlotTypeStoryChatTitle;

  /// No description provided for @createTabPlotTypeStoryChatSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'말풍선 형태로 대화하는 롤플레이'**
  String get createTabPlotTypeStoryChatSubtitle;

  /// No description provided for @createTabPlotTypeVisualNovelTitle.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨'**
  String get createTabPlotTypeVisualNovelTitle;

  /// No description provided for @createTabPlotTypeVisualNovelSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'배경/캐릭터 일러스트와 함께 진행하는 이야기'**
  String get createTabPlotTypeVisualNovelSubtitle;

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

  /// No description provided for @chatGeneratingIndicator.
  ///
  /// In ko, this message translates to:
  /// **'답변 생성 중...'**
  String get chatGeneratingIndicator;

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

  /// No description provided for @chatDrawerMemoryTitle.
  ///
  /// In ko, this message translates to:
  /// **'기억 보기'**
  String get chatDrawerMemoryTitle;

  /// No description provided for @chatMemorySheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'이전 대화 요약'**
  String get chatMemorySheetTitle;

  /// No description provided for @chatMemoryEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 요약된 기억이 없어요. 대화가 길어지면 자동으로 만들어져요.'**
  String get chatMemoryEmptyMessage;

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

  /// No description provided for @characterDetailIntroNarratorLabel.
  ///
  /// In ko, this message translates to:
  /// **'내레이션'**
  String get characterDetailIntroNarratorLabel;

  /// No description provided for @characterDetailIntroUserLabel.
  ///
  /// In ko, this message translates to:
  /// **'나'**
  String get characterDetailIntroUserLabel;

  /// No description provided for @characterDetailIntroImageLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미지'**
  String get characterDetailIntroImageLabel;

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

  /// No description provided for @plotEditExportDataSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'전용 형식(.mzplot)으로 내보냈어요.'**
  String get plotEditExportDataSuccessMessage;

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

  /// No description provided for @plotEditIntroAiGenerateButton.
  ///
  /// In ko, this message translates to:
  /// **'AI로 생성'**
  String get plotEditIntroAiGenerateButton;

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

  /// No description provided for @aiPresetApiKeyGuideButton.
  ///
  /// In ko, this message translates to:
  /// **'키 발급 안내'**
  String get aiPresetApiKeyGuideButton;

  /// No description provided for @apiKeyGuideDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'API 키 발급 안내'**
  String get apiKeyGuideDialogTitle;

  /// No description provided for @apiKeyGuideOpenButton.
  ///
  /// In ko, this message translates to:
  /// **'바로가기'**
  String get apiKeyGuideOpenButton;

  /// No description provided for @apiKeyGuideOpenRouterDescription.
  ///
  /// In ko, this message translates to:
  /// **'다양한 모델을 하나의 API 키로 쓸 수 있는 라우터 서비스예요.'**
  String get apiKeyGuideOpenRouterDescription;

  /// No description provided for @apiKeyGuideFeatherlessDescription.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 모델을 정액제로 무제한에 가깝게 쓸 수 있는 서비스예요.'**
  String get apiKeyGuideFeatherlessDescription;

  /// No description provided for @apiKeyGuideFeatherlessReferralNote.
  ///
  /// In ko, this message translates to:
  /// **'이 링크로 가입하면 첫 달 10달러 할인 혜택을 받아요.'**
  String get apiKeyGuideFeatherlessReferralNote;

  /// No description provided for @apiKeyGuideAtlasCloudDescription.
  ///
  /// In ko, this message translates to:
  /// **'여러 모델을 종량제로 제공하는 서비스예요.'**
  String get apiKeyGuideAtlasCloudDescription;

  /// No description provided for @apiKeyGuideAtlasCloudReferralNote.
  ///
  /// In ko, this message translates to:
  /// **'이 링크로 가입하면 5달러를 추가로 충전해줘요.'**
  String get apiKeyGuideAtlasCloudReferralNote;

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

  /// No description provided for @aiPresetDefaultSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 프리셋'**
  String get aiPresetDefaultSectionTitle;

  /// No description provided for @aiPresetApplyDefaultLabel.
  ///
  /// In ko, this message translates to:
  /// **'새 대화/게임 상대에 기본으로 사용하기'**
  String get aiPresetApplyDefaultLabel;

  /// No description provided for @aiPresetApplyDefaultDescription.
  ///
  /// In ko, this message translates to:
  /// **'프리셋을 따로 고르지 않은 모든 대화와 게임이 이 프리셋을 사용해요. 대화 중엔 언제든 다른 프리셋으로 바꿀 수 있어요.'**
  String get aiPresetApplyDefaultDescription;

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

  /// No description provided for @aiPresetEndpointFormatLabel.
  ///
  /// In ko, this message translates to:
  /// **'엔드포인트 형식'**
  String get aiPresetEndpointFormatLabel;

  /// No description provided for @aiPresetEndpointFormatDescription.
  ///
  /// In ko, this message translates to:
  /// **'선택한 형식에 맞는 요청/응답 파서로 통신해요.'**
  String get aiPresetEndpointFormatDescription;

  /// No description provided for @aiPresetEndpointFormatOpenAi.
  ///
  /// In ko, this message translates to:
  /// **'OpenAI 호환'**
  String get aiPresetEndpointFormatOpenAi;

  /// No description provided for @aiPresetEndpointFormatAnthropic.
  ///
  /// In ko, this message translates to:
  /// **'Anthropic'**
  String get aiPresetEndpointFormatAnthropic;

  /// No description provided for @aiPresetSupportsVisionLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미지 인식(비전) 지원'**
  String get aiPresetSupportsVisionLabel;

  /// No description provided for @aiPresetSupportsVisionDescription.
  ///
  /// In ko, this message translates to:
  /// **'켜두면 ZedTalk에서 첨부한 이미지를 이 프리셋의 모델에게 함께 보내요. 실제로 이미지를 이해하는 모델일 때만 켜주세요.'**
  String get aiPresetSupportsVisionDescription;

  /// No description provided for @aiPresetOpenRouterSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'OpenRouter 전용 옵션'**
  String get aiPresetOpenRouterSectionTitle;

  /// No description provided for @aiPresetOpenRouterSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'Base URL이 openrouter.ai일 때만 적용돼요.'**
  String get aiPresetOpenRouterSectionDescription;

  /// No description provided for @aiPresetOpenRouterZdrOnlyLabel.
  ///
  /// In ko, this message translates to:
  /// **'ZDR 제공자만 사용'**
  String get aiPresetOpenRouterZdrOnlyLabel;

  /// No description provided for @aiPresetOpenRouterZdrOnlyDescription.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 저장하지 않는(Zero Data Retention) 제공자로만 라우팅해요.'**
  String get aiPresetOpenRouterZdrOnlyDescription;

  /// No description provided for @aiPresetOpenRouterExcludeChinaLabel.
  ///
  /// In ko, this message translates to:
  /// **'중국 제공자 제외'**
  String get aiPresetOpenRouterExcludeChinaLabel;

  /// No description provided for @aiPresetOpenRouterExcludeChinaDescription.
  ///
  /// In ko, this message translates to:
  /// **'알리바바 등 중국 소재 제공자는 라우팅에서 제외해요.'**
  String get aiPresetOpenRouterExcludeChinaDescription;

  /// No description provided for @aiPresetOpenRouterExcludeTrainingLabel.
  ///
  /// In ko, this message translates to:
  /// **'데이터 학습 제공자 제외'**
  String get aiPresetOpenRouterExcludeTrainingLabel;

  /// No description provided for @aiPresetOpenRouterExcludeTrainingDescription.
  ///
  /// In ko, this message translates to:
  /// **'요청 데이터를 학습에 활용할 수 있는 제공자는 제외해요.'**
  String get aiPresetOpenRouterExcludeTrainingDescription;

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

  /// No description provided for @profileEditVnStandingImageLabel.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨 스탠딩 이미지'**
  String get profileEditVnStandingImageLabel;

  /// No description provided for @profileEditVnStandingImageDescription.
  ///
  /// In ko, this message translates to:
  /// **'플레이어블 캐릭터 없이 진행하는 비주얼 노벨에서, 내가 말할 때 화면에 표시할 전신 이미지예요'**
  String get profileEditVnStandingImageDescription;

  /// No description provided for @profileEditVnStandingImageSelectButton.
  ///
  /// In ko, this message translates to:
  /// **'이미지 선택'**
  String get profileEditVnStandingImageSelectButton;

  /// No description provided for @profileEditVnStandingImageClearButton.
  ///
  /// In ko, this message translates to:
  /// **'지우기'**
  String get profileEditVnStandingImageClearButton;

  /// No description provided for @profileExportButton.
  ///
  /// In ko, this message translates to:
  /// **'전용 형식으로 내보내기'**
  String get profileExportButton;

  /// No description provided for @profileExportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필을 내보냈어요.'**
  String get profileExportSuccessMessage;

  /// No description provided for @profileExportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'내보내기에 실패했어요: {error}'**
  String profileExportFailureMessage(Object error);

  /// No description provided for @profileImportButton.
  ///
  /// In ko, this message translates to:
  /// **'전용 형식으로 가져오기'**
  String get profileImportButton;

  /// No description provided for @profileImportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필을 가져왔어요.'**
  String get profileImportSuccessMessage;

  /// No description provided for @profileImportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'가져오기에 실패했어요: {error}'**
  String profileImportFailureMessage(Object error);

  /// No description provided for @profileEditScopeSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'적용 범위'**
  String get profileEditScopeSectionTitle;

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

  /// No description provided for @createTabAiGenerateButton.
  ///
  /// In ko, this message translates to:
  /// **'AI로 생성'**
  String get createTabAiGenerateButton;

  /// No description provided for @plotAiGenerateTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI로 플롯 생성'**
  String get plotAiGenerateTitle;

  /// No description provided for @plotAiGeneratePresetLabel.
  ///
  /// In ko, this message translates to:
  /// **'사용할 AI 프리셋'**
  String get plotAiGeneratePresetLabel;

  /// No description provided for @plotAiGeneratePresetEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'먼저 환경설정 > AI 설정에서 AI 프리셋을 만들어주세요.'**
  String get plotAiGeneratePresetEmptyHint;

  /// No description provided for @plotAiGeneratePlotTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'플롯 종류'**
  String get plotAiGeneratePlotTypeLabel;

  /// No description provided for @plotAiGeneratePlotTypeStoryChat.
  ///
  /// In ko, this message translates to:
  /// **'스토리챗'**
  String get plotAiGeneratePlotTypeStoryChat;

  /// No description provided for @plotAiGeneratePlotTypeVisualNovel.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨'**
  String get plotAiGeneratePlotTypeVisualNovel;

  /// No description provided for @plotAiGeneratePromptLabel.
  ///
  /// In ko, this message translates to:
  /// **'어떤 플롯을 만들까요?'**
  String get plotAiGeneratePromptLabel;

  /// No description provided for @plotAiGeneratePromptHint.
  ///
  /// In ko, this message translates to:
  /// **'장르, 배경, 등장인물 특징 등을 자유롭게 설명해주세요'**
  String get plotAiGeneratePromptHint;

  /// No description provided for @plotAiGenerateWebSearchLabel.
  ///
  /// In ko, this message translates to:
  /// **'웹 검색으로 참고자료 찾기'**
  String get plotAiGenerateWebSearchLabel;

  /// No description provided for @plotAiGenerateWebSearchUnsupportedHint.
  ///
  /// In ko, this message translates to:
  /// **'선택한 프리셋에서는 네이티브 웹 검색을 지원하지 않아요(OpenRouter 또는 OpenAI 계열만 가능).'**
  String get plotAiGenerateWebSearchUnsupportedHint;

  /// No description provided for @plotAiGenerateLoreLengthLabel.
  ///
  /// In ko, this message translates to:
  /// **'로어 길이'**
  String get plotAiGenerateLoreLengthLabel;

  /// No description provided for @plotAiGenerateLoreLengthShort.
  ///
  /// In ko, this message translates to:
  /// **'짧게'**
  String get plotAiGenerateLoreLengthShort;

  /// No description provided for @plotAiGenerateLoreLengthMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get plotAiGenerateLoreLengthMedium;

  /// No description provided for @plotAiGenerateLoreLengthLong.
  ///
  /// In ko, this message translates to:
  /// **'길게'**
  String get plotAiGenerateLoreLengthLong;

  /// No description provided for @plotAiGenerateAccuracyLabel.
  ///
  /// In ko, this message translates to:
  /// **'정확도'**
  String get plotAiGenerateAccuracyLabel;

  /// No description provided for @plotAiGenerateAccuracyAccurate.
  ///
  /// In ko, this message translates to:
  /// **'정확함(Accurate)'**
  String get plotAiGenerateAccuracyAccurate;

  /// No description provided for @plotAiGenerateAccuracyMixed.
  ///
  /// In ko, this message translates to:
  /// **'혼합(Mixed)'**
  String get plotAiGenerateAccuracyMixed;

  /// No description provided for @plotAiGenerateSubmitButton.
  ///
  /// In ko, this message translates to:
  /// **'생성하기'**
  String get plotAiGenerateSubmitButton;

  /// No description provided for @plotAiGeneratePromptEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'어떤 플롯을 만들지 먼저 설명해주세요.'**
  String get plotAiGeneratePromptEmptyMessage;

  /// No description provided for @plotAiGenerateFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'플롯 생성에 실패했어요: {error}'**
  String plotAiGenerateFailureMessage(Object error);

  /// No description provided for @plotAiGenerateGeneratingMessage.
  ///
  /// In ko, this message translates to:
  /// **'AI가 플롯을 만들고 있어요...'**
  String get plotAiGenerateGeneratingMessage;

  /// No description provided for @lanSyncSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'LAN 동기화'**
  String get lanSyncSectionTitle;

  /// No description provided for @lanSyncScreenTitle.
  ///
  /// In ko, this message translates to:
  /// **'LAN 동기화'**
  String get lanSyncScreenTitle;

  /// No description provided for @lanSyncExportSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서 내보내기'**
  String get lanSyncExportSectionTitle;

  /// No description provided for @lanSyncExportSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'같은 Wi-Fi/LAN에 연결된 다른 기기에서 아래 정보로 접속하면 전체 데이터를 가져갈 수 있어요.'**
  String get lanSyncExportSectionDescription;

  /// No description provided for @lanSyncStartHostButton.
  ///
  /// In ko, this message translates to:
  /// **'연결 대기 시작'**
  String get lanSyncStartHostButton;

  /// No description provided for @lanSyncStopHostButton.
  ///
  /// In ko, this message translates to:
  /// **'중지'**
  String get lanSyncStopHostButton;

  /// No description provided for @lanSyncWaitingMessage.
  ///
  /// In ko, this message translates to:
  /// **'다른 기기의 접속을 기다리는 중...'**
  String get lanSyncWaitingMessage;

  /// No description provided for @lanSyncAddressLabel.
  ///
  /// In ko, this message translates to:
  /// **'주소'**
  String get lanSyncAddressLabel;

  /// No description provided for @lanSyncPortLabel.
  ///
  /// In ko, this message translates to:
  /// **'포트'**
  String get lanSyncPortLabel;

  /// No description provided for @lanSyncPinLabel.
  ///
  /// In ko, this message translates to:
  /// **'PIN'**
  String get lanSyncPinLabel;

  /// No description provided for @lanSyncExportedMessage.
  ///
  /// In ko, this message translates to:
  /// **'전송을 완료했어요.'**
  String get lanSyncExportedMessage;

  /// No description provided for @lanSyncExportFailedMessage.
  ///
  /// In ko, this message translates to:
  /// **'전송에 실패했어요: {error}'**
  String lanSyncExportFailedMessage(Object error);

  /// No description provided for @lanSyncNoAddressWarning.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서 LAN 주소를 찾지 못했어요. Wi-Fi 연결을 확인해주세요.'**
  String get lanSyncNoAddressWarning;

  /// No description provided for @lanSyncImportSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'다른 기기에서 가져오기'**
  String get lanSyncImportSectionTitle;

  /// No description provided for @lanSyncImportSectionDescription.
  ///
  /// In ko, this message translates to:
  /// **'내보내는 쪽 화면에 표시된 주소/포트/PIN을 입력해주세요.'**
  String get lanSyncImportSectionDescription;

  /// No description provided for @lanSyncHostFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'주소(IP)'**
  String get lanSyncHostFieldLabel;

  /// No description provided for @lanSyncPortFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'포트'**
  String get lanSyncPortFieldLabel;

  /// No description provided for @lanSyncPinFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'PIN'**
  String get lanSyncPinFieldLabel;

  /// No description provided for @lanSyncImportButton.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get lanSyncImportButton;

  /// No description provided for @lanSyncImportConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'전체 데이터 교체'**
  String get lanSyncImportConfirmTitle;

  /// No description provided for @lanSyncImportConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'받아온 데이터로 이 기기의 전체 데이터를 덮어써요. 되돌릴 수 없어요.'**
  String get lanSyncImportConfirmContent;

  /// No description provided for @lanSyncImportFailedMessage.
  ///
  /// In ko, this message translates to:
  /// **'가져오기에 실패했어요: {error}'**
  String lanSyncImportFailedMessage(Object error);

  /// No description provided for @createTabSelectedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택됨'**
  String createTabSelectedCount(int count);

  /// No description provided for @createTabDeleteSelectedConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯 삭제'**
  String get createTabDeleteSelectedConfirmTitle;

  /// No description provided for @createTabDeleteSelectedConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'선택한 플롯을 삭제할까요? 되돌릴 수 없어요.'**
  String get createTabDeleteSelectedConfirmContent;

  /// No description provided for @createTabExportPackageButton.
  ///
  /// In ko, this message translates to:
  /// **'패키지로 내보내기(.mzpack)'**
  String get createTabExportPackageButton;

  /// No description provided for @createTabExportPackageSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 플롯을 내보냈어요.'**
  String createTabExportPackageSuccessMessage(int count);

  /// No description provided for @createTabExportPackageFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'내보내기에 실패했어요: {error}'**
  String createTabExportPackageFailureMessage(Object error);

  /// No description provided for @createTabImportFromPackageTitle.
  ///
  /// In ko, this message translates to:
  /// **'플롯 패키지에서 가져오기(.mzpack)'**
  String get createTabImportFromPackageTitle;

  /// No description provided for @createTabImportFromPackageSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'여러 플롯을 한 번에 불러와요'**
  String get createTabImportFromPackageSubtitle;

  /// No description provided for @createTabImportPackageSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 플롯을 가져왔어요.'**
  String createTabImportPackageSuccessMessage(int count);

  /// No description provided for @conversationTabTalkLabel.
  ///
  /// In ko, this message translates to:
  /// **'톡'**
  String get conversationTabTalkLabel;

  /// No description provided for @characterDetailTalkButton.
  ///
  /// In ko, this message translates to:
  /// **'ZedTalk'**
  String get characterDetailTalkButton;

  /// No description provided for @talkListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 톡한 캐릭터가 없어요'**
  String get talkListEmpty;

  /// No description provided for @talkAttachmentSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'첨부'**
  String get talkAttachmentSheetTitle;

  /// No description provided for @talkAttachmentImageOption.
  ///
  /// In ko, this message translates to:
  /// **'이미지'**
  String get talkAttachmentImageOption;

  /// No description provided for @talkAttachmentVideoOption.
  ///
  /// In ko, this message translates to:
  /// **'동영상'**
  String get talkAttachmentVideoOption;

  /// No description provided for @talkAttachmentDocumentOption.
  ///
  /// In ko, this message translates to:
  /// **'문서'**
  String get talkAttachmentDocumentOption;

  /// No description provided for @talkVisionUnsupportedNote.
  ///
  /// In ko, this message translates to:
  /// **'이 프리셋은 이미지 인식을 지원하지 않아서, 첨부한 이미지는 AI에게 전달되지 않아요.'**
  String get talkVisionUnsupportedNote;

  /// No description provided for @talkPresetSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'사용할 AI 프리셋'**
  String get talkPresetSheetTitle;

  /// No description provided for @talkNoPresetMessage.
  ///
  /// In ko, this message translates to:
  /// **'먼저 AI 프리셋을 골라주세요.'**
  String get talkNoPresetMessage;

  /// No description provided for @talkDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'톡 삭제'**
  String get talkDeleteConfirmTitle;

  /// No description provided for @talkDeleteConfirmContent.
  ///
  /// In ko, this message translates to:
  /// **'선택한 톡을 삭제할까요? 되돌릴 수 없어요.'**
  String get talkDeleteConfirmContent;

  /// No description provided for @talkCharacterPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화할 캐릭터를 선택하세요'**
  String get talkCharacterPickerTitle;

  /// No description provided for @talkDrawerStartFreshTitle.
  ///
  /// In ko, this message translates to:
  /// **'새로 시작'**
  String get talkDrawerStartFreshTitle;

  /// No description provided for @talkDrawerStartFreshSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'새 톡방을 만들어요'**
  String get talkDrawerStartFreshSubtitle;

  /// No description provided for @talkDrawerResumeTitle.
  ///
  /// In ko, this message translates to:
  /// **'다른 톡방 보기'**
  String get talkDrawerResumeTitle;

  /// No description provided for @talkDrawerDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'톡방 삭제'**
  String get talkDrawerDeleteTitle;

  /// No description provided for @talkDrawerProfileTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필'**
  String get talkDrawerProfileTitle;

  /// No description provided for @talkDrawerChoicesTitle.
  ///
  /// In ko, this message translates to:
  /// **'선택지'**
  String get talkDrawerChoicesTitle;

  /// No description provided for @talkDrawerExitButton.
  ///
  /// In ko, this message translates to:
  /// **'톡방 나가기'**
  String get talkDrawerExitButton;

  /// No description provided for @talkResumeSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'다른 톡방'**
  String get talkResumeSheetTitle;

  /// No description provided for @talkResumeSheetEmpty.
  ///
  /// In ko, this message translates to:
  /// **'이 플롯의 다른 톡방이 없어요'**
  String get talkResumeSheetEmpty;

  /// No description provided for @talkSheetStartFreshFromHere.
  ///
  /// In ko, this message translates to:
  /// **'여기서 새로 시작'**
  String get talkSheetStartFreshFromHere;

  /// No description provided for @talkEditMessageTitle.
  ///
  /// In ko, this message translates to:
  /// **'메시지 수정'**
  String get talkEditMessageTitle;

  /// No description provided for @lorebookImportButtonTooltip.
  ///
  /// In ko, this message translates to:
  /// **'가져오기 (SillyTavern World Info / JanitorAI)'**
  String get lorebookImportButtonTooltip;

  /// No description provided for @lorebookExportButtonTooltip.
  ///
  /// In ko, this message translates to:
  /// **'SillyTavern World Info로 내보내기'**
  String get lorebookExportButtonTooltip;

  /// No description provided for @lorebookImportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 항목을 불러왔어요. 저장을 눌러야 실제로 반영돼요.'**
  String lorebookImportSuccessMessage(Object count);

  /// No description provided for @lorebookImportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'가져오기에 실패했어요: {error}'**
  String lorebookImportFailureMessage(Object error);

  /// No description provided for @lorebookExportSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'World Info JSON으로 내보냈어요.'**
  String get lorebookExportSuccessMessage;

  /// No description provided for @lorebookExportFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'내보내기에 실패했어요: {error}'**
  String lorebookExportFailureMessage(Object error);

  /// No description provided for @createTabImportTargetSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'가져올 위치를 선택하세요'**
  String get createTabImportTargetSheetTitle;

  /// No description provided for @createTabImportTargetNewPlot.
  ///
  /// In ko, this message translates to:
  /// **'새 플롯으로 만들기'**
  String get createTabImportTargetNewPlot;

  /// No description provided for @createTabImportLorebookTargetSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'로어북을 어떻게 추가할까요?'**
  String get createTabImportLorebookTargetSheetTitle;

  /// No description provided for @createTabImportLorebookTargetNew.
  ///
  /// In ko, this message translates to:
  /// **'새 로어북 만들기'**
  String get createTabImportLorebookTargetNew;

  /// No description provided for @myPageSummarySettingsButton.
  ///
  /// In ko, this message translates to:
  /// **'요약(장기 기억) 설정'**
  String get myPageSummarySettingsButton;

  /// No description provided for @summarySettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'요약(장기 기억) 설정'**
  String get summarySettingsTitle;

  /// No description provided for @summarySettingsDescription.
  ///
  /// In ko, this message translates to:
  /// **'AI 프리셋에 컨텍스트 길이(최근 메시지 개수 상한)를 설정해두면, 그 범위를 벗어나는 오래된 대화를 자동으로 요약해서 시스템 프롬프트에 함께 실어요. 여기서 이 기능을 끄거나, 요약 프롬프트/사용할 프리셋을 직접 고를 수 있어요.'**
  String get summarySettingsDescription;

  /// No description provided for @summarySettingsEnabledLabel.
  ///
  /// In ko, this message translates to:
  /// **'장기 기억 요약 사용'**
  String get summarySettingsEnabledLabel;

  /// No description provided for @summarySettingsPromptLabel.
  ///
  /// In ko, this message translates to:
  /// **'요약 프롬프트'**
  String get summarySettingsPromptLabel;

  /// No description provided for @summarySettingsPromptHint.
  ///
  /// In ko, this message translates to:
  /// **'비워두면 기본 프롬프트를 사용해요'**
  String get summarySettingsPromptHint;

  /// No description provided for @summarySettingsPresetLabel.
  ///
  /// In ko, this message translates to:
  /// **'요약에 사용할 프리셋'**
  String get summarySettingsPresetLabel;

  /// No description provided for @summarySettingsPresetDefaultOption.
  ///
  /// In ko, this message translates to:
  /// **'채팅과 동일한 프리셋 사용'**
  String get summarySettingsPresetDefaultOption;

  /// No description provided for @summarySettingsSaveButton.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get summarySettingsSaveButton;

  /// No description provided for @summarySettingsSavedMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장했어요.'**
  String get summarySettingsSavedMessage;

  /// No description provided for @vnEditAppBarTitleCreate.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨 만들기'**
  String get vnEditAppBarTitleCreate;

  /// No description provided for @vnEditAppBarTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨 편집'**
  String get vnEditAppBarTitleEdit;

  /// No description provided for @vnEditSaveButtonCreate.
  ///
  /// In ko, this message translates to:
  /// **'제작'**
  String get vnEditSaveButtonCreate;

  /// No description provided for @vnEditSaveButtonEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get vnEditSaveButtonEdit;

  /// No description provided for @vnEditSavedMessage.
  ///
  /// In ko, this message translates to:
  /// **'저장했어요'**
  String get vnEditSavedMessage;

  /// No description provided for @vnEditTitleRequiredMessage.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력해주세요'**
  String get vnEditTitleRequiredMessage;

  /// No description provided for @vnEditTabContents.
  ///
  /// In ko, this message translates to:
  /// **'콘텐츠'**
  String get vnEditTabContents;

  /// No description provided for @vnEditTabInfo.
  ///
  /// In ko, this message translates to:
  /// **'소개'**
  String get vnEditTabInfo;

  /// No description provided for @vnEditTabPlaySettings.
  ///
  /// In ko, this message translates to:
  /// **'플레이 설정'**
  String get vnEditTabPlaySettings;

  /// No description provided for @vnEditTitleFieldLabel.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get vnEditTitleFieldLabel;

  /// No description provided for @vnEditTitleFieldHint.
  ///
  /// In ko, this message translates to:
  /// **'플롯의 제목을 입력해주세요'**
  String get vnEditTitleFieldHint;

  /// No description provided for @vnEditCharCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}자'**
  String vnEditCharCountLabel(int count);

  /// No description provided for @vnEditWorldviewLabel.
  ///
  /// In ko, this message translates to:
  /// **'세계관'**
  String get vnEditWorldviewLabel;

  /// No description provided for @vnEditWorldviewHint.
  ///
  /// In ko, this message translates to:
  /// **'나만의 독창적인 세계관을 직접 써주세요'**
  String get vnEditWorldviewHint;

  /// No description provided for @vnEditHashtagsLabel.
  ///
  /// In ko, this message translates to:
  /// **'해시태그'**
  String get vnEditHashtagsLabel;

  /// No description provided for @vnEditHashtagAddButton.
  ///
  /// In ko, this message translates to:
  /// **'추가 {count}/10'**
  String vnEditHashtagAddButton(int count);

  /// No description provided for @vnEditAddHashtagDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'해시태그 추가'**
  String get vnEditAddHashtagDialogTitle;

  /// No description provided for @vnEditHashtagHint.
  ///
  /// In ko, this message translates to:
  /// **'# 없이 입력해주세요'**
  String get vnEditHashtagHint;

  /// No description provided for @vnEditCharactersSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'등장인물'**
  String get vnEditCharactersSectionTitle;

  /// No description provided for @vnEditCharactersEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'플롯을 함께 이끌어갈 인물들을 추가해 주세요'**
  String get vnEditCharactersEmptyMessage;

  /// No description provided for @vnEditAddCharacterButton.
  ///
  /// In ko, this message translates to:
  /// **'새 인물 추가'**
  String get vnEditAddCharacterButton;

  /// No description provided for @vnEditPlayableSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'플레이어블 캐릭터'**
  String get vnEditPlayableSectionTitle;

  /// No description provided for @vnEditPlayableEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'플레이어가 선택할 수 있는 플롯의 주인공을 만들어주세요'**
  String get vnEditPlayableEmptyMessage;

  /// No description provided for @vnEditSelectExistingCharacterButton.
  ///
  /// In ko, this message translates to:
  /// **'등장인물 중 선택'**
  String get vnEditSelectExistingCharacterButton;

  /// No description provided for @vnEditSelectExistingCharacterDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'등장인물 중 선택'**
  String get vnEditSelectExistingCharacterDialogTitle;

  /// No description provided for @vnEditSelectExistingCharacterEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'선택할 수 있는 등장인물이 없어요'**
  String get vnEditSelectExistingCharacterEmptyMessage;

  /// No description provided for @vnEditBackgroundsSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'배경'**
  String get vnEditBackgroundsSectionTitle;

  /// No description provided for @vnEditBackgroundsEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'플롯의 몰입도를 높여줄 배경을 만들어 주세요'**
  String get vnEditBackgroundsEmptyMessage;

  /// No description provided for @vnEditAddBackgroundButton.
  ///
  /// In ko, this message translates to:
  /// **'새 배경 추가'**
  String get vnEditAddBackgroundButton;

  /// No description provided for @vnEditAddBackgroundDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 배경 추가'**
  String get vnEditAddBackgroundDialogTitle;

  /// No description provided for @vnEditEditBackgroundDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'배경 수정'**
  String get vnEditEditBackgroundDialogTitle;

  /// No description provided for @vnEditBackgroundImageLabel.
  ///
  /// In ko, this message translates to:
  /// **'배경 이미지'**
  String get vnEditBackgroundImageLabel;

  /// No description provided for @vnEditBackgroundTitleLabel.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get vnEditBackgroundTitleLabel;

  /// No description provided for @vnEditBackgroundTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'예) 학교 교실_낮'**
  String get vnEditBackgroundTitleHint;

  /// No description provided for @vnEditSavePlotFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'제목과 세계관을 입력하고 상단의 저장 버튼을 눌러주세요'**
  String get vnEditSavePlotFirstMessage;

  /// No description provided for @vnEditDeleteCharacterConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 인물을 삭제할까요? 표정 이미지도 함께 삭제돼요.'**
  String get vnEditDeleteCharacterConfirmMessage;

  /// No description provided for @vnEditDeleteBackgroundConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 배경을 삭제할까요?'**
  String get vnEditDeleteBackgroundConfirmMessage;

  /// No description provided for @vnEditCharacterFormTitleCreate.
  ///
  /// In ko, this message translates to:
  /// **'새 인물'**
  String get vnEditCharacterFormTitleCreate;

  /// No description provided for @vnEditCharacterFormTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'인물 수정'**
  String get vnEditCharacterFormTitleEdit;

  /// No description provided for @vnEditCharacterNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get vnEditCharacterNameLabel;

  /// No description provided for @vnEditCharacterNameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해 주세요'**
  String get vnEditCharacterNameHint;

  /// No description provided for @vnEditCharacterShortDescLabel.
  ///
  /// In ko, this message translates to:
  /// **'짧은 설명'**
  String get vnEditCharacterShortDescLabel;

  /// No description provided for @vnEditCharacterShortDescHint.
  ///
  /// In ko, this message translates to:
  /// **'인물의 특징을 담은 짧은 소개를 적어 주세요'**
  String get vnEditCharacterShortDescHint;

  /// No description provided for @vnEditCharacterPersonaLabel.
  ///
  /// In ko, this message translates to:
  /// **'인물 설명'**
  String get vnEditCharacterPersonaLabel;

  /// No description provided for @vnEditCharacterPersonaHint.
  ///
  /// In ko, this message translates to:
  /// **'말투, 성격, 버릇처럼 AI가 인물을 표현할 때 참고할 특징을 적어 주세요'**
  String get vnEditCharacterPersonaHint;

  /// No description provided for @vnEditCharacterImageLabel.
  ///
  /// In ko, this message translates to:
  /// **'인물 이미지'**
  String get vnEditCharacterImageLabel;

  /// No description provided for @vnEditCharacterImagePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'전신 이미지 추가'**
  String get vnEditCharacterImagePlaceholder;

  /// No description provided for @vnEditSpritePlacementSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'인물 배치'**
  String get vnEditSpritePlacementSectionTitle;

  /// No description provided for @vnEditSpritePlacementPreviewEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'인물 이미지를 추가하면 미리볼 수 있어요'**
  String get vnEditSpritePlacementPreviewEmptyMessage;

  /// No description provided for @vnEditSpriteScaleLabel.
  ///
  /// In ko, this message translates to:
  /// **'크기 배율 {scale}x'**
  String vnEditSpriteScaleLabel(String scale);

  /// No description provided for @vnEditSpriteOffsetXLabel.
  ///
  /// In ko, this message translates to:
  /// **'가로 위치'**
  String get vnEditSpriteOffsetXLabel;

  /// No description provided for @vnEditSpriteOffsetYLabel.
  ///
  /// In ko, this message translates to:
  /// **'세로 위치'**
  String get vnEditSpriteOffsetYLabel;

  /// No description provided for @vnEditExpressionSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'표정 이미지 (선택)'**
  String get vnEditExpressionSectionTitle;

  /// No description provided for @vnEditExpressionSavePlotFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'먼저 인물을 저장하면 표정을 추가할 수 있어요'**
  String get vnEditExpressionSavePlotFirstMessage;

  /// No description provided for @vnEditExpressionAddTile.
  ///
  /// In ko, this message translates to:
  /// **'이미지 추가'**
  String get vnEditExpressionAddTile;

  /// No description provided for @vnEditExpressionJoy.
  ///
  /// In ko, this message translates to:
  /// **'기쁨'**
  String get vnEditExpressionJoy;

  /// No description provided for @vnEditExpressionSad.
  ///
  /// In ko, this message translates to:
  /// **'슬픔'**
  String get vnEditExpressionSad;

  /// No description provided for @vnEditExpressionAngry.
  ///
  /// In ko, this message translates to:
  /// **'분노'**
  String get vnEditExpressionAngry;

  /// No description provided for @vnEditExpressionWorried.
  ///
  /// In ko, this message translates to:
  /// **'걱정'**
  String get vnEditExpressionWorried;

  /// No description provided for @vnEditExpressionSurprised.
  ///
  /// In ko, this message translates to:
  /// **'놀람'**
  String get vnEditExpressionSurprised;

  /// No description provided for @vnEditExpressionConfused.
  ///
  /// In ko, this message translates to:
  /// **'의문'**
  String get vnEditExpressionConfused;

  /// No description provided for @vnEditExpressionDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 이미지'**
  String get vnEditExpressionDefault;

  /// No description provided for @vnEditCharacterPickEntryLabel.
  ///
  /// In ko, this message translates to:
  /// **'플레이어블 캐릭터 선택'**
  String get vnEditCharacterPickEntryLabel;

  /// No description provided for @vnEditCharacterPickEntryHint.
  ///
  /// In ko, this message translates to:
  /// **'인트로 재생 중 이 위치에서 플레이어가 캐릭터를 고릅니다. 드래그로 순서만 바꿀 수 있어요.'**
  String get vnEditCharacterPickEntryHint;

  /// No description provided for @vnEditIntroEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 작성된 턴이 없어요. 아래 버튼으로 첫 턴을 추가해보세요.'**
  String get vnEditIntroEmptyMessage;

  /// No description provided for @vnEditAddTurnButton.
  ///
  /// In ko, this message translates to:
  /// **'턴 추가하기'**
  String get vnEditAddTurnButton;

  /// No description provided for @vnEditSceneTypeDialogue.
  ///
  /// In ko, this message translates to:
  /// **'대화형'**
  String get vnEditSceneTypeDialogue;

  /// No description provided for @vnEditSceneTypeDirection.
  ///
  /// In ko, this message translates to:
  /// **'연출형'**
  String get vnEditSceneTypeDirection;

  /// No description provided for @vnEditSpeakerNarratorLabel.
  ///
  /// In ko, this message translates to:
  /// **'내레이터'**
  String get vnEditSpeakerNarratorLabel;

  /// No description provided for @vnEditNoChangeLabel.
  ///
  /// In ko, this message translates to:
  /// **'변화 없음'**
  String get vnEditNoChangeLabel;

  /// No description provided for @vnEditIntroContentHint.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력해주세요'**
  String get vnEditIntroContentHint;

  /// No description provided for @vnEditDirectionCaptionHint.
  ///
  /// In ko, this message translates to:
  /// **'짧은 연출 문구를 입력해주세요'**
  String get vnEditDirectionCaptionHint;

  /// No description provided for @vnEditChoicesSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'선택지 {count}/4'**
  String vnEditChoicesSectionTitle(int count);

  /// No description provided for @vnEditAddChoiceButton.
  ///
  /// In ko, this message translates to:
  /// **'선택지 추가'**
  String get vnEditAddChoiceButton;

  /// No description provided for @vnEditChoiceContentHint.
  ///
  /// In ko, this message translates to:
  /// **'선택지 내용을 입력해주세요'**
  String get vnEditChoiceContentHint;

  /// No description provided for @vnEditUseDiceLabel.
  ///
  /// In ko, this message translates to:
  /// **'주사위 사용'**
  String get vnEditUseDiceLabel;

  /// No description provided for @vnEditDifficultyEasy.
  ///
  /// In ko, this message translates to:
  /// **'쉬움'**
  String get vnEditDifficultyEasy;

  /// No description provided for @vnEditDifficultyMedium.
  ///
  /// In ko, this message translates to:
  /// **'중간'**
  String get vnEditDifficultyMedium;

  /// No description provided for @vnEditDifficultyHard.
  ///
  /// In ko, this message translates to:
  /// **'어려움'**
  String get vnEditDifficultyHard;

  /// No description provided for @vnEditCoverTitle.
  ///
  /// In ko, this message translates to:
  /// **'커버'**
  String get vnEditCoverTitle;

  /// No description provided for @vnEditCoverImagePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'커버 이미지'**
  String get vnEditCoverImagePlaceholder;

  /// No description provided for @vnEditShortIntroLabel.
  ///
  /// In ko, this message translates to:
  /// **'짧은 소개'**
  String get vnEditShortIntroLabel;

  /// No description provided for @vnEditShortIntroHint.
  ///
  /// In ko, this message translates to:
  /// **'제목과 함께 보일 짧은 소개를 입력해주세요'**
  String get vnEditShortIntroHint;

  /// No description provided for @vnEditPlaySettingsSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'플레이 방식'**
  String get vnEditPlaySettingsSectionTitle;

  /// No description provided for @vnEditInputModeLabel.
  ///
  /// In ko, this message translates to:
  /// **'기본 입력 방식'**
  String get vnEditInputModeLabel;

  /// No description provided for @vnEditInputModeChoice.
  ///
  /// In ko, this message translates to:
  /// **'선택지'**
  String get vnEditInputModeChoice;

  /// No description provided for @vnEditInputModeFreeText.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get vnEditInputModeFreeText;

  /// No description provided for @vnEditInputModeChoiceDescription.
  ///
  /// In ko, this message translates to:
  /// **'미리 준비된 선택지 중 하나를 골라 답변해요'**
  String get vnEditInputModeChoiceDescription;

  /// No description provided for @vnEditInputModeFreeTextDescription.
  ///
  /// In ko, this message translates to:
  /// **'플레이어가 직접 답변을 입력해요'**
  String get vnEditInputModeFreeTextDescription;

  /// No description provided for @vnEditAiAssistLabel.
  ///
  /// In ko, this message translates to:
  /// **'AI 입력 어시스트'**
  String get vnEditAiAssistLabel;

  /// No description provided for @vnEditAiAssistDescription.
  ///
  /// In ko, this message translates to:
  /// **'AI가 플레이어의 입력을 다듬어 주고, 플레이어블 캐릭터 이미지를 함께 표시해요.'**
  String get vnEditAiAssistDescription;

  /// No description provided for @vnEditDiceEventLabel.
  ///
  /// In ko, this message translates to:
  /// **'주사위 이벤트'**
  String get vnEditDiceEventLabel;

  /// No description provided for @vnEditDiceEventDescription.
  ///
  /// In ko, this message translates to:
  /// **'중요한 순간에 플레이어가 직접 주사위를 굴려요.\n결과에 따라 성공 여부가 결정돼요.'**
  String get vnEditDiceEventDescription;

  /// No description provided for @vnPlayAddPlayableCharacterCardTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 플레이어블\n캐릭터'**
  String get vnPlayAddPlayableCharacterCardTitle;

  /// No description provided for @vnPlayAiAssistTooltip.
  ///
  /// In ko, this message translates to:
  /// **'AI 입력 도움받기'**
  String get vnPlayAiAssistTooltip;

  /// No description provided for @vnPlayBackToChoicesButton.
  ///
  /// In ko, this message translates to:
  /// **'선택지로 돌아가기'**
  String get vnPlayBackToChoicesButton;

  /// No description provided for @vnPlayBackTooltip.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get vnPlayBackTooltip;

  /// No description provided for @vnPlayCancelGenerationTooltip.
  ///
  /// In ko, this message translates to:
  /// **'생성 중지'**
  String get vnPlayCancelGenerationTooltip;

  /// No description provided for @vnPlayCharacterPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'플레이할 캐릭터를 선택해주세요'**
  String get vnPlayCharacterPickerTitle;

  /// No description provided for @vnPlayDefaultCharacterName.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터'**
  String get vnPlayDefaultCharacterName;

  /// No description provided for @vnPlayDeleteSessionConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 대화를 삭제할까요? 되돌릴 수 없어요.'**
  String get vnPlayDeleteSessionConfirmMessage;

  /// No description provided for @vnPlayDeleteSessionMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get vnPlayDeleteSessionMenuItem;

  /// No description provided for @vnPlayDiceBonusLabel.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get vnPlayDiceBonusLabel;

  /// No description provided for @vnPlayDiceConfirmButton.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get vnPlayDiceConfirmButton;

  /// No description provided for @vnPlayDiceGoalLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get vnPlayDiceGoalLabel;

  /// No description provided for @vnPlayDiceResultDetail.
  ///
  /// In ko, this message translates to:
  /// **'{roll} + {bonus} = {total} / 목표 {target}'**
  String vnPlayDiceResultDetail(int roll, int bonus, int total, int target);

  /// No description provided for @vnPlayDiceResultFailure.
  ///
  /// In ko, this message translates to:
  /// **'실패...'**
  String get vnPlayDiceResultFailure;

  /// No description provided for @vnPlayDiceResultSuccess.
  ///
  /// In ko, this message translates to:
  /// **'성공!'**
  String get vnPlayDiceResultSuccess;

  /// No description provided for @vnPlayDiceRollButton.
  ///
  /// In ko, this message translates to:
  /// **'운명의 주사위를 던진다'**
  String get vnPlayDiceRollButton;

  /// No description provided for @vnPlayDiceSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'운명의 주사위'**
  String get vnPlayDiceSheetTitle;

  /// No description provided for @vnPlayDiceTargetLabel.
  ///
  /// In ko, this message translates to:
  /// **'성공 기준'**
  String get vnPlayDiceTargetLabel;

  /// No description provided for @vnPlayEditCharacterTooltip.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 수정'**
  String get vnPlayEditCharacterTooltip;

  /// No description provided for @vnPlayEmptyStateMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 이야기가 시작되지 않았어요'**
  String get vnPlayEmptyStateMessage;

  /// No description provided for @vnPlayFreeInputHint.
  ///
  /// In ko, this message translates to:
  /// **'행동이나 대사를 입력하세요...'**
  String get vnPlayFreeInputHint;

  /// No description provided for @vnPlayGenerateFailureMessage.
  ///
  /// In ko, this message translates to:
  /// **'이야기를 만드는 데 실패했어요: {error}'**
  String vnPlayGenerateFailureMessage(Object error);

  /// No description provided for @vnPlayGeneratingIndicator.
  ///
  /// In ko, this message translates to:
  /// **'이야기를 만드는 중...'**
  String get vnPlayGeneratingIndicator;

  /// No description provided for @vnPlayHistoryEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'아직 대화 기록이 없어요'**
  String get vnPlayHistoryEmptyMessage;

  /// No description provided for @vnPlayHistoryMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'히스토리 보기'**
  String get vnPlayHistoryMenuItem;

  /// No description provided for @vnPlayProfileMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필'**
  String get vnPlayProfileMenuItem;

  /// No description provided for @vnPlayProfileSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 프로필 선택'**
  String get vnPlayProfileSheetTitle;

  /// No description provided for @vnPlayProfileSheetEmpty.
  ///
  /// In ko, this message translates to:
  /// **'비주얼 노벨에서 쓸 수 있는 프로필이 없어요'**
  String get vnPlayProfileSheetEmpty;

  /// No description provided for @vnPlayHistoryNarratorLabel.
  ///
  /// In ko, this message translates to:
  /// **'내레이션'**
  String get vnPlayHistoryNarratorLabel;

  /// No description provided for @vnPlayHistoryCharacterPickLabel.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 선택'**
  String get vnPlayHistoryCharacterPickLabel;

  /// No description provided for @vnPlayHistorySheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 기록'**
  String get vnPlayHistorySheetTitle;

  /// No description provided for @vnPlayHistoryTooltip.
  ///
  /// In ko, this message translates to:
  /// **'히스토리'**
  String get vnPlayHistoryTooltip;

  /// No description provided for @vnPlayJumpToPlotDetailMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'플롯 상세페이지 바로가기'**
  String get vnPlayJumpToPlotDetailMenuItem;

  /// No description provided for @vnPlayManualInputToggle.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get vnPlayManualInputToggle;

  /// No description provided for @vnPlayPresetDropdownPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 선택'**
  String get vnPlayPresetDropdownPlaceholder;

  /// No description provided for @vnPlayPresetManageLink.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 설정'**
  String get vnPlayPresetManageLink;

  /// No description provided for @vnPlayPresetSheetDescription.
  ///
  /// In ko, this message translates to:
  /// **'선택한 프리셋의 설정으로 이야기가 진행돼요. 프리셋은 마이페이지에서 관리할 수 있어요.'**
  String get vnPlayPresetSheetDescription;

  /// No description provided for @vnPlayPresetSheetEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 만든 프리셋이 없어요'**
  String get vnPlayPresetSheetEmpty;

  /// No description provided for @vnPlayPresetSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 프리셋'**
  String get vnPlayPresetSheetTitle;

  /// No description provided for @vnPlayRegenerateSuggestionsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'다시 제안받기'**
  String get vnPlayRegenerateSuggestionsTooltip;

  /// No description provided for @vnPlaySelectCharacterButton.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get vnPlaySelectCharacterButton;

  /// No description provided for @vnPlaySelectPresetMessage.
  ///
  /// In ko, this message translates to:
  /// **'AI 프리셋을 먼저 선택해주세요'**
  String get vnPlaySelectPresetMessage;

  /// No description provided for @vnPlaySessionLoadFailedMessage.
  ///
  /// In ko, this message translates to:
  /// **'세션을 불러오지 못했어요'**
  String get vnPlaySessionLoadFailedMessage;

  /// No description provided for @vnPlaySettingsSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get vnPlaySettingsSheetTitle;

  /// No description provided for @vnPlaySettingsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get vnPlaySettingsTooltip;

  /// No description provided for @vnPlayStartFreshMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'새로하기'**
  String get vnPlayStartFreshMenuItem;

  /// No description provided for @vnPlayStepBackTooltip.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get vnPlayStepBackTooltip;

  /// No description provided for @vnPlayStepForwardTooltip.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get vnPlayStepForwardTooltip;

  /// No description provided for @vnPlaySuggestionEditTooltip.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get vnPlaySuggestionEditTooltip;

  /// No description provided for @vnPlaySuggestionsEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'제안할 선택지가 없어요'**
  String get vnPlaySuggestionsEmptyMessage;

  /// No description provided for @vnPlaySuggestionsLoadingLabel.
  ///
  /// In ko, this message translates to:
  /// **'다음 행동을 생각하는 중...'**
  String get vnPlaySuggestionsLoadingLabel;

  /// No description provided for @vnPlayUntitledPlotTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목 없음'**
  String get vnPlayUntitledPlotTitle;

  /// No description provided for @gamesHomeTitle.
  ///
  /// In ko, this message translates to:
  /// **'게임'**
  String get gamesHomeTitle;

  /// No description provided for @gamesHomeChessTitle.
  ///
  /// In ko, this message translates to:
  /// **'체스'**
  String get gamesHomeChessTitle;

  /// No description provided for @gamesHomeChessSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터와 겨루는 체스 한 판'**
  String get gamesHomeChessSubtitle;

  /// No description provided for @gamesHomeOmokTitle.
  ///
  /// In ko, this message translates to:
  /// **'오목'**
  String get gamesHomeOmokTitle;

  /// No description provided for @gamesHomeOmokSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'5개를 먼저 이으면 승리'**
  String get gamesHomeOmokSubtitle;

  /// No description provided for @gamesHomeUnoTitle.
  ///
  /// In ko, this message translates to:
  /// **'우노'**
  String get gamesHomeUnoTitle;

  /// No description provided for @gamesHomeUnoSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'손패를 먼저 비우면 승리'**
  String get gamesHomeUnoSubtitle;

  /// No description provided for @gamesHomeLiarsBarTitle.
  ///
  /// In ko, this message translates to:
  /// **'라이어스 바'**
  String get gamesHomeLiarsBarTitle;

  /// No description provided for @gamesHomeLiarsBarSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'블러핑으로 상대의 생명을 뺏는 카드 게임'**
  String get gamesHomeLiarsBarSubtitle;

  /// No description provided for @gamesHomeRecordSummary.
  ///
  /// In ko, this message translates to:
  /// **'{wins}승 {losses}패 {draws}무'**
  String gamesHomeRecordSummary(Object wins, Object losses, Object draws);

  /// No description provided for @gamesHomeNoRecord.
  ///
  /// In ko, this message translates to:
  /// **'아직 플레이 기록이 없어요'**
  String get gamesHomeNoRecord;

  /// No description provided for @gameOpponentPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'상대 캐릭터 선택'**
  String get gameOpponentPickerTitle;

  /// No description provided for @gameOpponentPickerDifficultyLabel.
  ///
  /// In ko, this message translates to:
  /// **'난이도'**
  String get gameOpponentPickerDifficultyLabel;

  /// No description provided for @gameOpponentPickerEmptyMessage.
  ///
  /// In ko, this message translates to:
  /// **'선택할 수 있는 캐릭터가 없어요.\n먼저 플롯에서 캐릭터를 만들어주세요'**
  String get gameOpponentPickerEmptyMessage;

  /// No description provided for @gameOpponentPickerUseLlmLabel.
  ///
  /// In ko, this message translates to:
  /// **'LLM으로 상대 판단'**
  String get gameOpponentPickerUseLlmLabel;

  /// No description provided for @gameOpponentPickerUseLlmDescription.
  ///
  /// In ko, this message translates to:
  /// **'켜면 CPU 알고리즘 대신 AI 프리셋(마이페이지 기본 프리셋)이 상대의 수를 판단해요. 실패하면 자동으로 기존 방식으로 진행돼요.'**
  String get gameOpponentPickerUseLlmDescription;

  /// No description provided for @gameOpponentPickerSpeakEveryMoveLabel.
  ///
  /// In ko, this message translates to:
  /// **'매 수마다 대사'**
  String get gameOpponentPickerSpeakEveryMoveLabel;

  /// No description provided for @gameOpponentPickerSpeakEveryMoveDescription.
  ///
  /// In ko, this message translates to:
  /// **'켜면 상대가 수를 둘 때마다 캐릭터 성격에 맞는 짧은 대사를 말해요.'**
  String get gameOpponentPickerSpeakEveryMoveDescription;

  /// No description provided for @gameYouLabel.
  ///
  /// In ko, this message translates to:
  /// **'나'**
  String get gameYouLabel;

  /// No description provided for @gameYourTurnLabel.
  ///
  /// In ko, this message translates to:
  /// **'내 차례'**
  String get gameYourTurnLabel;

  /// No description provided for @gameOpponentTurnLabel.
  ///
  /// In ko, this message translates to:
  /// **'상대 차례'**
  String get gameOpponentTurnLabel;

  /// No description provided for @gameResignButton.
  ///
  /// In ko, this message translates to:
  /// **'기권'**
  String get gameResignButton;

  /// No description provided for @gameResignConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'정말 기권할까요?'**
  String get gameResignConfirmMessage;

  /// No description provided for @gamePlayAgainButton.
  ///
  /// In ko, this message translates to:
  /// **'다시하기'**
  String get gamePlayAgainButton;

  /// No description provided for @gameBackToListButton.
  ///
  /// In ko, this message translates to:
  /// **'게임 목록으로'**
  String get gameBackToListButton;

  /// No description provided for @gameYouWinTitle.
  ///
  /// In ko, this message translates to:
  /// **'승리!'**
  String get gameYouWinTitle;

  /// No description provided for @gameYouLoseTitle.
  ///
  /// In ko, this message translates to:
  /// **'패배'**
  String get gameYouLoseTitle;

  /// No description provided for @gameDrawTitle.
  ///
  /// In ko, this message translates to:
  /// **'무승부'**
  String get gameDrawTitle;

  /// No description provided for @chessCheckLabel.
  ///
  /// In ko, this message translates to:
  /// **'체크'**
  String get chessCheckLabel;

  /// No description provided for @chessCheckmateMessage.
  ///
  /// In ko, this message translates to:
  /// **'체크메이트예요'**
  String get chessCheckmateMessage;

  /// No description provided for @chessStalemateMessage.
  ///
  /// In ko, this message translates to:
  /// **'스테일메이트, 무승부예요'**
  String get chessStalemateMessage;

  /// No description provided for @chessPromotionTitle.
  ///
  /// In ko, this message translates to:
  /// **'승진시킬 기물을 고르세요'**
  String get chessPromotionTitle;

  /// No description provided for @chessCapturedByYouLabel.
  ///
  /// In ko, this message translates to:
  /// **'내가 잡은 기물'**
  String get chessCapturedByYouLabel;

  /// No description provided for @chessCapturedByOpponentLabel.
  ///
  /// In ko, this message translates to:
  /// **'상대가 잡은 기물'**
  String get chessCapturedByOpponentLabel;

  /// No description provided for @omokWinMessage.
  ///
  /// In ko, this message translates to:
  /// **'5개를 이었어요!'**
  String get omokWinMessage;

  /// No description provided for @unoYourHandLabel.
  ///
  /// In ko, this message translates to:
  /// **'내 손패'**
  String get unoYourHandLabel;

  /// No description provided for @unoOpponentHandLabel.
  ///
  /// In ko, this message translates to:
  /// **'상대 손패'**
  String get unoOpponentHandLabel;

  /// No description provided for @unoDrawPileTooltip.
  ///
  /// In ko, this message translates to:
  /// **'카드 뽑기'**
  String get unoDrawPileTooltip;

  /// No description provided for @unoChooseColorTitle.
  ///
  /// In ko, this message translates to:
  /// **'낼 색상을 고르세요'**
  String get unoChooseColorTitle;

  /// No description provided for @unoUnoCalloutLabel.
  ///
  /// In ko, this message translates to:
  /// **'UNO!'**
  String get unoUnoCalloutLabel;

  /// No description provided for @unoCannotPlayMessage.
  ///
  /// In ko, this message translates to:
  /// **'낼 수 있는 카드가 없어서 한 장 뽑았어요'**
  String get unoCannotPlayMessage;

  /// No description provided for @liarsBarTargetCardLabel.
  ///
  /// In ko, this message translates to:
  /// **'이번 라운드 목표 카드'**
  String get liarsBarTargetCardLabel;

  /// No description provided for @liarsBarYourHandLabel.
  ///
  /// In ko, this message translates to:
  /// **'내 손패'**
  String get liarsBarYourHandLabel;

  /// No description provided for @liarsBarSelectHint.
  ///
  /// In ko, this message translates to:
  /// **'낼 카드를 1~3장 골라주세요'**
  String get liarsBarSelectHint;

  /// No description provided for @liarsBarPlayButton.
  ///
  /// In ko, this message translates to:
  /// **'제출'**
  String get liarsBarPlayButton;

  /// No description provided for @liarsBarBelieveButton.
  ///
  /// In ko, this message translates to:
  /// **'믿는다'**
  String get liarsBarBelieveButton;

  /// No description provided for @liarsBarChallengeButton.
  ///
  /// In ko, this message translates to:
  /// **'의심한다'**
  String get liarsBarChallengeButton;

  /// No description provided for @liarsBarRevealTrueMessage.
  ///
  /// In ko, this message translates to:
  /// **'진짜였어요'**
  String get liarsBarRevealTrueMessage;

  /// No description provided for @liarsBarRevealBluffMessage.
  ///
  /// In ko, this message translates to:
  /// **'블러핑이었어요'**
  String get liarsBarRevealBluffMessage;

  /// No description provided for @liarsBarLifeLabel.
  ///
  /// In ko, this message translates to:
  /// **'생명'**
  String get liarsBarLifeLabel;

  /// No description provided for @liarsBarOpponentClaimLabel.
  ///
  /// In ko, this message translates to:
  /// **'상대가 {count}장을 냈어요'**
  String liarsBarOpponentClaimLabel(Object count);
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
