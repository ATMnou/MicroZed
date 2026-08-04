import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/chat_session_repository.dart';
import '../data/repositories/intro_entry_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../data/repositories/talk_session_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import 'chat_screen.dart';
import 'plot_edit_screen.dart';
import 'plot_profile_picker_screen.dart';
import 'talk_character_picker_screen.dart';
import 'talk_chat_screen.dart';

/// 홈에서 플롯 카드를 눌렀을 때 표시되는 캐릭터 정보 화면. 실제 DB의 플롯/대표 캐릭터/
/// 인트로 첫 줄을 불러와서 보여준다. 하단 액션은 북마크 버튼을 제거하고
/// '이어서 대화하기' 버튼만 남겼다.
class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({
    super.key,
    required this.plotId,
    required this.heroColor,
  });

  final int plotId;
  final Color heroColor;

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late final PlotRepository _plotRepository;
  late final IntroEntryRepository _introRepository;
  late final ChatSessionRepository _sessionRepository;
  late final PlotConversationProfileRepository _plotProfileRepository;
  late final TalkSessionRepository _talkSessionRepository;
  late final CharacterRepository _characterRepository;

  Plot? _plot;
  Character? _character;
  IntroEntry? _firstIntroEntry;
  int _conversationCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final db = AppDatabase.instance;
    _plotRepository = PlotRepository(db);
    _introRepository = IntroEntryRepository(db);
    _sessionRepository = ChatSessionRepository(db);
    _plotProfileRepository = PlotConversationProfileRepository(db);
    _talkSessionRepository = TalkSessionRepository(db);
    _characterRepository = CharacterRepository(db);
    _load();
  }

  /// 'ZedTalk' 버튼. 이 플롯에 이미 톡방이 있으면 가장 최근 것을 이어서 열고(캐릭터는 이미
  /// 그 방에 정해져 있으니 다시 묻지 않는다), 없으면 새로 만든다 — 플롯에 캐릭터가 여럿이면
  /// 새로 만들기 전에 어떤 캐릭터와 대화할지 먼저 고르게 한다.
  Future<void> _startTalk(BuildContext context) async {
    final existingSessionId = await _talkSessionRepository.mostRecentSessionIdForPlot(widget.plotId);
    int sessionId;
    if (existingSessionId != null) {
      sessionId = existingSessionId;
    } else {
      if (!context.mounted) return;
      final pick = await _pickTalkCharacter(context);
      if (pick.cancelled) return;
      if (!context.mounted) return;
      sessionId = await _talkSessionRepository.createSession(plotId: widget.plotId, characterId: pick.characterId);
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TalkChatScreen(sessionId: sessionId)),
    );
  }

  /// 플롯 캐릭터가 1명 이하면 고를 필요 없이 바로 그 캐릭터 id(없으면 null)를 돌려준다.
  /// 2명 이상이면 선택 화면을 띄우고, 취소하면 `cancelled: true`(호출부가 중단 처리).
  Future<({bool cancelled, int? characterId})> _pickTalkCharacter(BuildContext context) async {
    final characters = await _characterRepository.getByPlot(widget.plotId);
    if (characters.length <= 1) {
      return (cancelled: false, characterId: characters.isEmpty ? null : characters.first.id);
    }
    if (!context.mounted) return (cancelled: true, characterId: null);
    final chosen = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => TalkCharacterPickerScreen(plotId: widget.plotId)),
    );
    return chosen == null ? (cancelled: true, characterId: null) : (cancelled: false, characterId: chosen);
  }

  /// 이 플롯에 이미 활성 세션이 있으면 그대로 이어서 열고, 없으면 새로 만든다.
  /// 새로 만드는 경우, 플롯 전용 대화 프로필이 하나라도 있으면 먼저 프로필 선택 화면을
  /// 띄워서 어떤 프로필로 시작할지 고르게 한다(없으면 예전처럼 조용히 전역 기본값을 쓴다).
  Future<void> _startOrContinueChat(BuildContext context) async {
    final existingSessionId = await _sessionRepository.activeSessionIdForPlot(widget.plotId);
    late final int sessionId;
    if (existingSessionId != null) {
      sessionId = existingSessionId;
    } else {
      final plotProfiles = await _plotProfileRepository.getByPlot(widget.plotId);
      int? globalProfileId;
      int? plotProfileId;
      if (plotProfiles.isNotEmpty) {
        if (!context.mounted) return;
        final choice = await Navigator.of(context).push<({int? globalProfileId, int? plotProfileId})>(
          MaterialPageRoute(builder: (_) => PlotProfilePickerScreen(plotId: widget.plotId)),
        );
        if (choice == null) return; // 취소됨
        globalProfileId = choice.globalProfileId;
        plotProfileId = choice.plotProfileId;
      }
      sessionId = await _sessionRepository.createSession(
        plotId: widget.plotId,
        conversationProfileId: globalProfileId,
        plotConversationProfileId: plotProfileId,
      );
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: sessionId)),
    );
  }

  Future<void> _load() async {
    final plot = await _plotRepository.getById(widget.plotId);
    final character = await _plotRepository.representativeCharacter(
      widget.plotId,
    );
    final defaultVersionId = await _introRepository.ensureDefaultVersion(
      widget.plotId,
    );
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7A6FF0)),
            )
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white, size: 24),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlotEditScreen(plotId: widget.plotId),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(
                AppLocalizations.of(context)!.createTabEditPlotMenuItem,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Text(
                AppLocalizations.of(context)!.characterDetailExportMenuItem,
                style: const TextStyle(color: Colors.white),
              ),
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
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _loading ? null : () => _startTalk(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3A3A3A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.characterDetailTalkButton,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _startOrContinueChat(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A6FF0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.characterDetailContinueChatButton,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plot?.title ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white38,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '$conversationCount',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          plot?.description ?? '',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.characterDetailCharacterSectionTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCharacterCard(context),
        if (firstIntroEntry != null) ...[
          const SizedBox(height: 24),
          Text(
            l10n.characterDetailIntroSectionTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildIntroPreview(context),
        ],
      ],
    );
  }

  Widget _buildCharacterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          LocalAvatar(
            imagePath: character?.imagePath,
            radius: 28,
            icon: Icons.pets,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character?.name ??
                      AppLocalizations.of(context)!.chatDefaultCharacterName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
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

  Widget _buildIntroPreview(BuildContext context) {
    final entry = firstIntroEntry!;
    switch (entry.type) {
      case IntroEntryType.character:
        return _buildIntroBubble(
          context,
          avatar: LocalAvatar(
            imagePath: character?.imagePath,
            radius: 16,
            icon: Icons.pets,
          ),
          label:
              character?.name ??
              AppLocalizations.of(context)!.chatDefaultCharacterName,
          content: Text(
            entry.content,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        );
      case IntroEntryType.narrator:
        return _buildIntroBubble(
          context,
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2A2A2A),
            child: Icon(Icons.reorder, color: Colors.white54, size: 16),
          ),
          label: AppLocalizations.of(context)!.characterDetailIntroNarratorLabel,
          content: Text(
            entry.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case IntroEntryType.user:
        return _buildIntroBubble(
          context,
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2A2A2A),
            child: Icon(Icons.person, color: Colors.white54, size: 16),
          ),
          label: AppLocalizations.of(context)!.characterDetailIntroUserLabel,
          content: Text(
            entry.content,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        );
      case IntroEntryType.image:
        return _buildIntroBubble(
          context,
          avatar: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2A2A2A),
            child: Icon(Icons.image_outlined, color: Colors.white54, size: 16),
          ),
          label: AppLocalizations.of(context)!.characterDetailIntroImageLabel,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(entry.content),
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                height: 60,
                child: Icon(Icons.broken_image_outlined, color: Colors.white38),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildIntroBubble(
    BuildContext context, {
    required Widget avatar,
    required String label,
    required Widget content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: content,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
