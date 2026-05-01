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

  // Load saved language BEFORE setting up Translations
  await Hive.initFlutter('OpenAir/.hive_config');
  final box = await Hive.openBox('openAirBox');
  final settings = box.get('userInterface');
  final language = settings?['language'] ?? 'English';

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

  // Set the language BEFORE runApp
  _setLanguage(language);

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

  runApp(ProviderScope(child: const MyApp()));
}

void _setLanguage(String language) {
  // Update the config
  languageConfig = language;

  switch (language) {
    case 'English':
      Translations.changeLanguage(Localization.en_US);
      break;
    case 'Spanish':
      Translations.changeLanguage(Localization.es_ES);
      break;
    case 'French':
      Translations.changeLanguage(Localization.fr_FR);
      break;
    case 'German':
      Translations.changeLanguage(Localization.de_DE);
      break;
    case 'Italian':
      Translations.changeLanguage(Localization.it_IT);
      break;
    case 'Portuguese':
      Translations.changeLanguage(Localization.pt_PT);
      break;
    case 'Russian':
      Translations.changeLanguage(Localization.ru_RU);
      break;
    case 'Chinese':
      Translations.changeLanguage(Localization.zh_CN);
      break;
    case 'Japanese':
      Translations.changeLanguage(Localization.ja_JP);
      break;
    case 'Korean':
      Translations.changeLanguage(Localization.ko_KR);
      break;
    case 'Arabic':
      Translations.changeLanguage(Localization.ar_AE);
      break;
    case 'Hebrew':
      Translations.changeLanguage(Localization.he_IL);
      break;
    case 'Dutch':
      Translations.changeLanguage(Localization.nl_NL);
      break;
    case 'Swedish':
      Translations.changeLanguage(Localization.sv_SE);
      break;
    default:
      Translations.changeLanguage(Localization.en_US);
  }
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
      // Default theme - will be overridden by _loadSavedTheme() if needed
      defaultThemeId: 'blue_accent_light_medium',
      saveThemesOnChange: true,
      loadThemeOnInit: false, // We'll load manually to handle Auto mode
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
            textTheme: scaleTextTheme(baseTextTheme, 0.875),
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
            textTheme: scaleTextTheme(baseTextTheme, 0.875),
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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

    // Load saved theme
    _loadSavedTheme();

    // Listen for system theme changes
    WidgetsBinding.instance.addObserver(this);

    // Minimum 2 second delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _minDelayPassed = true);
      }
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      _applySystemTheme();
    }
  }

  void _applySystemTheme() {
    if (!mounted || themeModeConfig != 'System') return;

    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final sizeSuffix = _getSizeSuffix(fontSizeConfig);
    final themeSuffix = brightness == Brightness.dark ? 'dark' : 'light';
    final themeId = 'blue_accent_${themeSuffix}_$sizeSuffix';

    ThemeProvider.controllerOf(context).setTheme(themeId);
  }

  String _getSizeSuffix(String fontSizeFactor) {
    switch (fontSizeFactor) {
      case 'Small':
        return 'small';
      case 'Large':
        return 'large';
      case 'Extra Large':
        return 'extra_large';
      default:
        return 'medium';
    }
  }

  void _loadSavedTheme() async {
    try {
      final box = await Hive.openBox('openAirBox');
      final settings = box.get('userInterface');

      if (settings != null && mounted) {
        final fontSizeFactor = settings['fontSizeFactor'] ?? 'Medium';
        final themeMode = settings['themeMode'] ?? 'Light';

        fontSizeConfig = fontSizeFactor;
        themeModeConfig = themeMode;

        String sizeSuffix = _getSizeSuffix(fontSizeFactor);
        String themeSuffix;

        if (themeMode == 'System') {
          final brightness =
              View.of(context).platformDispatcher.platformBrightness;
          themeSuffix = brightness == Brightness.dark ? 'dark' : 'light';
        } else {
          themeSuffix = themeMode == 'Dark' ? 'dark' : 'light';
        }

        final themeId = 'blue_accent_${themeSuffix}_$sizeSuffix';
        ThemeProvider.controllerOf(context).setTheme(themeId);
      }
    } catch (e) {
      debugPrint('Error loading saved theme: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                  style: widget.themeData.textTheme.headlineLarge?.copyWith(
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
