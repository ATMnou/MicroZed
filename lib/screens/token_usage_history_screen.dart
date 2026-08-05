import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/token_usage_repository.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > '내역' 버튼에서 들어오는 토큰 사용 내역 화면.
/// 요청마다 모델/제공자(baseUrl)/입출력 토큰/가격(엔드포인트가 알려주는 경우만)을 보여준다.
class TokenUsageHistoryScreen extends StatefulWidget {
  const TokenUsageHistoryScreen({super.key});

  @override
  State<TokenUsageHistoryScreen> createState() =>
      _TokenUsageHistoryScreenState();
}

class _TokenUsageHistoryScreenState extends State<TokenUsageHistoryScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;
  Color get _danger => _p.danger;
  Color get _textFaint => _p.textFaint;
  late final TokenUsageRepository _repository;


  @override
  void initState() {
    super.initState();
    _repository = TokenUsageRepository(AppDatabase.instance);
  }

  Future<void> _confirmDeleteAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.tokenUsageDeleteAllConfirmTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          l10n.tokenUsageDeleteAllConfirmContent,
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
              l10n.commonDelete,
              style: TextStyle(color: _danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repository.deleteAll();
    }
  }

  /// OpenRouter처럼 여러 업스트림으로 라우팅하는 엔드포인트는 그 자신이 제공자가 아니므로,
  /// 응답에서 캡처해둔 실제 라우팅 제공자명이 있으면 그걸 우선 쓰고, 없을 때만 baseUrl host로
  /// 대체한다.
  String _providerOf(TokenUsageLog log) {
    if (log.provider != null && log.provider!.isNotEmpty) return log.provider!;
    final host = Uri.tryParse(log.baseUrl)?.host;
    return (host == null || host.isEmpty) ? log.baseUrl : host;
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
          l10n.tokenUsageTitle,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmDeleteAll,
            child: Text(
              l10n.tokenUsageDeleteAllButton,
              style: TextStyle(color: _danger, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<TokenUsageLog>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final logs = snapshot.data ?? const [];
            if (logs.isEmpty) {
              return Center(
                child: Text(
                  l10n.tokenUsageEmptyMessage,
                  style: TextStyle(color: _textFaint, fontSize: 13),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _LogCard(
                log: logs[index],
                provider: _providerOf(logs[index]),
                formattedDate: _formatDate(logs[index].createdAt),
                formatCost: _formatCost,
              ),
            );
          },
        ),
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
        color: PaletteScope.of(context).surface,
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
                  style: TextStyle(
                    color: PaletteScope.of(context).textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(
              context,
            )!.tokenUsageProviderLabel(provider, log.presetName),
            style: TextStyle(color: PaletteScope.of(context).textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.tokenUsageBreakdown(
                  log.promptTokens,
                  log.completionTokens,
                  total,
                ),
                style: TextStyle(color: PaletteScope.of(context).textSecondary, fontSize: 12),
              ),
              const Spacer(),
              if (log.costUsd != null)
                Text(
                  formatCost(log.costUsd!),
                  style: TextStyle(
                    color: PaletteScope.of(context).primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
