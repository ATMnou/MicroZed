import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/token_usage_repository.dart';

/// 마이페이지 > '내역' 버튼에서 들어오는 토큰 사용 내역 화면.
/// 요청마다 모델/제공자(baseUrl)/입출력 토큰/가격(엔드포인트가 알려주는 경우만)을 보여준다.
class TokenUsageHistoryScreen extends StatefulWidget {
  const TokenUsageHistoryScreen({super.key});

  @override
  State<TokenUsageHistoryScreen> createState() => _TokenUsageHistoryScreenState();
}

class _TokenUsageHistoryScreenState extends State<TokenUsageHistoryScreen> {
  late final TokenUsageRepository _repository;

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _repository = TokenUsageRepository(AppDatabase.instance);
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text('내역을 전부 삭제할까요?', style: TextStyle(color: Colors.white)),
        content: const Text(
          '삭제하면 되돌릴 수 없어요.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repository.deleteAll();
    }
  }

  String _providerOf(String baseUrl) {
    final host = Uri.tryParse(baseUrl)?.host;
    return (host == null || host.isEmpty) ? baseUrl : host;
  }

  String _formatCost(double cost) {
    if (cost < 0.01) return '\$${cost.toStringAsFixed(6)}';
    return '\$${cost.toStringAsFixed(4)}';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
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
          '토큰 사용 내역',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _confirmDeleteAll,
            child: const Text('전체 삭제', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<List<TokenUsageLog>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? const [];
          if (logs.isEmpty) {
            return const Center(
              child: Text('아직 사용 내역이 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _LogCard(
              log: logs[index],
              provider: _providerOf(logs[index].baseUrl),
              formattedDate: _formatDate(logs[index].createdAt),
              formatCost: _formatCost,
            ),
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.log,
    required this.provider,
    required this.formattedDate,
    required this.formatCost,
  });

  final TokenUsageLog log;
  final String provider;
  final String formattedDate;
  final String Function(double) formatCost;

  @override
  Widget build(BuildContext context) {
    final total = log.promptTokens + log.completionTokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.modelName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(formattedDate, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text('제공자: $provider · ${log.presetName}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '입력 ${log.promptTokens} · 출력 ${log.completionTokens} · 합계 $total',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              if (log.costUsd != null)
                Text(
                  formatCost(log.costUsd!),
                  style: const TextStyle(color: Color(0xFF7A6FF0), fontSize: 12, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
