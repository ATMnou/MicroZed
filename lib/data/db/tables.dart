import 'package:drift/drift.dart';

/// 플롯 공개 범위. UI의 공개/비공개/미등록 필터와 대응한다.
enum PlotVisibility { public, private, unlisted }

/// 인트로(첫 상황) 한 줄이 누구의 발화인지 구분한다. image는 AI에게는 전달되지 않고
/// 화면에만 보여주는 첨부 이미지 한 장이다.
enum IntroEntryType { character, narrator, user, image }

/// 실제 채팅 메시지의 발화자 종류. image는 AI에게는 전달되지 않고 화면에만 보여준다.
enum MessageSender { character, narrator, user, image }

/// AI 프리셋이 어떤 요청/응답 형식을 쓰는 엔드포인트인지. openAiCompatible이 기본값이고,
/// anthropic은 Anthropic Messages API(`/v1/messages`, system 필드 분리, `x-api-key` 헤더) 전용
/// 클라이언트로 라우팅된다.
enum AiEndpointFormat { openAiCompatible, anthropic }

/// 플롯의 진행 방식. storyChat이 기본(채팅 말풍선 형태)이고, visualNovel은 배경+인물
/// 일러스트 위에 대사창을 띄우는 비주얼 노벨 형태다. 둘 다 Plots/Characters/ChatSessions/
/// ChatTurns/ChatMessages를 그대로 공유하고, visualNovel 전용 데이터(배경/표정/선택지)만
/// 아래 Vn* 테이블에 별도로 붙는다.
enum PlotType { storyChat, visualNovel }

/// 비주얼 노벨 캐릭터 표정 세트의 고정 6종. 기본 전신 이미지가 없는 감정은 캐릭터의
/// 기본 imagePath로 대체 표시한다.
enum VnEmotion { joy, sad, angry, worried, surprised, confused }

/// 비주얼 노벨 인트로 한 턴이 '대화형'(배경+캐릭터+대사)인지 '연출형'(나레이션+선택 이미지)인지.
enum VnSceneType { dialogue, direction }

/// 비주얼 노벨 플레이 설정의 기본 입력 방식. choice면 선택지 버튼 중심, freeText면 직접 입력 중심.
enum VnInputMode { choice, freeText }

/// 비주얼 노벨 선택지에 주사위를 쓸 때의 난이도. 성공 기준치(목표 눈금)를 결정한다.
enum VnDiceDifficulty { easy, medium, hard }

/// ZedTalk(짧은 메신저형 대화) 메시지의 발화자. 롤플레이 채팅과 달리 나레이터가 없다.
enum TalkMessageSender { user, character }

/// ZedTalk 메시지에 첨부할 수 있는 미디어 종류. 비전을 지원하는 프리셋에서만 image가
/// 실제로 AI에게 전달되고, 나머지는 화면에만 보여준다.
enum TalkAttachmentType { image, video, document }

/// 플롯(캐릭터 세트 + 프롬프트 + 소개). 제작 탭의 플롯 목록, 캐릭터 상세 화면, 플롯 편집 화면이 다루는 핵심 엔티티.
class Plots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get shortIntro => text().nullable()();
  TextColumn get hashtags => text().withDefault(const Constant(''))();
  IntColumn get visibility =>
      intEnum<PlotVisibility>().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// storyChat(기본) 또는 visualNovel. 제작 탭 플롯 생성 시 고르고, 이후에는 바꾸지 않는다.
  IntColumn get plotType => intEnum<PlotType>().withDefault(const Constant(0))();

  /// 아래 3개는 plotType이 visualNovel일 때만 의미가 있다(플레이 설정 탭).
  IntColumn get vnInputMode => intEnum<VnInputMode>().withDefault(const Constant(0))();
  BoolColumn get vnAiInputAssist => boolean().withDefault(const Constant(false))();
  BoolColumn get vnDiceEnabled => boolean().withDefault(const Constant(true))();
}

/// 비주얼 노벨 플롯의 배경 이미지 라이브러리. 인트로/AI 응답의 씬 전환 태그가 title로
/// 이 테이블을 찾아 배경을 바꾼다.
class VnBackgrounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get imagePath => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// 캐릭터(플레이어블 포함)의 감정별 전신 이미지. 없는 감정은 Character.imagePath(기본 이미지)로
/// 대체된다.
class VnCharacterExpressions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId =>
      integer().references(Characters, #id, onDelete: KeyAction.cascade)();
  IntColumn get emotion => intEnum<VnEmotion>()();
  TextColumn get imagePath => text()();
}

/// 비주얼 노벨 인트로 버전에 붙는 선택지. 선택지 자체는 IntroEntries가 아니라 IntroVersions에
/// 바로 붙는다(대화형/연출형 턴들을 다 보여준 다음, 첫 행동을 고르는 화면이라서).
class VnChoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get introVersionId =>
      integer().references(IntroVersions, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get useDice => boolean().withDefault(const Constant(false))();
  IntColumn get difficulty => intEnum<VnDiceDifficulty>().nullable()();
}

/// 플롯에 속한 캐릭터. 플롯 1개에 여러 캐릭터가 붙을 수 있다(대표 캐릭터 1개 포함).
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isRepresentative =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 플롯 편집 > 소개 탭에서 캐릭터별로 작성하는 상세 페이지용 소개 마크다운.
  /// AI에게는 전달되지 않고 상세 페이지 표시 전용이다(AI용 페르소나는 [description]).
  TextColumn get aboutText => text().withDefault(const Constant(''))();

  /// 비주얼 노벨 플롯에서만 의미가 있다. true면 '플레이어블 캐릭터'(플레이어가 빙의해서
  /// 진행하는 주인공 후보)로 취급된다.
  BoolColumn get isPlayable => boolean().withDefault(const Constant(false))();
}

/// 플롯 하나에 여러 개 만들 수 있는 인트로(첫 상황) 버전. 채팅 시작 시 어떤 버전으로
/// 시작할지 '<, >'로 넘겨볼 수 있다(ChatTurns/versionIndex 메커니즘 재사용).
class IntroVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 플롯 편집 > 인트로 탭에서 구성하는 '첫 상황' 한 줄 한 줄. introVersionId로 어떤
/// 인트로 버전에 속하는지 구분한다(plotId는 예전 스키마와의 호환을 위해 남겨둔다).
/// characterId가 null이면 나레이터/유저 줄이고, type으로 구분한다.
class IntroEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  IntColumn get introVersionId => integer()
      .nullable()
      .references(IntroVersions, #id, onDelete: KeyAction.cascade)();
  IntColumn get characterId => integer()
      .nullable()
      .references(Characters, #id, onDelete: KeyAction.cascade)();
  IntColumn get type => intEnum<IntroEntryType>()();
  TextColumn get content => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 아래 3개는 plotType이 visualNovel인 플롯의 인트로 줄에서만 쓰인다.
  IntColumn get vnBackgroundId => integer()
      .nullable()
      .references(VnBackgrounds, #id, onDelete: KeyAction.setNull)();
  IntColumn get vnExpression => intEnum<VnEmotion>().nullable()();
  IntColumn get vnSceneType => intEnum<VnSceneType>().withDefault(const Constant(0))();
}

/// 세션마다 하나씩 쌓이는 장기 기억(오래된 대화 요약). [coveredUpToMessageId]는 이 요약이
/// 몇 번째 메시지까지 반영했는지를 가리킨다 - 컨텍스트 길이 제한으로 더 많은 메시지가
/// 잘려나갈 때마다, 잘려나간 구간 전체를 다시 요약해서 이 값과 함께 갱신한다(세션당 1행,
/// 누적/재요약 방식이라 별도 버전 이력은 두지 않는다).
class ChatMemorySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ChatSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get coveredUpToMessageId => integer()();
  TextColumn get summaryText => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 마이페이지 > 대화 프로필 편집에서 관리하는, 유저가 대화에서 사용할 프로필.
class ConversationProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

/// 플롯 편집 > 프롬프트 탭에서 그 플롯 전용으로 만드는 대화 프로필. 마이페이지의 전역
/// [ConversationProfiles]와는 완전히 별개이고, 개수 제한이 없다.
class PlotConversationProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 20)();

  /// true면 [name]을 직접 쓰지 않고, 표시할 때마다 전역 기본 프로필의 이름을 그대로 가져와
  /// 보여준다(전역 기본 프로필이 바뀌면 이 프로필의 이름도 같이 바뀐다).
  BoolColumn get useGlobalName => boolean().withDefault(const Constant(false))();

  /// 카드/목록에 보여주는 한 줄 소개. AI에게는 전달되지 않는다(표시 전용).
  TextColumn get shortIntro => text().withLength(min: 1, max: 50)();

  /// 캐릭터 설명처럼 AI에게 그대로 전달되는 유저 페르소나 설명.
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// BYOK AI 프리셋. 실제 API 키는 저장하지 않고 secure storage 참조 키(apiKeyRef)만 둔다.
class AiPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get baseUrl => text()();
  TextColumn get modelName => text()();
  TextColumn get apiKeyRef => text().nullable()();
  RealColumn get temperature => real().withDefault(const Constant(1.0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// 아래 4개는 전부 선택 사항이다(null/빈 문자열이면 요청에 포함하지 않거나 기본 동작).
  IntColumn get topK => integer().nullable()();
  IntColumn get maxTokens => integer().nullable()();

  /// 매 요청마다 히스토리에 포함할 최근 메시지 개수 상한. null이면 전체를 보낸다.
  IntColumn get contextLength => integer().nullable()();

  /// 시스템 프롬프트 뒤에 그대로 덧붙이는 사용자 정의 지침. 기본값은 빈 문자열.
  TextColumn get additionalSystemPrompt => text().withDefault(const Constant(''))();

  /// true면 원격 API가 아니라 기기에 내장된 로컬 LLM(llama.cpp)으로 추론한다.
  /// 이 경우 baseUrl/apiKeyRef는 쓰지 않고 [localModelSource]만 사용한다.
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();

  /// null(끔) 또는 'low'/'medium'/'high'. 원격 요청에는 `reasoning_effort`로 그대로 실어 보내고,
  /// 로컬 모델에는 사고(thinking) 모드를 켜고 이 값에 비례한 토큰 예산을 준다.
  TextColumn get reasoningEffort => text().nullable()();

  /// 로컬 모델의 위치. `hf://...` (다운로드 후 캐시된 모델) 또는 로컬 파일 경로.
  TextColumn get localModelSource => text().nullable()();

  /// 아래 3개는 baseUrl이 openrouter.ai일 때만 UI에 노출되는 OpenRouter 전용 라우팅 옵션.
  /// OpenRouter의 `provider` 요청 필드로 그대로 실어 보낸다.
  /// ZDR(Zero Data Retention) 정책을 지키는 제공자로만 라우팅을 강제한다.
  BoolColumn get openRouterZdrOnly => boolean().withDefault(const Constant(false))();

  /// 알려진 중국 소재 제공자(알리바바 등)를 라우팅에서 제외한다.
  BoolColumn get openRouterExcludeChinaProviders => boolean().withDefault(const Constant(false))();

  /// 요청 데이터를 학습에 활용할 수 있는 제공자를 라우팅에서 제외한다.
  BoolColumn get openRouterExcludeTrainingProviders => boolean().withDefault(const Constant(false))();

  /// 기본값(openAiCompatible)이면 기존과 동일하게 동작한다. [isLocal]이 true면 이 값은
  /// 무시되고 로컬 llama.cpp 엔진으로 라우팅된다.
  IntColumn get endpointFormat =>
      intEnum<AiEndpointFormat>().withDefault(const Constant(0))();

  /// ZedTalk에서 이미지 첨부를 실제로 모델에 보낼지. 사용자가 고른 모델이 비전을
  /// 지원하는지 앱이 자동으로 알 방법이 없어서(모델명만으로는 신뢰할 수 없음) 수동 토글이다.
  BoolColumn get supportsVision => boolean().withDefault(const Constant(false))();
}

/// ZedTalk 대화방. 롤플레이용 [ChatSessions]과 별개로, 플롯당 여러 개 만들 수 있다
/// (롤플레이는 플롯당 활성 세션이 1개뿐이지만 ZedTalk은 그런 제약이 없다).
class TalkSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId => integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  IntColumn get presetId => integer().nullable().references(AiPresets, #id, onDelete: KeyAction.setNull)();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// 이 방의 상대 캐릭터. null이면 예전처럼 plot의 대표 캐릭터로 폴백한다
  /// (스키마 v17 이전에 만들어진 세션 대응용).
  IntColumn get characterId => integer().nullable().references(Characters, #id, onDelete: KeyAction.setNull)();

  /// [ChatSessions]와 동일하게 전역 프로필/플롯 전용 프로필 중 하나만 값이 있을 수 있다.
  IntColumn get conversationProfileId =>
      integer().nullable().references(ConversationProfiles, #id, onDelete: KeyAction.setNull)();
  IntColumn get plotConversationProfileId =>
      integer().nullable().references(PlotConversationProfiles, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// ChatMessages와 달리 턴/버전 개념이 없는 단순한 메시지 하나. 재시도/AI 수정 없이
/// 보낸 순서 그대로 쌓인다.
class TalkMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(TalkSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sender => intEnum<TalkMessageSender>()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get attachmentPath => text().nullable()();
  IntColumn get attachmentType => intEnum<TalkAttachmentType>().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 대화 탭에 나열되는 개별 대화방. 어떤 플롯/프로필/프리셋으로 진행 중인지를 연결한다.
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
  IntColumn get conversationProfileId => integer()
      .nullable()
      .references(ConversationProfiles, #id, onDelete: KeyAction.setNull)();

  /// [conversationProfileId](전역 프로필)와는 동시에 값이 있을 수 없다 - 둘 중 하나만 쓴다.
  IntColumn get plotConversationProfileId => integer()
      .nullable()
      .references(PlotConversationProfiles, #id, onDelete: KeyAction.setNull)();
  IntColumn get presetId => integer()
      .nullable()
      .references(AiPresets, #id, onDelete: KeyAction.setNull)();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// null이면 현재 진행 중인 활성 대화. 값이 있으면 '새로하기'로 저장되어 '이어하기'
  /// 목록에만 노출되는 보관된 대화이며, 값은 저장된 시각이다.
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// 비주얼 노벨 플롯에서만 쓰인다. 플레이어가 시작할 때 고른 플레이어블 캐릭터
  /// (Characters.isPlayable = true인 행). null이면 아직 안 골랐거나 스토리챗 플롯이다.
  IntColumn get vnPlayableCharacterId =>
      integer().nullable().references(Characters, #id, onDelete: KeyAction.setNull)();
}

/// AI 응답(또는 인트로) 한 턴. 재시도/AI 수정으로 만들어지는 여러 '버전'을 묶는 단위이고,
/// 인트로 여러 버전을 시작 시 넘겨보는 것도 이 메커니즘을 그대로 재사용한다.
class ChatTurns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ChatSessions, #id, onDelete: KeyAction.cascade)();

  /// 지금 화면에 보여줄 버전 번호(0부터 시작). '<, >'로 넘길 때 이 값만 바뀐다.
  IntColumn get activeVersionIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 채팅 화면에 렌더링되는 실제 메시지.
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(ChatSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get senderType => intEnum<MessageSender>()();
  IntColumn get characterId => integer()
      .nullable()
      .references(Characters, #id, onDelete: KeyAction.setNull)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// AI가 등장시켰지만 등록된 캐릭터와 매칭되지 않은 발화자의 원문 이름.
  /// characterId가 null일 때 표시용으로만 쓴다(예: 즉석에서 등장한 새 인물).
  TextColumn get speakerNameOverride => text().nullable()();

  /// null이면 유저가 직접 입력한 메시지. 값이 있으면 AI 응답(또는 인트로)의 한 말풍선이며,
  /// 같은 turnId 안에서 versionIndex로 재시도/AI 수정 버전을, turnSortOrder로 한 버전
  /// 안에서의 말풍선 순서를 구분한다.
  IntColumn get turnId => integer()
      .nullable()
      .references(ChatTurns, #id, onDelete: KeyAction.cascade)();
  IntColumn get versionIndex => integer().withDefault(const Constant(0))();
  IntColumn get turnSortOrder => integer().withDefault(const Constant(0))();

  /// 아래 2개는 plotType이 visualNovel인 플롯의 메시지에서만 쓰인다. AI 응답의 씬 태그
  /// ([SCENE bg=... expr=...])를 파싱해서 채워 넣는다 - 화면에 어떤 배경/표정을 보여줄지 결정한다.
  IntColumn get vnBackgroundId => integer()
      .nullable()
      .references(VnBackgrounds, #id, onDelete: KeyAction.setNull)();
  IntColumn get vnExpression => intEnum<VnEmotion>().nullable()();
}

/// AI 응답 1회당 소모한 토큰(+ 알 수 있으면 가격) 기록. 프리셋이 나중에 삭제/수정돼도
/// 내역이 남아야 하므로 FK 없이 요청 당시의 이름/baseUrl/모델명을 그대로 스냅샷으로 남긴다.
class TokenUsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get presetName => text()();
  TextColumn get baseUrl => text()();
  TextColumn get modelName => text()();
  IntColumn get promptTokens => integer().withDefault(const Constant(0))();
  IntColumn get completionTokens => integer().withDefault(const Constant(0))();

  /// 엔드포인트가 가격을 알려줄 때만(예: OpenRouter) 값이 있다. USD 기준.
  RealColumn get costUsd => real().nullable()();

  /// OpenRouter처럼 여러 업스트림으로 라우팅하는 엔드포인트가 실제로 요청을 처리한
  /// 제공자명을 알려줄 때만 값이 있다(예: "DeepInfra"). 없으면 baseUrl host로 대체 표시.
  TextColumn get provider => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 제작 탭의 '로어북'. 여러 플롯에 연결해서 키워드가 언급될 때마다 내용을 AI에게
/// 전달하는 세계관/설정 모음집. 소개글(title/shortIntro)은 관리용일 뿐 AI에게 전달되지 않는다.
class Lorebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get shortIntro => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 로어북 안의 항목 하나. keywords는 콤마로 join해서 저장한다.
/// 키워드가 대화에서 언급되면 content가 AI 시스템 프롬프트에 실린다.
class LorebookEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lorebookId =>
      integer().references(Lorebooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get keywords => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// 로어북 ↔ 플롯 다대다 연결.
class LorebookPlotLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lorebookId =>
      integer().references(Lorebooks, #id, onDelete: KeyAction.cascade)();
  IntColumn get plotId =>
      integer().references(Plots, #id, onDelete: KeyAction.cascade)();
}
