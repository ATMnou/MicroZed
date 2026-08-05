import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/character_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 다중 캐릭터 플롯에서 새 ZedTalk을 시작할 때, 어떤 캐릭터와 1:1로 대화할지 고르는 화면.
/// [Navigator.pop]으로 고른 캐릭터의 id를 돌려준다(취소면 null).
class TalkCharacterPickerScreen extends StatefulWidget {
  const TalkCharacterPickerScreen({super.key, required this.plotId});

  final int plotId;

  @override
  State<TalkCharacterPickerScreen> createState() => _TalkCharacterPickerScreenState();
}

class _TalkCharacterPickerScreenState extends State<TalkCharacterPickerScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;

  late final CharacterRepository _characterRepository;
  bool _loading = true;
  List<Character> _characters = const [];

  @override
  void initState() {
    super.initState();
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final characters = await _characterRepository.getByPlot(widget.plotId);
    if (!mounted) return;
    setState(() {
      _characters = characters;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: _textPrimary, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            l10n.talkCharacterPickerTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        for (final character in _characters)
                          InkWell(
                            onTap: () => Navigator.of(context).pop(character.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  LocalAvatar(imagePath: character.imagePath, radius: 22, icon: Icons.pets),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          character.name,
                                          style: TextStyle(
                                            color: _textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (character.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            character.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: _mutedText, fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
