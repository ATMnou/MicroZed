import 'package:flutter/material.dart';

import '../data/theme/color_palette.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../widgets/color_picker_dialog.dart';

/// 마이페이지 > 환경설정 > 테마의 '+ 프리셋 추가' / 편집 화면.
/// [existing]이 null이면 새 커스텀 프리셋 생성(다른 프리셋을 복사해서 시작), 값이 있으면 그 커스텀
/// 프리셋을 고친다(빌트인은 이 화면에 진입할 수 없다 - 호출부에서 막는다).
class PaletteEditScreen extends StatefulWidget {
  const PaletteEditScreen({super.key, this.existing, required this.startFrom});

  final ColorPalette? existing;
  final ColorPalette startFrom;

  @override
  State<PaletteEditScreen> createState() => _PaletteEditScreenState();
}

class _PaletteEditScreenState extends State<PaletteEditScreen> {
  late ColorPalette _draft;
  late final TextEditingController _nameController;
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    _draft = widget.existing ?? widget.startFrom.copyWith(id: '', isBuiltIn: false);
    _nameController = TextEditingController(text: _isNew ? '' : _draft.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickColor(Color current, ValueChanged<Color> onPicked) async {
    final result = await showAppColorPickerDialog(context, initial: current, previewPalette: _draft);
    if (result != null) setState(() => onPicked(result));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.paletteEditNameEmptyMessage)));
      return;
    }
    setState(() => _saving = true);
    try {
      final palette = _draft.copyWith(name: name);
      if (_isNew) {
        final saved = await paletteController.addCustom(palette);
        await paletteController.select(saved.id);
      } else {
        await paletteController.updateCustom(palette);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _draft;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isNew ? l10n.paletteEditNewTitle : l10n.paletteEditEditTitle,
          style: TextStyle(color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.commonSave, style: TextStyle(color: p.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.paletteEditPreviewLabel, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
                const SizedBox(height: 10),
                _buildPreview(p),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.paletteEditNameLabel,
              labelStyle: TextStyle(color: p.textMuted),
              filled: true,
              fillColor: p.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: p.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildBrightnessToggle(l10n, p),
          const SizedBox(height: 20),
          Text(l10n.paletteEditColorsLabel, style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _colorRow(l10n.paletteSlotBackground, p.background, (c) => _draft = _draft.copyWith(background: c)),
          _colorRow(l10n.paletteSlotSurface, p.surface, (c) => _draft = _draft.copyWith(surface: c)),
          _colorRow(l10n.paletteSlotSurfaceAlt, p.surfaceAlt, (c) => _draft = _draft.copyWith(surfaceAlt: c)),
          _colorRow(l10n.paletteSlotBorder, p.border, (c) => _draft = _draft.copyWith(border: c)),
          _colorRow(l10n.paletteSlotPrimary, p.primary, (c) => _draft = _draft.copyWith(primary: c)),
          _colorRow(l10n.paletteSlotOnPrimary, p.onPrimary, (c) => _draft = _draft.copyWith(onPrimary: c)),
          _colorRow(l10n.paletteSlotTextPrimary, p.textPrimary, (c) => _draft = _draft.copyWith(textPrimary: c)),
          _colorRow(l10n.paletteSlotTextSecondary, p.textSecondary, (c) => _draft = _draft.copyWith(textSecondary: c)),
          _colorRow(l10n.paletteSlotTextMuted, p.textMuted, (c) => _draft = _draft.copyWith(textMuted: c)),
          _colorRow(l10n.paletteSlotTextFaint, p.textFaint, (c) => _draft = _draft.copyWith(textFaint: c)),
          _colorRow(l10n.paletteSlotTextGhost, p.textGhost, (c) => _draft = _draft.copyWith(textGhost: c)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreview(ColorPalette p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: p.border)),
            child: Row(
              children: [
                Text('Aa', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('Aa', style: TextStyle(color: p.textSecondary)),
                const SizedBox(width: 8),
                Text('Aa', style: TextStyle(color: p.textMuted)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text('Button', style: TextStyle(color: p.onPrimary, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessToggle(AppLocalizations l10n, ColorPalette p) {
    return Row(
      children: [
        Text(l10n.paletteEditBrightnessLabel, style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const Spacer(),
        _brightnessChip(l10n.paletteEditBrightnessDark, Brightness.dark, p),
        const SizedBox(width: 8),
        _brightnessChip(l10n.paletteEditBrightnessLight, Brightness.light, p),
      ],
    );
  }

  Widget _brightnessChip(String label, Brightness value, ColorPalette p) {
    final selected = _draft.brightness == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _draft = _draft.copyWith(brightness: value)),
      backgroundColor: p.surface,
      selectedColor: p.primary.withValues(alpha: 0.25),
      labelStyle: TextStyle(color: selected ? p.primary : p.textSecondary, fontSize: 13),
      side: BorderSide(color: selected ? p.primary : p.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _colorRow(String label, Color value, void Function(Color) onPicked) {
    final p = _draft;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _pickColor(value, (c) => setState(() => onPicked(c))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: p.textPrimary, fontSize: 13.5))),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: value,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.border),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
