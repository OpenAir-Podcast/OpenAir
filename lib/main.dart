import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/responsive/desktop_scaffold.dart';
import 'package:openair/responsive/mobile_scaffold.dart';
import 'package:openair/responsive/responsive_layout.dart';
import 'package:openair/responsive/tablet_scaffold.dart';
import 'package:openair/views/mobile/settings_pages/user_interface_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:openair/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(1200, 768),
      title: 'OpenAir',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  try {
    // Load the .env file
    await dotenv.load(fileName: '.env');
  } on FileNotFoundError catch (_, e) {
    debugPrint('Error loading .env file: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_PROJECT_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
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
    // We only want to run initialization once.
    _initialization ??= _initApp();
  }

  /// Initializes all necessary app services.
  Future<void> _initApp() async {
    // Now initialize the main provider which needs context.
    if (mounted) await ref.read(openAirProvider).initial(context);
    if (mounted) await ref.read(audioProvider).initAudio(context);
    if (mounted) await ref.read(notificationProvider).init(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          Translations.support(
            [
              Localization.ar_AE, // Arabic (UAE)
              Localization.de_DE, // Germany
              Localization.es_ES, // Spain
              Localization.en_US, // United States
              Localization.fr_FR, // France
              Localization.he_IL, // Israel
              Localization.it_IT, // Italy
              Localization.ja_JP, // Japan
              Localization.ko_KR, // South Korea
              Localization.nl_NL, // Netherlands
              Localization.pt_PT, // Portugal
              Localization.ru_RU, // Russia
              Localization.sv_SE, // Sweden
              Localization.zh_CN, // China
            ],
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
                  scaffoldBackgroundColor: scaffoldBackgroundColorLight,
                  primaryColor: primaryColorLight,
                  appBarTheme: appBarThemeLight,
                  floatingActionButtonTheme: floatingActionButtonTheme,
                  cardColor: cardColorLight,
                  colorScheme: colorSchemeLight,
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 0.875,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.0,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.125,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.25,
                  ),
                  snackBarTheme: snackBarThemeLight,
                  listTileTheme: listTileThemeLight,
                ),
              ),
              // Dark Theme
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 0.875,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.0,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.125,
                  ),
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
                  textTheme: const TextTheme().apply(
                    fontSizeFactor: 1.25,
                  ),
                  snackBarTheme: snackBarThemeDark,
                  listTileTheme: listTileThemeDark,
                ),
              ),
            ],
            child: ThemeConsumer(
              child: Builder(
                builder: (themeContext) {
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

                  // Load user interface settings
                  AsyncValue<Map?> userInterfaceSettings =
                      ref.watch(userInterfaceSettingsDataProvider);

                  Future.delayed(
                    const Duration(milliseconds: 5000),
                  );

                  return MaterialApp(
                    supportedLocales: Translations.supportedLocales,
                    localizationsDelegates: const [
                      LocalizationsPlusDelegate(),
                      FallbackCupertinoLocalizationsDelegate()
                    ],
                    debugShowCheckedModeBanner: false,
                    title: 'OpenAir',
                    theme: themeData,
                    home: userInterfaceSettings.when(
                      data: (data) {
                        Translations.changeLanguage(data!['locale']);

                        final hasConnection =
                            ref.watch(openAirProvider).hasConnection;
                        if (!hasConnection) {
                          return const NoConnection();
                        }

                        return const ResponsiveLayout(
                          mobileScaffold: MobileScaffold(),
                          tabletScaffold: TabletScaffold(),
                          desktopScaffold: DesktopScaffold(),
                        );
                      },
                      error: (error, stackTrace) {
                        debugPrint(
                            'Error loading user interface settings: $error\n$stackTrace');

                        return Scaffold(
                          body: Center(
                            child: Text(
                                textAlign: TextAlign.center,
                                'Error loading user interface settings: $error\n$stackTrace',
                                style: TextStyle(
                                  color: Colors.red[700],
                                )),
                          ),
                        );
                      },
                      loading: () => Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
