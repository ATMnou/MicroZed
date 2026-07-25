import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';

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
      _additionalSystemPromptController.text = preset?.additionalSystemPrompt ?? '';
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
      apiKey: _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim(),
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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? '프리셋 수정' : '프리셋 추가',
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field(label: '이름', controller: _nameController, hint: '예: 기본 스타일'),
                const SizedBox(height: 16),
                _field(label: '설명', controller: _descController, hint: '이 프리셋을 한 줄로 소개해주세요', maxLines: 2),
                const SizedBox(height: 16),
                _field(label: 'Base URL', controller: _baseUrlController, hint: '예: https://api.openai.com/v1'),
                const SizedBox(height: 16),
                _field(label: '모델명', controller: _modelController, hint: '예: gpt-4o-mini, claude-sonnet-5'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('API 키', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Text('기기에만 안전하게 저장돼요', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '직접 발급받은 API 키를 입력해주세요',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: _cardBg,
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
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
                const Text(
                  '고급 설정',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '전부 선택 사항이에요. 비워두면 요청에 포함하지 않아요.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        label: 'Temperature',
                        controller: _temperatureController,
                        hint: '예: 1.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'Top K',
                        controller: _topKController,
                        hint: '예: 40',
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
                        hint: '예: 1024',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: 'Context Length',
                        controller: _contextLengthController,
                        hint: '최근 메시지 몇 개까지',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _field(
                  label: '추가 시스템 프롬프트',
                  controller: _additionalSystemPromptController,
                  hint: '기본 프롬프트 뒤에 덧붙일 지침(선택)',
                  maxLines: 4,
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading || _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('저장하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
