import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/db/database.dart';
import 'data/db/seed.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/home_screen.dart';

final localeController = LocaleController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedIfEmpty(AppDatabase.instance);
  await localeController.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (context, locale, _) {
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
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF141414),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7A6FF0),
              brightness: Brightness.dark,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
