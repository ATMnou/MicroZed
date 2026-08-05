import 'package:flutter/material.dart';

import '../data/ai/summary_settings_store.dart';
import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > '요약(장기 기억) 설정'. 롤플레이 채팅이 컨텍스트 길이를 넘는 오래된
/// 대화를 자동 요약하는 기존 기능(ai_chat_service.dart의 `_ensureMemorySummary`)의
/// on/off, 요약 프롬프트, 요약에 쓸 프리셋을 조정한다.
class SummarySettingsScreen extends StatefulWidget {
  const SummarySettingsScreen({super.key});

  @override
  State<SummarySettingsScreen> createState() => _SummarySettingsScreenState();
}

class _SummarySettingsScreenState extends State<SummarySettingsScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  final _store = SummarySettingsStore();
  late final AiPresetRepository _presetRepo;
  final _promptController = TextEditingController();

  bool _enabled = true;
  int? _presetId;
  bool _loading = true;
  bool _saving = false;


  @override
  void initState() {
    super.initState();
    _presetRepo = AiPresetRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final saved = await _store.read();
    if (!mounted) return;
    setState(() {
      _enabled = saved.enabled;
      _promptController.text = saved.customPrompt ?? '';
      _presetId = saved.presetId;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final promptText = _promptController.text.trim();
    await _store.save(SummarySettings(
      enabled: _enabled,
      customPrompt: promptText.isEmpty ? null : promptText,
      presetId: _presetId,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.summarySettingsSavedMessage)));
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
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.summarySettingsTitle,
          style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.summarySettingsDescription,
                  style: TextStyle(color: _textFaint, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: _purple,
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                  title: Text(
                    l10n.summarySettingsEnabledLabel,
                    style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.summarySettingsPromptLabel,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.summarySettingsPromptHint,
                    hintStyle: TextStyle(color: _textFaint, fontSize: 13),
                    filled: true,
                    fillColor: _cardBg,
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _purple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.summarySettingsPresetLabel,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<AiPreset>>(
                  stream: _presetRepo.watchAll(),
                  builder: (context, snapshot) {
                    final presets = snapshot.data ?? const [];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _borderGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: _presetId,
                          dropdownColor: _cardBg,
                          style: TextStyle(color: _textPrimary, fontSize: 14),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(l10n.summarySettingsPresetDefaultOption),
                            ),
                            for (final preset in presets)
                              DropdownMenuItem<int?>(value: preset.id, child: Text(preset.name)),
                          ],
                          onChanged: (value) => setState(() => _presetId = value),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading || _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: _textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.summarySettingsSaveButton,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
