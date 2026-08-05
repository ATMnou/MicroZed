import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';
import '../widgets/api_key_guide_dialog.dart';

/// AI 프리셋 추가/수정 화면. API 키는 저장 시 secure storage로 보내지고,
/// DB에는 참조 키만 남는다(AiPresetRepository 참고).
class AiPresetEditScreen extends StatefulWidget {
  const AiPresetEditScreen({super.key, this.presetId});

  final int? presetId;

  @override
  State<AiPresetEditScreen> createState() => _AiPresetEditScreenState();
}

class _AiPresetEditScreenState extends State<AiPresetEditScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  Color get _mutedText => _p.textMuted;
  Color get _textSecondary => _p.textSecondary;
  late final AiPresetRepository _repository;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _temperatureController = TextEditingController(text: '1.0');
  final _topKController = TextEditingController();
  final _maxTokensController = TextEditingController();
  final _contextLengthController = TextEditingController();
  final _additionalSystemPromptController = TextEditingController();

  /// null(끔) 또는 'low'/'medium'/'high'.
  String? _reasoningEffort;

  bool _openRouterZdrOnly = false;
  bool _openRouterExcludeChinaProviders = false;
  bool _openRouterExcludeTrainingProviders = false;
  AiEndpointFormat _endpointFormat = AiEndpointFormat.openAiCompatible;
  bool _supportsVision = false;

  bool _loading = true;
  bool _saving = false;
  bool _obscureApiKey = true;


  bool get _isEditing => widget.presetId != null;
  bool get _isOpenRouter => _baseUrlController.text.toLowerCase().contains('openrouter.ai');

  @override
  void initState() {
    super.initState();
    _repository = AiPresetRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    if (widget.presetId != null) {
      final preset = await _repository.getById(widget.presetId!);
      _nameController.text = preset?.name ?? '';
      _descController.text = preset?.description ?? '';
      _baseUrlController.text = preset?.baseUrl ?? '';
      _modelController.text = preset?.modelName ?? '';
      _temperatureController.text = (preset?.temperature ?? 1.0).toString();
      _topKController.text = preset?.topK?.toString() ?? '';
      _maxTokensController.text = preset?.maxTokens?.toString() ?? '';
      _contextLengthController.text = preset?.contextLength?.toString() ?? '';
      _additionalSystemPromptController.text =
          preset?.additionalSystemPrompt ?? '';
      _reasoningEffort = preset?.reasoningEffort;
      _openRouterZdrOnly = preset?.openRouterZdrOnly ?? false;
      _openRouterExcludeChinaProviders = preset?.openRouterExcludeChinaProviders ?? false;
      _openRouterExcludeTrainingProviders = preset?.openRouterExcludeTrainingProviders ?? false;
      _endpointFormat = preset?.endpointFormat ?? AiEndpointFormat.openAiCompatible;
      _supportsVision = preset?.supportsVision ?? false;
      final apiKey = await _repository.readApiKey(widget.presetId!);
      if (apiKey != null) _apiKeyController.text = apiKey;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _baseUrlController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    await _repository.upsert(
      id: widget.presetId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      modelName: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim().isEmpty
          ? null
          : _apiKeyController.text.trim(),
      temperature: double.tryParse(_temperatureController.text.trim()) ?? 1.0,
      topK: int.tryParse(_topKController.text.trim()),
      maxTokens: int.tryParse(_maxTokensController.text.trim()),
      contextLength: int.tryParse(_contextLengthController.text.trim()),
      additionalSystemPrompt: _additionalSystemPromptController.text.trim(),
      reasoningEffort: _reasoningEffort,
      openRouterZdrOnly: _openRouterZdrOnly,
      openRouterExcludeChinaProviders: _openRouterExcludeChinaProviders,
      openRouterExcludeTrainingProviders: _openRouterExcludeTrainingProviders,
      endpointFormat: _endpointFormat,
      supportsVision: _supportsVision,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _temperatureController.dispose();
    _topKController.dispose();
    _maxTokensController.dispose();
    _contextLengthController.dispose();
    _additionalSystemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing
              ? l10n.aiPresetEditTitleEdit
              : l10n.aiPresetEditTitleCreate,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field(
                  label: l10n.plotEditNameFieldLabel,
                  controller: _nameController,
                  hint: l10n.aiPresetNameHint,
                ),
                const SizedBox(height: 16),
                _field(
                  label: l10n.plotEditDescriptionFieldLabel,
                  controller: _descController,
                  hint: l10n.aiPresetDescHint,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildEndpointFormatSelector(l10n),
                const SizedBox(height: 12),
                _openRouterSwitch(
                  label: l10n.aiPresetSupportsVisionLabel,
                  description: l10n.aiPresetSupportsVisionDescription,
                  value: _supportsVision,
                  onChanged: (v) => setState(() => _supportsVision = v),
                ),
                const SizedBox(height: 4),
                _field(
                  label: 'Base URL',
                  controller: _baseUrlController,
                  hint: l10n.aiPresetBaseUrlHint,
                ),
                const SizedBox(height: 16),
                _field(
                  label: l10n.aiPresetModelNameLabel,
                  controller: _modelController,
                  hint: l10n.aiPresetModelNameHint,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.aiPresetApiKeyLabel,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.aiPresetApiKeyStorageNote,
                        style: TextStyle(
                          color: _textFaint,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => showApiKeyGuideDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: _purple,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.help_outline, size: 15),
                      label: Text(l10n.aiPresetApiKeyGuideButton, style: const TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.aiPresetApiKeyHint,
                    hintStyle: TextStyle(
                      color: _textFaint,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: _cardBg,
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _mutedText,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
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
                const SizedBox(height: 24),
                Text(
                  l10n.aiPresetAdvancedSettingsTitle,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aiPresetAdvancedSettingsDescription,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        label: 'Temperature',
                        controller: _temperatureController,
                        hint: l10n.aiPresetTemperatureHint,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'Top K',
                        controller: _topKController,
                        hint: l10n.aiPresetTopKHint,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        label: 'Max Tokens',
                        controller: _maxTokensController,
                        hint: l10n.aiPresetMaxTokensHint,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'Context Length',
                        controller: _contextLengthController,
                        hint: l10n.aiPresetContextLengthHint,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _field(
                  label: l10n.aiPresetAdditionalPromptLabel,
                  controller: _additionalSystemPromptController,
                  hint: l10n.aiPresetAdditionalPromptHint,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildReasoningEffortSelector(l10n),
                AnimatedBuilder(
                  animation: _baseUrlController,
                  builder: (context, _) {
                    if (!_isOpenRouter) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildOpenRouterOptions(l10n),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.aiPresetSaveButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasoningEffortSelector(AppLocalizations l10n) {
    final options = <String?, String>{
      null: l10n.aiPresetReasoningEffortOff,
      'low': l10n.aiPresetReasoningEffortLow,
      'medium': l10n.aiPresetReasoningEffortMedium,
      'high': l10n.aiPresetReasoningEffortHigh,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiPresetReasoningEffortLabel,
          style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aiPresetReasoningEffortDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final selected = _reasoningEffort == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _reasoningEffort = entry.key),
              backgroundColor: _cardBg,
              selectedColor: _purple.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected ? _purple : _textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(color: selected ? _purple : _borderGrey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEndpointFormatSelector(AppLocalizations l10n) {
    final options = <AiEndpointFormat, String>{
      AiEndpointFormat.openAiCompatible: l10n.aiPresetEndpointFormatOpenAi,
      AiEndpointFormat.anthropic: l10n.aiPresetEndpointFormatAnthropic,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiPresetEndpointFormatLabel,
          style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aiPresetEndpointFormatDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final selected = _endpointFormat == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _endpointFormat = entry.key),
              backgroundColor: _cardBg,
              selectedColor: _purple.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                color: selected ? _purple : _textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(color: selected ? _purple : _borderGrey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpenRouterOptions(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiPresetOpenRouterSectionTitle,
          style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aiPresetOpenRouterSectionDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _openRouterSwitch(
          label: l10n.aiPresetOpenRouterZdrOnlyLabel,
          description: l10n.aiPresetOpenRouterZdrOnlyDescription,
          value: _openRouterZdrOnly,
          onChanged: (v) => setState(() => _openRouterZdrOnly = v),
        ),
        _openRouterSwitch(
          label: l10n.aiPresetOpenRouterExcludeChinaLabel,
          description: l10n.aiPresetOpenRouterExcludeChinaDescription,
          value: _openRouterExcludeChinaProviders,
          onChanged: (v) => setState(() => _openRouterExcludeChinaProviders = v),
        ),
        _openRouterSwitch(
          label: l10n.aiPresetOpenRouterExcludeTrainingLabel,
          description: l10n.aiPresetOpenRouterExcludeTrainingDescription,
          value: _openRouterExcludeTrainingProviders,
          onChanged: (v) => setState(() => _openRouterExcludeTrainingProviders = v),
        ),
      ],
    );
  }

  Widget _openRouterSwitch({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: _purple,
      title: Text(label, style: TextStyle(color: _textPrimary, fontSize: 13.5)),
      subtitle: Text(description, style: TextStyle(color: _textFaint, fontSize: 11.5)),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}
