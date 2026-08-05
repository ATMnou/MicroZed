import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/chat_image_preferences.dart';
import 'data/db/database.dart';
import 'data/db/seed.dart';
import 'data/theme/palette_controller.dart';
import 'data/theme/palette_scope.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/home_screen.dart';

final localeController = LocaleController();
final chatImagePreferences = ChatImagePreferences();
final paletteController = PaletteController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedIfEmpty(AppDatabase.instance);
  await localeController.load();
  await chatImagePreferences.load();
  await paletteController.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    paletteController.updatePlatformBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    paletteController.updatePlatformBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return ListenableBuilder(
          listenable: paletteController,
          builder: (context, _) {
            final theme = paletteController.active.toThemeData();
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
              themeMode: ThemeMode.light,
              theme: theme,
              darkTheme: theme,
              builder: (context, child) => PaletteScope(child: child!),
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
