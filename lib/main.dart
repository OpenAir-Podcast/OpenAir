import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/responsive/desktop_scaffold.dart';
import 'package:openair/responsive/mobile_scaffold.dart';
import 'package:openair/responsive/responsive_layout.dart';
import 'package:openair/responsive/tablet_scaffold.dart';
import 'package:openair/views/mobile/nav_pages/settings_page.dart';
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                // backgroundColor:
                //     ThemeProvider.themeOf(context).data.scaffoldBackgroundColor,
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // If initialization fails, show an error message.
          if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'App initialization failed:\n${snapshot.error}\n${snapshot.stackTrace}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          final settings = ref.watch(settingsDataProvider);

          return settings.when(
            data: (data) {
              debugPrint(data!.getFontSizeFactor.toString());

              return ThemeProvider(
                defaultThemeId: 'blue_accent_light',
                saveThemesOnChange: true,
                loadThemeOnInit: true,
                themes: [
                  AppTheme(
                    id: "blue_accent_light",
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
                            fontSizeFactor: data.getFontSizeFactor,
                          ),
                    ),
                  ),
                  AppTheme(
                    id: "blue_accent_dark",
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
                            fontSizeFactor: data.getFontSizeFactor,
                          ),
                    ),
                  ),
                  AppTheme(
                    id: "blue_accent_amoled",
                    description: "AMOLED theme with blue accent",
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
                      cardColor: Colors.black,
                      colorScheme: ColorScheme.dark(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        secondary: Colors.blueAccent,
                        onSecondary: Colors.white,
                        surface: Colors.grey[850]!,
                        onSurface: Colors.white,
                        error: Colors.redAccent,
                        onError: Colors.black,
                      ),
                      textTheme: Theme.of(context).textTheme.apply(
                            fontSizeFactor: data.getFontSizeFactor,
                          ),
                    ),
                  ),
                ],
                child: ThemeConsumer(
                  child: Builder(
                    builder: (themeContext) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'OpenAir',
                        theme: ThemeProvider.themeOf(themeContext).data,
                        home: const ResponsiveLayout(
                          mobileScaffold: MobileScaffold(),
                          tabletScaffold: TabletScaffold(),
                          desktopScaffold: DesktopScaffold(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            error: (error, stackTrace) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: Text('Error: $error\n$stackTrace'),
                  ),
                ),
              );
            },
            loading: () {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            },
          );
        });
  }
}
