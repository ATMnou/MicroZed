import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../l10n/app_localizations.dart';

/// AI 프리셋 추가/수정 화면. API 키는 저장 시 secure storage로 보내지고,
/// DB에는 참조 키만 남는다(AiPresetRepository 참고).
class AiPresetEditScreen extends StatefulWidget {
  const AiPresetEditScreen({super.key, this.presetId});

  final int? presetId;

  @override
  State<AiPresetEditScreen> createState() => _AiPresetEditScreenState();
}

class _AiPresetEditScreenState extends State<AiPresetEditScreen> {
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

  bool _loading = true;
  bool _saving = false;
  bool _obscureApiKey = true;

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  bool get _isEditing => widget.presetId != null;

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing
              ? l10n.aiPresetEditTitleEdit
              : l10n.aiPresetEditTitleCreate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.aiPresetApiKeyStorageNote,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.aiPresetApiKeyHint,
                    hintStyle: const TextStyle(
                      color: Colors.white38,
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
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
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
                const SizedBox(height: 24),
                Text(
                  l10n.aiPresetAdvancedSettingsTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aiPresetAdvancedSettingsDescription,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
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
                foregroundColor: Colors.white,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
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
}
