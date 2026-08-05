import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../l10n/app_localizations.dart';
import 'ai_preset_edit_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > 'AI 프리셋 설정'에서 진입하는 프리셋 관리 화면.
/// 대화 화면의 AI 모델 선택 바텀시트에서 보여주는 것과 같은 프리셋 목록(DB)을 관리한다.
class AiPresetScreen extends StatefulWidget {
  const AiPresetScreen({super.key});

  @override
  State<AiPresetScreen> createState() => _AiPresetScreenState();
}

class _AiPresetScreenState extends State<AiPresetScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  late final AiPresetRepository _repository;


  @override
  void initState() {
    super.initState();
    _repository = AiPresetRepository(AppDatabase.instance);
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myPageAiPresetButton,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            StreamBuilder<List<AiPreset>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                final presets = snapshot.data ?? const [];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    Text(
                      l10n.aiPresetScreenDescription,
                      style: TextStyle(
                        color: _textFaint,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (presets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            l10n.chatModelSheetNoPresets,
                            style: TextStyle(
                              color: _textFaint,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ...presets.map(
                      (p) => _PresetCard(
                        preset: p,
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AiPresetEditScreen(presetId: p.id),
                            ),
                          );
                        },
                        onDelete: () => _repository.delete(p.id),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AiPresetEditScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: _textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  l10n.aiPresetScreenAddButton,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.onEdit,
    required this.onDelete,
  });

  final AiPreset preset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletteScope.of(context).surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        preset.name,
                        style: TextStyle(
                          color: PaletteScope.of(context).textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (preset.isLocal) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: PaletteScope.of(context).primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '기기 내장',
                          style: TextStyle(color: PaletteScope.of(context).primary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  preset.description,
                  style: TextStyle(color: PaletteScope.of(context).textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  preset.isLocal ? preset.modelName : '${preset.baseUrl} · ${preset.modelName}',
                  style: TextStyle(color: PaletteScope.of(context).textGhost, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: PaletteScope.of(context).textMuted,
              size: 18,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: PaletteScope.of(context).textMuted,
              size: 18,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
