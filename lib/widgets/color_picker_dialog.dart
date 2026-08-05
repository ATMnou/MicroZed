import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/theme/color_palette.dart';
import '../l10n/app_localizations.dart';

/// 프리셋 편집 화면에서 색상 슬롯 하나를 고를 때 쓰는 다이얼로그.
/// 헥스코드 직접 입력 + 빠른 선택용 스와치 그리드로 구성된다(외부 컬러피커 패키지 의존 없이 자체 구현).
Future<Color?> showAppColorPickerDialog(
  BuildContext context, {
  required Color initial,
  required ColorPalette previewPalette,
}) {
  return showDialog<Color>(
    context: context,
    builder: (dialogContext) => _ColorPickerDialog(initial: initial, palette: previewPalette),
  );
}

const _quickSwatches = <Color>[
  Color(0xFF000000), Color(0xFF141414), Color(0xFF1E1E1E), Color(0xFF262626),
  Color(0xFF3A3A3A), Color(0xFF5A5A5A), Color(0xFF9A9A9A), Color(0xFFD9D9D9),
  Color(0xFFF5F5F7), Color(0xFFFFFFFF),
  Color(0xFF7A6FF0), Color(0xFF5B8CFF), Color(0xFF3DD6C4), Color(0xFF4CD964),
  Color(0xFFE8C547), Color(0xFFFF9F43), Color(0xFFFF5252), Color(0xFFFF6FA5),
  Color(0xFFB56FF0), Color(0xFF6FD6F0),
];

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initial, required this.palette});

  final Color initial;
  final ColorPalette palette;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color;
  late final TextEditingController _hexController;
  late final TextEditingController _alphaController;

  @override
  void initState() {
    super.initState();
    _color = widget.initial;
    _hexController = TextEditingController(text: _hexOf(_color, includeAlpha: false));
    _alphaController = TextEditingController(text: (_color.a * 255).round().toString());
  }

  @override
  void dispose() {
    _hexController.dispose();
    _alphaController.dispose();
    super.dispose();
  }

  String _hexOf(Color color, {bool includeAlpha = true}) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    final a = (color.a * 255).round().toRadixString(16).padLeft(2, '0');
    return '${includeAlpha ? a : ''}$r$g$b'.toUpperCase();
  }

  void _applyHex(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    if (cleaned.length != 6 && cleaned.length != 8) return;
    final hex = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return;
    setState(() => _color = Color(parsed));
  }

  void _applyAlpha(String value) {
    final alpha = int.tryParse(value);
    if (alpha == null) return;
    setState(() => _color = _color.withAlpha(alpha.clamp(0, 255)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.palette;
    return AlertDialog(
      backgroundColor: p.surface,
      title: Text(l10n.colorPickerTitle, style: TextStyle(color: p.textPrimary)),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.border),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _hexController,
                      style: TextStyle(color: p.textPrimary, fontFamily: 'monospace'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f#]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      decoration: InputDecoration(
                        prefixText: '#',
                        prefixStyle: TextStyle(color: p.textMuted),
                        labelText: l10n.colorPickerHexLabel,
                        labelStyle: TextStyle(color: p.textMuted),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: p.border)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: p.primary)),
                      ),
                      onChanged: _applyHex,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _alphaController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: p.textPrimary),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                      decoration: InputDecoration(
                        labelText: l10n.colorPickerAlphaLabel,
                        labelStyle: TextStyle(color: p.textMuted),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: p.border)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: p.primary)),
                      ),
                      onChanged: _applyAlpha,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.colorPickerQuickPicksLabel, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickSwatches.map((swatch) {
                  final selected = swatch.toARGB32() == _color.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() {
                      _color = swatch;
                      _hexController.text = _hexOf(_color, includeAlpha: false);
                      _alphaController.text = '255';
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: swatch,
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? p.primary : p.border, width: selected ? 2.5 : 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel, style: TextStyle(color: p.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_color),
          child: Text(l10n.commonConfirm, style: TextStyle(color: p.primary)),
        ),
      ],
    );
  }
}
