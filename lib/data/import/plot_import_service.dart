import '../db/database.dart';
import '../local_image_store.dart';
import '../repositories/character_repository.dart';
import '../repositories/intro_entry_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_repository.dart';
import 'character_card_parser.dart';

/// [PlotImportService.importAsNewPlot]의 결과. 생성된 plotId와 함께, 카드에 실제로
/// 오프닝(첫 메시지/대안 인사말)이나 로어북 데이터가 있었는지를 알려준다.
/// 일부 카드(특히 "시나리오/RPG" 성향 카드)는 원본부터 오프닝이 비어있을 수 있는데,
/// 이걸 화면에서 구분해 안내할 수 있도록 한다.
class PlotImportResult {
  const PlotImportResult({required this.plotId, required this.hadIntro, required this.hadLorebook});

  final int plotId;
  final bool hadIntro;
  final bool hadLorebook;
}

/// 파싱된 SillyTavern 카드를 실제 플롯/캐릭터/인트로/로어북 레코드로 저장한다.
///
/// 매핑 규칙:
/// - Plot.title/Character.name: 카드 이름(각각 20/10자 제한에 맞춰 자름)
/// - Plot.description: scenario가 있으면 scenario, 없으면 description
/// - Character.description: description + personality + mes_example(대화 예시)
/// - first_mes: 기본 인트로 버전의 캐릭터 발화 한 줄, alternate_greetings: 추가 인트로 버전들
///   (플롯의 '인트로 여러 버전(대안 오프닝)' 기능과 정확히 대응된다)
/// - character_book: 새 로어북을 만들어 이 플롯에 연결
class PlotImportService {
  PlotImportService(AppDatabase db)
      : _plotRepository = PlotRepository(db),
        _characterRepository = CharacterRepository(db),
        _introRepository = IntroEntryRepository(db),
        _lorebookRepository = LorebookRepository(db),
        _imageStore = LocalImageStore();

  final PlotRepository _plotRepository;
  final CharacterRepository _characterRepository;
  final IntroEntryRepository _introRepository;
  final LorebookRepository _lorebookRepository;
  final LocalImageStore _imageStore;

  static const _titleMaxLength = 20;
  static const _nameMaxLength = 10;
  static const _shortIntroMaxLength = 40;
  static const _maxHashtags = 10;

  /// 새 플롯으로 저장하고 결과(plotId + 무엇을 가져왔는지)를 반환한다.
  Future<PlotImportResult> importAsNewPlot(ParsedCharacterCard card) async {
    final characterName = _truncate(card.name, _nameMaxLength);

    String? imagePath;
    final avatarBytes = card.avatarBytes;
    if (avatarBytes != null) {
      imagePath = await _imageStore.saveBytes('card', avatarBytes);
    }

    final plotDescription = card.scenario.isNotEmpty
        ? card.scenario
        : (card.description.isNotEmpty ? card.description : '(가져온 캐릭터 카드)');

    final plotId = await _plotRepository.upsertPlot(
      title: _truncate(card.name, _titleMaxLength),
      description: plotDescription,
      shortIntro: _truncate(card.creatorNotes, _shortIntroMaxLength),
      hashtags: card.tags.take(_maxHashtags).toList(),
      coverImagePath: imagePath,
    );

    final characterId = await _characterRepository.add(
      plotId: plotId,
      name: characterName.isEmpty ? '캐릭터 1' : characterName,
      description: _buildCharacterDescription(card),
      imagePath: imagePath,
      isRepresentative: true,
      sortOrder: 0,
    );

    final hadIntro = await _importIntro(plotId, characterId, characterName, card);
    final hadLorebook = await _importLorebook(plotId, card);

    return PlotImportResult(plotId: plotId, hadIntro: hadIntro, hadLorebook: hadLorebook);
  }

  /// 인트로를 실제로 만들었으면 true, 카드에 오프닝이 아예 없어서 건너뛰었으면 false.
  Future<bool> _importIntro(
    int plotId,
    int characterId,
    String characterName,
    ParsedCharacterCard card,
  ) async {
    final greetings = [
      if (card.firstMessage.isNotEmpty) card.firstMessage,
      ...card.alternateGreetings,
    ];
    if (greetings.isEmpty) return false;

    final firstVersionId = await _introRepository.ensureDefaultVersion(plotId);
    await _introRepository.add(
      plotId: plotId,
      introVersionId: firstVersionId,
      characterId: characterId,
      type: IntroEntryType.character,
      content: _applyPlaceholders(greetings.first, characterName),
    );

    for (final greeting in greetings.skip(1)) {
      final versionId = await _introRepository.addVersion(plotId);
      await _introRepository.add(
        plotId: plotId,
        introVersionId: versionId,
        characterId: characterId,
        type: IntroEntryType.character,
        content: _applyPlaceholders(greeting, characterName),
      );
    }
    return true;
  }

  /// 로어북을 실제로 만들었으면 true, 카드에 character_book이 없어서 건너뛰었으면 false.
  Future<bool> _importLorebook(int plotId, ParsedCharacterCard card) async {
    if (card.loreEntries.isEmpty) return false;
    final bookName = card.bookName?.trim() ?? '';
    final title = bookName.isNotEmpty ? bookName : '${card.name} 세계관';
    final lorebookId = await _lorebookRepository.upsert(title: title);
    for (final entry in card.loreEntries) {
      final entryId = await _lorebookRepository.addEntry(lorebookId);
      await _lorebookRepository.updateEntry(
        id: entryId,
        title: entry.name ?? '',
        keywords: entry.keys.join(','),
        content: entry.content,
      );
    }
    await _lorebookRepository.setLorebookLinksForPlot(plotId, {lorebookId});
    return true;
  }

  String _buildCharacterDescription(ParsedCharacterCard card) {
    final parts = <String>[];
    if (card.description.isNotEmpty) parts.add(card.description);
    if (card.personality.isNotEmpty) parts.add('[성격]\n${card.personality}');
    if (card.exampleDialogue.isNotEmpty) {
      parts.add('[대화 예시]\n${_cleanExampleDialogue(card.exampleDialogue)}');
    }
    return parts.join('\n\n');
  }

  String _cleanExampleDialogue(String raw) {
    return raw.replaceAll(RegExp('<START>', caseSensitive: false), '').trim();
  }

  /// SillyTavern의 `{{char}}`/`<BOT>`은 이 시점에 실제 캐릭터 이름으로 바꿔 넣는다.
  /// `{{user}}`/`<USER>`는 채팅 화면이 대화 프로필 이름으로 실시간 치환하므로 `{{user}}`
  /// 형태로만 통일해서 남겨둔다.
  String _applyPlaceholders(String text, String characterName) {
    final name = characterName.isEmpty ? '캐릭터' : characterName;
    return text
        .replaceAll(RegExp('\\{\\{char\\}\\}', caseSensitive: false), name)
        .replaceAll(RegExp('<BOT>', caseSensitive: false), name)
        .replaceAll(RegExp('<USER>', caseSensitive: false), '{{user}}');
  }

  String _truncate(String text, int maxLength) {
    final trimmed = text.trim();
    return trimmed.length <= maxLength ? trimmed : trimmed.substring(0, maxLength);
  }
}
