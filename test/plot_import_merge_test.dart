import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/import/character_card_parser.dart';
import 'package:microzed/data/import/plot_import_service.dart';
import 'package:microzed/data/repositories/character_repository.dart';
import 'package:microzed/data/repositories/lorebook_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';

void main() {
  test('mergeIntoPlot은 기존 캐릭터/로어북 링크를 지우지 않고 새 캐릭터를 추가한다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final plotRepository = PlotRepository(db);
    final characterRepository = CharacterRepository(db);
    final lorebookRepository = LorebookRepository(db);

    final plotId = await plotRepository.upsertPlot(
      title: '기존 플롯',
      description: '기존 설명',
      shortIntro: '',
      hashtags: const [],
    );
    await characterRepository.add(
      plotId: plotId,
      name: '기존 캐릭터',
      isRepresentative: true,
      sortOrder: 0,
    );
    final existingLorebookId = await lorebookRepository.upsert(title: '기존 로어북');
    await lorebookRepository.setLorebookLinksForPlot(plotId, {existingLorebookId});

    final card = ParsedCharacterCard(
      name: '새 캐릭터',
      description: '새 캐릭터 설명',
      loreEntries: const [
        CharacterBookEntryData(keys: ['키워드'], content: '새 로어 내용'),
      ],
      bookName: '새 로어북',
    );

    final result = await PlotImportService(db).mergeIntoPlot(plotId, card);

    expect(result.plotId, plotId);
    expect(result.hadLorebook, isTrue);

    final characters = await characterRepository.getByPlot(plotId);
    expect(characters, hasLength(2));
    expect(characters.first.name, '기존 캐릭터');
    expect(characters.first.isRepresentative, isTrue);
    expect(characters.last.name, '새 캐릭터');
    expect(characters.last.isRepresentative, isFalse);

    // 기존 로어북 링크가 유지된 채로 새 로어북 링크가 추가돼야 한다(덮어쓰기 금지).
    final linkedLorebooks = await lorebookRepository.watchLinkedLorebooks(plotId).first;
    expect(linkedLorebooks.map((l) => l.title), containsAll(['기존 로어북', '새 로어북']));

    await db.close();
  });

  test('mergeIntoPlot에 mergeLorebookId를 주면 새 로어북을 만들지 않고 기존 로어북에 항목을 이어 붙인다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final plotRepository = PlotRepository(db);
    final lorebookRepository = LorebookRepository(db);

    final plotId = await plotRepository.upsertPlot(
      title: '플롯',
      description: '',
      shortIntro: '',
      hashtags: const [],
    );
    final lorebookId = await lorebookRepository.upsert(title: '공용 로어북');
    await lorebookRepository.setLorebookLinksForPlot(plotId, {lorebookId});

    final card = ParsedCharacterCard(
      name: '캐릭터',
      loreEntries: const [
        CharacterBookEntryData(keys: ['a'], content: '항목 A'),
      ],
    );

    await PlotImportService(db).mergeIntoPlot(plotId, card, mergeLorebookId: lorebookId);

    final entries = await lorebookRepository.getEntries(lorebookId);
    expect(entries, hasLength(1));
    expect(entries.first.content, '항목 A');

    final linkedLorebooks = await lorebookRepository.watchLinkedLorebooks(plotId).first;
    expect(linkedLorebooks, hasLength(1)); // 새 로어북이 추가로 생기지 않았다

    await db.close();
  });
}
