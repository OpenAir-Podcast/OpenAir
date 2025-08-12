import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/responsive/desktop_scaffold.dart';
import 'package:openair/responsive/mobile_scaffold.dart';
import 'package:openair/responsive/responsive_layout.dart';
import 'package:openair/responsive/tablet_scaffold.dart';
import 'package:theme_provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Load the .env file
    await dotenv.load(fileName: '.env');
  } on FileNotFoundError catch (_, e) {
    debugPrint('Error loading .env file: $e');
  }

  await Hive.initFlutter('OpenAir/.hive_config');
  runApp(const ProviderScope(child: MyApp()));
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
    // We only want to run initialization once.
    _initialization ??= _initApp();
  }

  /// Initializes all necessary app services.
  Future<void> _initApp() async {
    // Initialize Hive first, as other providers might depend on it.
    await ref.read(hiveServiceProvider).initial();

    // Now initialize the main provider which needs context.
    if (mounted) await ref.read(openAirProvider).initial(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          Translations.support(
            [
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
            ],
            // selected: Localization.en_US,
            // fallback: Localization.en_US,
          );

          return ThemeProvider(
            defaultThemeId: 'blue_accent_light_medium',
            saveThemesOnChange: true,
            loadThemeOnInit: true,
            themes: [
              // Light Theme
              AppTheme(
                id: "blue_accent_light_small",
                description: "Light theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[50],
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[100]!,
                    onSurface: Colors.black,
                    error: Colors.red[700]!,
                    onError: Colors.white,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 0.875,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_light_medium",
                description: "Light theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[50],
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[100]!,
                    onSurface: Colors.black,
                    error: Colors.red[700]!,
                    onError: Colors.white,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.0,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_light_large",
                description: "Light theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[50],
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[100]!,
                    onSurface: Colors.black,
                    error: Colors.red[700]!,
                    onError: Colors.white,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.125,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_light_extra_large",
                description: "Light theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[50],
                  colorScheme: ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[100]!,
                    onSurface: Colors.black,
                    error: Colors.red[700]!,
                    onError: Colors.white,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.25,
                      ),
                ),
              ),
              // Dark Theme
              AppTheme(
                id: "blue_accent_dark_small",
                description: "Dark theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[900],
                  colorScheme: ColorScheme.dark(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[850]!,
                    onSurface: Colors.white,
                    error: Colors.red[400]!,
                    onError: Colors.black,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 0.875,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_dark_medium",
                description: "Dark theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[900],
                  colorScheme: ColorScheme.dark(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[850]!,
                    onSurface: Colors.white,
                    error: Colors.red[400]!,
                    onError: Colors.black,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.0,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_dark_large",
                description: "Dark theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[900],
                  colorScheme: ColorScheme.dark(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[850]!,
                    onSurface: Colors.white,
                    error: Colors.red[400]!,
                    onError: Colors.black,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.125,
                      ),
                ),
              ),
              AppTheme(
                id: "blue_accent_dark_extra_large",
                description: "Dark theme with blue accent",
                data: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  primaryColor: Colors.blue,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.blue,
                  ),
                  floatingActionButtonTheme:
                      const FloatingActionButtonThemeData(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  cardColor: Colors.grey[900],
                  colorScheme: ColorScheme.dark(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    secondary: Colors.blueAccent,
                    onSecondary: Colors.white,
                    surface: Colors.grey[850]!,
                    onSurface: Colors.white,
                    error: Colors.red[400]!,
                    onError: Colors.black,
                  ),
                  textTheme: Theme.of(context).textTheme.apply(
                        fontSizeFactor: 1.25,
                      ),
                ),
              ),
            ],
            child: ThemeConsumer(
              child: Builder(
                builder: (themeContext) {
                  try {
                    final themeData = ThemeProvider.themeOf(themeContext).data;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return MaterialApp(
                        supportedLocales: Translations.supportedLocales,
                        localizationsDelegates: const [
                          LocalizationsPlusDelegate(),
                          FallbackCupertinoLocalizationsDelegate()
                        ],
                        debugShowCheckedModeBanner: false,
                        title: 'OpenAir',
                        theme: themeData,
                        home: Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    return MaterialApp(
                      supportedLocales: Translations.supportedLocales,
                      localizationsDelegates: const [
                        LocalizationsPlusDelegate(),
                        FallbackCupertinoLocalizationsDelegate()
                      ],
                      debugShowCheckedModeBanner: false,
                      title: 'OpenAir',
                      theme: themeData,
                      home: ResponsiveLayout(
                        mobileScaffold: MobileScaffold(),
                        tabletScaffold: TabletScaffold(),
                        desktopScaffold: DesktopScaffold(),
                      ),
                    );
                  } catch (e, stack) {
                    debugPrint(
                        'ThemeProvider or MaterialApp error: $e\n$stack');
                    return MaterialApp(
                      home: Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
