import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/intro_entry_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../widgets/local_avatar.dart';
import 'chat_screen.dart';
import 'plot_edit_screen.dart';

/// 홈에서 플롯 카드를 눌렀을 때 표시되는 캐릭터 정보 화면. 실제 DB의 플롯/대표 캐릭터/
/// 인트로 첫 줄을 불러와서 보여준다. 하단 액션은 북마크 버튼을 제거하고
/// '이어서 대화하기' 버튼만 남겼다.
class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({super.key, required this.plotId, required this.heroColor});

  final int plotId;
  final Color heroColor;

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late final PlotRepository _plotRepository;
  late final IntroEntryRepository _introRepository;
  late final ChatSessionRepository _sessionRepository;

  Plot? _plot;
  Character? _character;
  IntroEntry? _firstIntroEntry;
  int _conversationCount = 0;
  bool _loading = true;

  static const _background = Color(0xFF141414);

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    _plotRepository = PlotRepository(db);
    _introRepository = IntroEntryRepository(db);
    _sessionRepository = ChatSessionRepository(db);
    _load();
  }

  Future<void> _load() async {
    final plot = await _plotRepository.getById(widget.plotId);
    final character = await _plotRepository.representativeCharacter(widget.plotId);
    final defaultVersionId = await _introRepository.ensureDefaultVersion(widget.plotId);
    final introEntries = await _introRepository.getByVersion(defaultVersionId);
    final count = await _plotRepository.conversationCount(widget.plotId);
    if (mounted) {
      setState(() {
        _plot = plot;
        _character = character;
        _firstIntroEntry = introEntries.isEmpty ? null : introEntries.first;
        _conversationCount = count;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7A6FF0)))
          : ListView(
              children: [
                _buildHeroImage(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _DetailBody(
                    plot: _plot,
                    character: _character,
                    firstIntroEntry: _firstIntroEntry,
                    conversationCount: _conversationCount,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlotEditScreen(plotId: widget.plotId),
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('플롯 수정', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'export',
              child: Text('내보내기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final coverPath = _plot?.coverImagePath;
    if (coverPath != null) {
      return Image.file(
        File(coverPath),
        width: double.infinity,
        height: 320,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: double.infinity,
      height: 320,
      color: widget.heroColor,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  final sessionId = await _sessionRepository.findOrCreateForPlot(widget.plotId);
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatScreen(sessionId: sessionId)),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7A6FF0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('이어서 대화하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.plot,
    required this.character,
    required this.firstIntroEntry,
    required this.conversationCount,
  });

  final Plot? plot;
  final Character? character;
  final IntroEntry? firstIntroEntry;
  final int conversationCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plot?.title ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text('$conversationCount', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          plot?.description ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),
        const Text(
          '캐릭터',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildCharacterCard(),
        if (firstIntroEntry != null) ...[
          const SizedBox(height: 24),
          const Text(
            '인트로',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildIntroPreview(),
        ],
      ],
    );
  }

  Widget _buildCharacterCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          LocalAvatar(imagePath: character?.imagePath, radius: 28, icon: Icons.pets),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character?.name ?? '캐릭터',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  character?.description ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPreview() {
    final entry = firstIntroEntry!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalAvatar(imagePath: character?.imagePath, radius: 16, icon: Icons.pets),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(character?.name ?? '캐릭터', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.content,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
