import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';
import '../l10n/app_localizations.dart';

class _ApiKeyProviderLink {
  const _ApiKeyProviderLink({
    required this.name,
    required this.description,
    required this.url,
    this.referralNote,
  });

  final String name;
  final String description;
  final String url;
  final String? referralNote;
}

/// AI 프리셋 설정 화면 > 'API 키 발급 안내' 버튼이 여는 다이얼로그. OpenRouter/Featherless/
/// AtlasCloud 각각의 키 발급 페이지로 바로 이동할 수 있고, 레퍼럴 링크를 쓴 두 곳은
/// 가입 시 받는 혜택도 함께 안내한다.
Future<void> showApiKeyGuideDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final providers = [
    _ApiKeyProviderLink(
      name: 'OpenRouter',
      description: l10n.apiKeyGuideOpenRouterDescription,
      url: 'https://openrouter.ai/keys',
    ),
    _ApiKeyProviderLink(
      name: 'Featherless',
      description: l10n.apiKeyGuideFeatherlessDescription,
      url: 'https://featherless.ai/register?referrer=4PUP8PVP',
      referralNote: l10n.apiKeyGuideFeatherlessReferralNote,
    ),
    _ApiKeyProviderLink(
      name: 'AtlasCloud',
      description: l10n.apiKeyGuideAtlasCloudDescription,
      url: 'https://www.atlascloud.ai?ref=FZCPUG',
      referralNote: l10n.apiKeyGuideAtlasCloudReferralNote,
    ),
  ];

  return showDialog(
    context: context,
    builder: (dialogContext) {
      final p = PaletteScope.of(dialogContext);
      return AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.apiKeyGuideDialogTitle, style: TextStyle(color: p.textPrimary)),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final provider in providers) ...[
                  _ProviderTile(provider: provider, palette: p),
                  if (provider != providers.last) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose, style: TextStyle(color: p.textMuted)),
          ),
        ],
      );
    },
  );
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.provider, required this.palette});

  final _ApiKeyProviderLink provider;
  final ColorPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.name,
                  style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton(
                onPressed: () => launchUrl(Uri.parse(provider.url), mode: LaunchMode.externalApplication),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.primary,
                  side: BorderSide(color: palette.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.apiKeyGuideOpenButton, style: const TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(provider.description, style: TextStyle(color: palette.textSecondary, fontSize: 12.5, height: 1.4)),
          if (provider.referralNote != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.redeem_outlined, size: 14, color: palette.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    provider.referralNote!,
                    style: TextStyle(color: palette.primary, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
