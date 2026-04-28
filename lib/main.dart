import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:openair/config/config.dart';
import 'package:openair/home.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:openair/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Translations.support([
    Localization.ar_AE,
    Localization.de_DE,
    Localization.es_ES,
    Localization.en_US,
    Localization.fr_FR,
    Localization.he_IL,
    Localization.it_IT,
    Localization.ja_JP,
    Localization.ko_KR,
    Localization.nl_NL,
    Localization.pt_PT,
    Localization.ru_RU,
    Localization.sv_SE,
    Localization.zh_CN,
  ]);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(720, 600),
      title: 'OpenAir',
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  try {
    await dotenv.load(fileName: '.env');
  } on FileNotFoundError catch (_, e) {
    debugPrint('Error loading .env file: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_PROJECT_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
    debug: false,
  );

  await Hive.initFlutter('OpenAir/.hive_config');

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Future<void>? _initialization;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialization ??= _initApp();
  }

  Future<void> _initApp() async {
    if (mounted) await ref.read(openAirProvider).initial(context);
    if (mounted) await ref.read(audioProvider).initAudio(context);
    if (mounted) await ref.read(notificationProvider).init(context);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      defaultThemeId: 'blue_accent_light_extra_large',
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      themes: [
        AppTheme(
          id: "blue_accent_light_small",
          description: "Light theme with blue accent",
          data: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: scaffoldBackgroundColorLight,
            primaryColor: primaryColorLight,
            appBarTheme: appBarThemeLight,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorLight,
            colorScheme: colorSchemeLight,
            textTheme: scaleTextTheme(baseTextTheme, 0.8),
            snackBarTheme: snackBarThemeLight,
            listTileTheme: listTileThemeLight,
          ),
        ),
        AppTheme(
          id: "blue_accent_light_medium",
          description: "Light theme with blue accent",
          data: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: scaffoldBackgroundColorLight,
            primaryColor: primaryColorLight,
            appBarTheme: appBarThemeLight,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorLight,
            colorScheme: colorSchemeLight,
            textTheme: scaleTextTheme(baseTextTheme, 1.0),
            snackBarTheme: snackBarThemeLight,
            listTileTheme: listTileThemeLight,
          ),
        ),
        AppTheme(
          id: "blue_accent_light_large",
          description: "Light theme with blue accent",
          data: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: scaffoldBackgroundColorLight,
            primaryColor: primaryColorLight,
            appBarTheme: appBarThemeLight,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorLight,
            colorScheme: colorSchemeLight,
            textTheme: scaleTextTheme(baseTextTheme, 1.2),
            snackBarTheme: snackBarThemeLight,
            listTileTheme: listTileThemeLight,
          ),
        ),
        AppTheme(
          id: "blue_accent_light_extra_large",
          description: "Light theme with blue accent",
          data: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: scaffoldBackgroundColorLight,
            primaryColor: primaryColorLight,
            appBarTheme: appBarThemeLight,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorLight,
            colorScheme: colorSchemeLight,
            textTheme: scaleTextTheme(baseTextTheme, 1.4),
            snackBarTheme: snackBarThemeLight,
            listTileTheme: listTileThemeLight,
          ),
        ),
        AppTheme(
          id: "blue_accent_dark_small",
          description: "Dark theme with blue accent",
          data: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: scaffoldBackgroundColorDark,
            primaryColor: primaryColorDark,
            appBarTheme: appBarThemeDark,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorDark,
            colorScheme: colorSchemeDark,
            textTheme: scaleTextTheme(baseTextTheme, 0.8),
            snackBarTheme: snackBarThemeDark,
            listTileTheme: listTileThemeDark,
          ),
        ),
        AppTheme(
          id: "blue_accent_dark_medium",
          description: "Dark theme with blue accent",
          data: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: scaffoldBackgroundColorDark,
            primaryColor: primaryColorDark,
            appBarTheme: appBarThemeDark,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorDark,
            colorScheme: colorSchemeDark,
            textTheme: scaleTextTheme(baseTextTheme, 1.0),
            snackBarTheme: snackBarThemeDark,
            listTileTheme: listTileThemeDark,
          ),
        ),
        AppTheme(
          id: "blue_accent_dark_large",
          description: "Dark theme with blue accent",
          data: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: scaffoldBackgroundColorDark,
            primaryColor: primaryColorDark,
            appBarTheme: appBarThemeDark,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorDark,
            colorScheme: colorSchemeDark,
            textTheme: scaleTextTheme(baseTextTheme, 1.2),
            snackBarTheme: snackBarThemeDark,
            listTileTheme: listTileThemeDark,
          ),
        ),
        AppTheme(
          id: "blue_accent_dark_extra_large",
          description: "Dark theme with blue accent",
          data: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: scaffoldBackgroundColorDark,
            primaryColor: primaryColorDark,
            appBarTheme: appBarThemeDark,
            floatingActionButtonTheme: floatingActionButtonTheme,
            cardColor: cardColorDark,
            colorScheme: colorSchemeDark,
            textTheme: scaleTextTheme(baseTextTheme, 1.4),
            snackBarTheme: snackBarThemeDark,
            listTileTheme: listTileThemeDark,
          ),
        ),
      ],
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            final themeData = ThemeProvider.themeOf(themeContext).data;

            return _AppHome(
              initialization: _initialization,
              themeData: themeData,
            );
          },
        ),
      ),
    );
  }
}

class _AppHome extends ConsumerStatefulWidget {
  final Future<void>? initialization;
  final ThemeData themeData;

  const _AppHome({
    this.initialization,
    required this.themeData,
  });

  @override
  ConsumerState<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends ConsumerState<_AppHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _minDelayPassed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();

    // Minimum 2 second delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _minDelayPassed = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.initialization,
      builder: (context, snapshot) {
        final initDone = snapshot.connectionState == ConnectionState.done;

        // Show splash while: init not done OR min delay not passed
        if (!initDone || !_minDelayPassed) {
          return _buildSplash();
        }

        // Show Home
        final locale = ref.watch(localeProvider);
        return MaterialApp(
          locale: locale,
          supportedLocales: Translations.supportedLocales,
          localizationsDelegates: const [
            LocalizationsPlusDelegate(),
            FallbackCupertinoLocalizationsDelegate()
          ],
          debugShowCheckedModeBanner: false,
          title: 'OpenAir',
          theme: widget.themeData,
          home: Home(),
        );
      },
    );
  }

  Widget _buildSplash() {
    return MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: Translations.supportedLocales,
      localizationsDelegates: const [
        LocalizationsPlusDelegate(),
        FallbackCupertinoLocalizationsDelegate()
      ],
      debugShowCheckedModeBanner: false,
      title: 'OpenAir',
      theme: widget.themeData,
      home: Scaffold(
        backgroundColor: widget.themeData.colorScheme.primary,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.radio,
                  size: 100,
                  color: widget.themeData.colorScheme.onPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  'OpenAir',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.themeData.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.themeData.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
