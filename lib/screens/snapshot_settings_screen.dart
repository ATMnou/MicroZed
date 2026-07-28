import 'package:flutter/material.dart';

import '../data/ai/snapshot_settings_store.dart';
import '../l10n/app_localizations.dart';

/// 마이페이지 > '스냅샷 설정'. 채팅의 스냅샷 버튼이 이미지를 생성할 때 쓸 엔드포인트
/// (OpenRouter 또는 AtlasCloud), API 키, 모델명을 저장한다.
class SnapshotSettingsScreen extends StatefulWidget {
  const SnapshotSettingsScreen({super.key});

  @override
  State<SnapshotSettingsScreen> createState() => _SnapshotSettingsScreenState();
}

class _SnapshotSettingsScreenState extends State<SnapshotSettingsScreen> {
  final _store = SnapshotSettingsStore();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  SnapshotImageProvider _provider = SnapshotImageProvider.openRouter;
  bool _loading = true;
  bool _saving = false;
  bool _obscureApiKey = true;

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _store.read();
    if (!mounted) return;
    if (saved != null) {
      _provider = saved.provider;
      _apiKeyController.text = saved.apiKey;
      _modelController.text = saved.modelName;
    } else {
      _modelController.text = _provider.defaultModelName;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    await _store.save(
      SnapshotSettings(
        provider: _provider,
        apiKey: _apiKeyController.text.trim(),
        modelName: _modelController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snapshotSettingsSavedMessage)));
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.snapshotSettingsTitle,
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
                Text(
                  l10n.snapshotSettingsDescription,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.snapshotSettingsProviderLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: SnapshotImageProvider.values.map((provider) {
                    final selected = provider == _provider;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: provider == SnapshotImageProvider.values.first
                              ? 8
                              : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _provider = provider;
                            if (_modelController.text.trim().isEmpty) {
                              _modelController.text = provider.defaultModelName;
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? _purple : _borderGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              provider == SnapshotImageProvider.openRouter
                                  ? 'OpenRouter'
                                  : 'AtlasCloud',
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.snapshotSettingsModelNameLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _modelController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.snapshotSettingsModelNameHint,
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
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
                const SizedBox(height: 20),
                Text(
                  l10n.snapshotSettingsApiKeyLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.snapshotSettingsApiKeyHint,
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
                l10n.snapshotSettingsSaveButton,
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
}
