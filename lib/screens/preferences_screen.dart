import 'package:flutter/material.dart';

import '../data/chat_image_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

/// 마이페이지 > '환경설정'. 채팅에 붙는 인트로/스냅샷 이미지를 정사각형으로 보여줄지,
/// 가로를 꽉 채워서 보여줄지 고른다.
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

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
          l10n.preferencesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.preferencesImageDisplayModeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.preferencesImageDisplayModeDescription,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<ChatImageDisplayMode>(
              valueListenable: chatImagePreferences,
              builder: (context, mode, _) {
                return Column(
                  children: ChatImageDisplayMode.values.map((option) {
                    final selected = option == mode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => chatImagePreferences.setMode(option),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? _purple : _borderGrey,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option == ChatImageDisplayMode.square
                                      ? l10n.preferencesImageDisplaySquareOption
                                      : l10n.preferencesImageDisplayFullWidthOption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check,
                                  color: _purple,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
