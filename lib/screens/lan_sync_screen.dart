import 'package:flutter/material.dart';

import '../data/backup/backup_service.dart';
import '../data/db/database.dart';
import '../data/lan_sync_service.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > 환경설정 > 'LAN 동기화'. 같은 Wi-Fi/LAN에 있는 다른 기기와 파일 없이
/// 전체 데이터를 1회성으로 주고받는다(전체 교체, 병합 아님) - 기존 파일 기반
/// 백업/복원(BackupService)과 같은 포맷을 로컬 HTTP로 전송할 뿐이다.
class LanSyncScreen extends StatefulWidget {
  const LanSyncScreen({super.key});

  @override
  State<LanSyncScreen> createState() => _LanSyncScreenState();
}

class _LanSyncScreenState extends State<LanSyncScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textSecondary => _p.textSecondary;
  Color get _mutedText => _p.textMuted;
  Color get _danger => _p.danger;
  Color get _textFaint => _p.textFaint;

  late final LanSyncHost _host;
  final _client = LanSyncClient();
  late final BackupService _backupService;

  LanSyncHostInfo? _hostInfo;
  bool _hosting = false;
  String? _hostStatusMessage;

  final _hostFieldController = TextEditingController();
  final _portFieldController = TextEditingController(text: '');
  final _pinFieldController = TextEditingController();
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _host = LanSyncHost(AppDatabase.instance);
    _backupService = BackupService(AppDatabase.instance);
  }

  @override
  void dispose() {
    _host.stop();
    _hostFieldController.dispose();
    _portFieldController.dispose();
    _pinFieldController.dispose();
    super.dispose();
  }

  Future<void> _startHosting() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _hosting = true;
      _hostStatusMessage = null;
    });
    final info = await _host.start(
      onExported: () {
        if (mounted) {
          setState(() {
            _hosting = false;
            _hostStatusMessage = l10n.lanSyncExportedMessage;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _hosting = false;
            _hostStatusMessage = l10n.lanSyncExportFailedMessage(e);
          });
        }
      },
    );
    if (!mounted) {
      await _host.stop();
      return;
    }
    setState(() => _hostInfo = info);
  }

  Future<void> _stopHosting() async {
    await _host.stop();
    if (mounted) {
      setState(() {
        _hosting = false;
        _hostInfo = null;
      });
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    final host = _hostFieldController.text.trim();
    final port = int.tryParse(_portFieldController.text.trim());
    final pin = _pinFieldController.text.trim();
    if (host.isEmpty || port == null || pin.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(l10n.lanSyncImportConfirmTitle, style: TextStyle(color: _textPrimary)),
        content: Text(
          l10n.lanSyncImportConfirmContent,
          style: TextStyle(color: _textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: TextStyle(color: _mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.lanSyncImportButton, style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _importing = true);
    try {
      final bytes = await _client.fetch(host: host, port: port, pin: pin);
      final summary = await _backupService.restoreFromBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.myPageImportSuccessMessage(summary.plotCount, summary.chatMessageCount, summary.lorebookCount),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lanSyncImportFailedMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
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
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.lanSyncScreenTitle,
          style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExportSection(l10n),
            const SizedBox(height: 24),
            _buildImportSection(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(AppLocalizations l10n) {
    final info = _hostInfo;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lanSyncExportSectionTitle,
            style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lanSyncExportSectionDescription,
            style: TextStyle(color: _textFaint, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (info != null) ...[
            if (info.addresses.isEmpty)
              Text(l10n.lanSyncNoAddressWarning, style: TextStyle(color: _danger, fontSize: 12.5))
            else ...[
              _infoRow(l10n.lanSyncAddressLabel, info.addresses.join(', ')),
              _infoRow(l10n.lanSyncPortLabel, info.port.toString()),
              _infoRow(l10n.lanSyncPinLabel, info.pin),
            ],
            const SizedBox(height: 8),
            if (_hosting)
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.lanSyncWaitingMessage, style: TextStyle(color: _mutedText, fontSize: 12.5)),
                ],
              ),
            if (_hostStatusMessage != null)
              Text(_hostStatusMessage!, style: TextStyle(color: _textSecondary, fontSize: 12.5)),
            const SizedBox(height: 12),
          ],
          OutlinedButton(
            onPressed: _hosting ? _stopHosting : _startHosting,
            style: OutlinedButton.styleFrom(
              foregroundColor: _textPrimary,
              side: BorderSide(color: _borderGrey),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(_hosting ? l10n.lanSyncStopHostButton : l10n.lanSyncStartHostButton),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: TextStyle(color: _textFaint, fontSize: 12.5)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lanSyncImportSectionTitle,
            style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lanSyncImportSectionDescription,
            style: TextStyle(color: _textFaint, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          _importField(l10n.lanSyncHostFieldLabel, _hostFieldController),
          const SizedBox(height: 10),
          _importField(l10n.lanSyncPortFieldLabel, _portFieldController, keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          _importField(l10n.lanSyncPinFieldLabel, _pinFieldController, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _importing ? null : _import,
            style: OutlinedButton.styleFrom(
              foregroundColor: _textPrimary,
              side: BorderSide(color: _borderGrey),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: _importing
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _textSecondary),
                  )
                : const Icon(Icons.wifi_tethering, size: 16),
            label: Text(l10n.lanSyncImportButton),
          ),
        ],
      ),
    );
  }

  Widget _importField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textFaint, fontSize: 13),
        filled: true,
        fillColor: _background,
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
    );
  }
}
