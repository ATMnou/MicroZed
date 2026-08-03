import 'package:flutter/material.dart';

import '../data/ai/ai_chat_service.dart';
import '../data/ai/plot_ai_generator_service.dart';
import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import 'plot_edit_screen.dart';

/// 제작 탭 > 'AI로 생성'. AI 프리셋과 몇 가지 옵션을 고르면 플롯 초안(제목/설명/캐릭터/로어북)을
/// 만들어서 바로 [PlotEditScreen]으로 넘어간다 - 세부 검토/수정은 기존 편집 화면을 그대로 재사용한다.
class PlotAiGenerateScreen extends StatefulWidget {
  const PlotAiGenerateScreen({super.key});

  @override
  State<PlotAiGenerateScreen> createState() => _PlotAiGenerateScreenState();
}

class _PlotAiGenerateScreenState extends State<PlotAiGenerateScreen> {
  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  late final AiPresetRepository _presetRepository;
  late final PlotAiGeneratorService _generatorService;
  final _promptController = TextEditingController();

  List<AiPreset> _presets = const [];
  AiPreset? _selectedPreset;
  bool _webSearch = false;
  PlotLoreLength _loreLength = PlotLoreLength.medium;
  PlotGenerationAccuracy _accuracy = PlotGenerationAccuracy.mixed;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _presetRepository = AiPresetRepository(AppDatabase.instance);
    _generatorService = PlotAiGeneratorService(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final presets = await _presetRepository.watchAll().first;
    if (!mounted) return;
    setState(() {
      _presets = presets;
      _selectedPreset = presets.isEmpty ? null : presets.first;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  bool get _selectedSupportsWebSearch {
    final preset = _selectedPreset;
    return preset != null && AiChatService.supportsWebSearch(preset);
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    final preset = _selectedPreset;
    if (preset == null) return;
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGeneratePromptEmptyMessage)),
      );
      return;
    }
    setState(() => _generating = true);
    try {
      final result = await _generatorService.generate(
        preset: preset,
        options: PlotGenerationOptions(
          userPrompt: _promptController.text.trim(),
          webSearch: _webSearch && _selectedSupportsWebSearch,
          loreLength: _loreLength,
          accuracy: _accuracy,
        ),
      );
      if (!mounted) return;
      final plotId = await _commitResult(result);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PlotEditScreen(plotId: plotId)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGenerateFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<int> _commitResult(PlotGenerationResult result) async {
    final db = AppDatabase.instance;
    final plotRepository = PlotRepository(db);
    final characterRepository = CharacterRepository(db);
    final lorebookRepository = LorebookRepository(db);

    final plotId = await plotRepository.upsertPlot(
      title: result.title.isEmpty ? _promptController.text.trim() : result.title,
      description: result.description,
      shortIntro: result.shortIntro,
      hashtags: result.hashtags,
    );

    for (var i = 0; i < result.characters.length; i++) {
      final character = result.characters[i];
      await characterRepository.add(
        plotId: plotId,
        name: character.name,
        description: character.description,
        isRepresentative: i == 0,
        sortOrder: i,
      );
    }
    // 캐릭터를 하나도 못 만들었으면 편집 화면이 기대하는 최소 요구(대표 캐릭터 1명)를 채워준다.
    if (result.characters.isEmpty) {
      await characterRepository.add(
        plotId: plotId,
        name: result.title.isEmpty ? '캐릭터' : result.title,
        isRepresentative: true,
      );
    }

    if (result.loreEntries.isNotEmpty) {
      final lorebookTitle = result.title.isEmpty ? 'AI 생성 로어북' : '${result.title} 로어북';
      final lorebookId = await lorebookRepository.upsert(title: lorebookTitle);
      for (final entry in result.loreEntries) {
        final entryId = await lorebookRepository.addEntry(lorebookId);
        await lorebookRepository.updateEntry(
          id: entryId,
          title: entry.title,
          keywords: entry.keywords,
          content: entry.content,
        );
      }
      await lorebookRepository.setLorebookLinksForPlot(plotId, {lorebookId});
    }

    return plotId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _generating ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.plotAiGenerateTitle,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _generating
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: _purple),
                      const SizedBox(height: 16),
                      Text(
                        l10n.plotAiGenerateGeneratingMessage,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPresetSelector(l10n),
                    const SizedBox(height: 20),
                    _buildPromptField(l10n),
                    const SizedBox(height: 20),
                    _buildWebSearchToggle(l10n),
                    const SizedBox(height: 20),
                    _buildLoreLengthSelector(l10n),
                    const SizedBox(height: 20),
                    _buildAccuracySelector(l10n),
                  ],
                ),
      bottomNavigationBar: _loading || _generating
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedPreset == null ? null : _generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      l10n.plotAiGenerateSubmitButton,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPresetSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.plotAiGeneratePresetLabel,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_presets.isEmpty)
          Text(
            l10n.plotAiGeneratePresetEmptyHint,
            style: const TextStyle(color: Colors.white38, fontSize: 12.5),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderGrey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AiPreset>(
                value: _selectedPreset,
                isExpanded: true,
                dropdownColor: _cardBg,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: _presets
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (preset) => setState(() => _selectedPreset = preset),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPromptField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.plotAiGeneratePromptLabel,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.plotAiGeneratePromptHint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: _cardBg,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _purple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebSearchToggle(AppLocalizations l10n) {
    final supported = _selectedSupportsWebSearch;
    return SwitchListTile(
      value: _webSearch && supported,
      onChanged: supported ? (v) => setState(() => _webSearch = v) : null,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: _purple,
      title: Text(l10n.plotAiGenerateWebSearchLabel, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: supported
          ? null
          : Text(
              l10n.plotAiGenerateWebSearchUnsupportedHint,
              style: const TextStyle(color: Colors.white38, fontSize: 11.5),
            ),
    );
  }

  Widget _buildLoreLengthSelector(AppLocalizations l10n) {
    final options = <PlotLoreLength, String>{
      PlotLoreLength.short: l10n.plotAiGenerateLoreLengthShort,
      PlotLoreLength.medium: l10n.plotAiGenerateLoreLengthMedium,
      PlotLoreLength.long: l10n.plotAiGenerateLoreLengthLong,
    };
    return _buildChipRow(
      label: l10n.plotAiGenerateLoreLengthLabel,
      options: options,
      selected: _loreLength,
      onSelected: (v) => setState(() => _loreLength = v),
    );
  }

  Widget _buildAccuracySelector(AppLocalizations l10n) {
    final options = <PlotGenerationAccuracy, String>{
      PlotGenerationAccuracy.accurate: l10n.plotAiGenerateAccuracyAccurate,
      PlotGenerationAccuracy.mixed: l10n.plotAiGenerateAccuracyMixed,
    };
    return _buildChipRow(
      label: l10n.plotAiGenerateAccuracyLabel,
      options: options,
      selected: _accuracy,
      onSelected: (v) => setState(() => _accuracy = v),
    );
  }

  Widget _buildChipRow<T>({
    required String label,
    required Map<T, String> options,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final isSelected = entry.key == selected;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onSelected(entry.key),
              backgroundColor: _cardBg,
              selectedColor: _purple.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: isSelected ? _purple : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(color: isSelected ? _purple : _borderGrey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
