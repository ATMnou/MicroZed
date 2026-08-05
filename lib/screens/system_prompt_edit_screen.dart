import 'package:flutter/material.dart';

import '../data/ai/prompt_builder.dart';
import '../data/ai/system_prompt_store.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > '시스템 프롬프트 설정'에서 진입하는, AI에게 보내는 시스템 프롬프트
/// 템플릿을 통째로 편집하는 화면. 저장된 값이 없으면 기본 템플릿을 그대로 보여준다.
class SystemPromptEditScreen extends StatefulWidget {
  const SystemPromptEditScreen({super.key});

  @override
  State<SystemPromptEditScreen> createState() => _SystemPromptEditScreenState();
}

class _SystemPromptEditScreenState extends State<SystemPromptEditScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;
  Color get _danger => _p.danger;
  Color get _textSecondary => _p.textSecondary;
  Color get _textFaint => _p.textFaint;
  final _store = SystemPromptStore();
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;


  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _store.read();
    if (!mounted) return;
    _controller.text = (saved != null && saved.trim().isNotEmpty)
        ? saved
        : PromptBuilder.defaultSystemPromptTemplate;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    await _store.save(_controller.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.systemPromptSavedMessage)));
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.systemPromptResetConfirmTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          l10n.systemPromptResetConfirmContent,
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: _mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.systemPromptResetButton,
              style: TextStyle(color: _danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _store.resetToDefault();
    if (!mounted) return;
    setState(
      () => _controller.text = PromptBuilder.defaultSystemPromptTemplate,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.systemPromptResetDoneMessage)));
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
          l10n.systemPromptButtonLabel,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _loading || _saving ? null : _save,
              child: Text(
                l10n.commonSave,
                style: TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.systemPromptWarning,
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.systemPromptPlaceholderHintTitle,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.systemPromptPlaceholderHintBody,
                          style: TextStyle(
                            color: _textFaint,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 16,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
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
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _confirmReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textSecondary,
                      side: BorderSide(color: _borderGrey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: Text(
                      l10n.systemPromptResetButton,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
