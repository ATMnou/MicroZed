import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'data/app_theme_preferences.dart';
import 'data/chat_image_preferences.dart';
import 'data/db/database.dart';
import 'data/db/seed.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/home_screen.dart';

final localeController = LocaleController();
final chatImagePreferences = ChatImagePreferences();
final appThemePreferences = AppThemePreferences();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedIfEmpty(AppDatabase.instance);
  await localeController.load();
  await chatImagePreferences.load();
  await appThemePreferences.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return ValueListenableBuilder<AppThemeMode>(
          valueListenable: appThemePreferences,
          builder: (context, appThemeMode, _) {
            final ThemeMode themeMode;
            final ThemeData darkVariant;
            switch (appThemeMode) {
              case AppThemeMode.light:
                themeMode = ThemeMode.light;
                darkVariant = kDarkTheme;
              case AppThemeMode.dark:
                themeMode = ThemeMode.dark;
                darkVariant = kDarkTheme;
              case AppThemeMode.amoled:
                themeMode = ThemeMode.dark;
                darkVariant = kAmoledTheme;
              case AppThemeMode.system:
                themeMode = ThemeMode.system;
                darkVariant = kDarkTheme;
            }
            return MaterialApp(
              title: 'Microzed',
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: themeMode,
              theme: kLightTheme,
              darkTheme: darkVariant,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
