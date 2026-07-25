import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import 'ai_preset_edit_screen.dart';

/// 마이페이지 > 'AI 프리셋 설정'에서 진입하는 프리셋 관리 화면.
/// 대화 화면의 AI 모델 선택 바텀시트에서 보여주는 것과 같은 프리셋 목록(DB)을 관리한다.
class AiPresetScreen extends StatefulWidget {
  const AiPresetScreen({super.key});

  @override
  State<AiPresetScreen> createState() => _AiPresetScreenState();
}

class _AiPresetScreenState extends State<AiPresetScreen> {
  late final AiPresetRepository _repository;

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _purple = Color(0xFF7A6FF0);

  @override
  void initState() {
    super.initState();
    _repository = AiPresetRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI 프리셋 설정',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<AiPreset>>(
            stream: _repository.watchAll(),
            builder: (context, snapshot) {
              final presets = snapshot.data ?? const [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  const Text(
                    '대화에서 사용할 AI 프리셋을 만들고 관리하세요.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (presets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('아직 만든 프리셋이 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      ),
                    ),
                  ...presets.map((p) => _PresetCard(
                        preset: p,
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AiPresetEditScreen(presetId: p.id)),
                          );
                        },
                        onDelete: () => _repository.delete(p.id),
                      )),
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
                  MaterialPageRoute(builder: (_) => const AiPresetEditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('프리셋 추가', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.onEdit, required this.onDelete});

  final AiPreset preset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AiPresetScreenState._cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  preset.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${preset.baseUrl} · ${preset.modelName}',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
