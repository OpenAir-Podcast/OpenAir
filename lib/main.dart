import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
// import 'package:openair/models/settings_model.dart';
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
        // While waiting for initialization to complete, show a loading spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
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
                    'App initialization failed:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        // Once initialization is complete, build the main app UI.
        return ThemeProvider(
          saveThemesOnChange: true,
          loadThemeOnInit: true,
          // onInitCallback: (controller, previouslySavedThemeFuture) async {
          //   SettingsModel? settings =
          //       await ref.watch(hiveServiceProvider).getSettings();

          //   if (settings.themeModeString == 'System') {
          //     if (context.mounted) {
          //       Brightness platformBrightness =
          //           View.of(context).platformDispatcher.platformBrightness;

          //       if (platformBrightness == Brightness.dark) {
          //         switch (settings.accentColor) {
          //           case 'Blue':
          //             controller.setTheme('blue_accent_dark');
          //             break;
          //           case 'Red':
          //             controller.setTheme('red_accent_dark');
          //             break;
          //           case 'Green':
          //             controller.setTheme('green_accent_dark');
          //             break;
          //           case 'Yellow':
          //             controller.setTheme('yellow_accent_dark');
          //             break;
          //           case 'Orange':
          //             controller.setTheme('orange_accent_dark');
          //             break;
          //           case 'Purple':
          //             controller.setTheme('purple_accent_dark');
          //             break;
          //           case 'Pink':
          //             controller.setTheme('pink_accent_dark');
          //             break;
          //           case 'Teal':
          //             controller.setTheme('teal_accent_dark');
          //             break;
          //           case 'Cyan':
          //             controller.setTheme('cyan_accent_dark');
          //             break;
          //           case 'Indigo':
          //             controller.setTheme('indigo_accent_dark');
          //             break;
          //           default:
          //             controller.setTheme('blue_accent_dark');
          //         }
          //       } else {
          //         switch (settings.accentColor) {
          //           case 'Blue':
          //             controller.setTheme('blue_accent_light');
          //             break;
          //           case 'Red':
          //             controller.setTheme('red_accent_light');
          //             break;
          //           case 'Green':
          //             controller.setTheme('green_accent_light');
          //             break;
          //           case 'Yellow':
          //             controller.setTheme('yellow_accent_light');
          //             break;
          //           case 'Orange':
          //             controller.setTheme('orange_accent_light');
          //             break;
          //           case 'Purple':
          //             controller.setTheme('purple_accent_light');
          //             break;
          //           case 'Pink':
          //             controller.setTheme('pink_accent_light');
          //             break;
          //           case 'Teal':
          //             controller.setTheme('teal_accent_light');
          //             break;
          //           case 'Cyan':
          //             controller.setTheme('cyan_accent_light');
          //             break;
          //           case 'Indigo':
          //             controller.setTheme('indigo_accent_light');
          //             break;
          //           default:
          //             controller.setTheme('blue_accent_light');
          //         }
          //       }

          //       controller.forgetSavedTheme();
          //     }
          //   } else if (settings.themeModeString == 'Light') {
          //     switch (settings.accentColor) {
          //       case 'Blue':
          //         controller.setTheme('blue_accent_light');
          //         break;
          //       case 'Red':
          //         controller.setTheme('red_accent_light');
          //         break;
          //       case 'Green':
          //         controller.setTheme('green_accent_light');
          //         break;
          //       case 'Yellow':
          //         controller.setTheme('yellow_accent_light');
          //         break;
          //       case 'Orange':
          //         controller.setTheme('orange_accent_light');
          //         break;
          //       case 'Purple':
          //         controller.setTheme('purple_accent_light');
          //         break;
          //       case 'Pink':
          //         controller.setTheme('pink_accent_light');
          //         break;
          //       case 'Teal':
          //         controller.setTheme('teal_accent_light');
          //         break;
          //       case 'Cyan':
          //         controller.setTheme('cyan_accent_light');
          //         break;
          //       case 'Indigo':
          //         controller.setTheme('indigo_accent_light');
          //         break;
          //       default:
          //         controller.setTheme('blue_accent_light');
          //     }

          //     controller.forgetSavedTheme();
          //   } else if (settings.themeModeString == 'Dark') {
          //     switch (settings.accentColor) {
          //       case 'Blue':
          //         controller.setTheme('blue_accent_dark');
          //         break;
          //       case 'Red':
          //         controller.setTheme('red_accent_dark');
          //         break;
          //       case 'Green':
          //         controller.setTheme('green_accent_dark');
          //         break;
          //       case 'Yellow':
          //         controller.setTheme('yellow_accent_dark');
          //         break;
          //       case 'Orange':
          //         controller.setTheme('orange_accent_dark');
          //         break;
          //       case 'Purple':
          //         controller.setTheme('purple_accent_dark');
          //         break;
          //       case 'Pink':
          //         controller.setTheme('pink_accent_dark');
          //         break;
          //       case 'Teal':
          //         controller.setTheme('teal_accent_dark');
          //         break;
          //       case 'Cyan':
          //         controller.setTheme('cyan_accent_dark');
          //         break;
          //       case 'Indigo':
          //         controller.setTheme('indigo_accent_dark');
          //         break;
          //       default:
          //         controller.setTheme('blue_accent_dark');
          //     }

          //     controller.forgetSavedTheme();
          //   } else if (settings.themeModeString == 'Black/AMOLED') {
          //     switch (settings.accentColor) {
          //       case 'Blue':
          //         controller.setTheme('blue_accent_amoled');
          //         break;
          //       case 'Red':
          //         controller.setTheme('red_accent_amoled');
          //         break;
          //       case 'Green':
          //         controller.setTheme('green_accent_amoled');
          //         break;
          //       case 'Yellow':
          //         controller.setTheme('yellow_accent_amoled');
          //         break;
          //       case 'Orange':
          //         controller.setTheme('orange_accent_amoled');
          //         break;
          //       case 'Purple':
          //         controller.setTheme('purple_accent_amoled');
          //         break;
          //       case 'Pink':
          //         controller.setTheme('pink_accent_amoled');
          //         break;
          //       case 'Teal':
          //         controller.setTheme('teal_accent_amoled');
          //         break;
          //       case 'Cyan':
          //         controller.setTheme('cyan_accent_amoled');
          //         break;
          //       case 'Indigo':
          //         controller.setTheme('indigo_accent_amoled');
          //         break;
          //       default:
          //         controller.setTheme('blue_accent_amoled');
          //     }

          //     controller.forgetSavedTheme();
          //   }
          // },
          themes: [
            // BLUE ACCENTS
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
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
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
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
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
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
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
              ),
            ),
            // RED ACCENTS
            AppTheme(
              id: "red_accent_light",
              description: "Light theme with red accent",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.red,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  secondary: Colors.redAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "red_accent_dark",
              description: "Dark theme with red accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.red,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.red,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  secondary: Colors.redAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "red_accent_amoled",
              description: "AMOLED theme with red accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.red,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.red,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  secondary: Colors.redAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // GREEN ACCENTS
            AppTheme(
              id: "green_accent_light",
              description: "Light theme with green accent",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.green,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  secondary: Colors.greenAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "green_accent_dark",
              description: "Dark theme with green accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.green,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.green,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  secondary: Colors.greenAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "green_accent_amoled",
              description: "AMOLED green theme",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.green,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.green,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  secondary: Colors.greenAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // YELLOW ACCENTS
            AppTheme(
              id: "yellow_accent_light",
              description: "Light yellow theme",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.yellow,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.yellow,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.yellow,
                  onPrimary: Colors.black,
                  secondary: Colors.yellowAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "yellow_accent_dark",
              description: "Dark theme with yellow accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.yellow,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.yellow,
                  onPrimary: Colors.black,
                  secondary: Colors.yellowAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "yellow_accent_amoled",
              description: "AMOLED yellow theme",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.yellow,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.yellow,
                  onPrimary: Colors.black,
                  secondary: Colors.yellowAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // ORANGE ACCENTS
            AppTheme(
              id: "orange_accent_light",
              description: "Light orange theme",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.orange,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  secondary: Colors.orangeAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "orange_accent_dark",
              description: "Dark theme with orange accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.orange,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.orange,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  secondary: Colors.orangeAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "orange_accent_amoled",
              description: "AMOLED orange theme",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.orange,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.orange,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  secondary: Colors.orangeAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // PURPLE ACCENTS
            AppTheme(
              id: "purple_accent_light",
              description: "Light purple theme",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.purple,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.purple,
                  onPrimary: Colors.white,
                  secondary: Colors.purpleAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "purple_accent_dark",
              description: "Dark theme with purple accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.purple,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.purple,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.purple,
                  onPrimary: Colors.white,
                  secondary: Colors.purpleAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "purple_accent_amoled",
              description: "AMOLED purple theme",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.purple,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.purple,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.purple,
                  onPrimary: Colors.white,
                  secondary: Colors.purpleAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // PINK ACCENTS
            AppTheme(
              id: "pink_accent_light",
              description: "Light theme with pink accent",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.pink,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.pink,
                  onPrimary: Colors.white,
                  secondary: Colors.pinkAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "pink_accent_dark",
              description: "Dark theme with pink accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.pink,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.pink,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.pink,
                  onPrimary: Colors.white,
                  secondary: Colors.pinkAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "pink_accent_amoled",
              description: "AMOLED theme with pink accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.pink,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.pink,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.pink,
                  onPrimary: Colors.white,
                  secondary: Colors.pinkAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // TEAL ACCENTS
            AppTheme(
              id: "teal_accent_light",
              description: "Light theme with teal accent",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.teal,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  secondary: Colors.tealAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "teal_accent_dark",
              description: "Dark theme with teal accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.teal,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.teal,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  secondary: Colors.tealAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "teal_accent_amoled",
              description: "AMOLED theme with teal accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.teal,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.teal,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.teal,
                  onPrimary: Colors.white,
                  secondary: Colors.tealAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // CYAN ACCENTS
            AppTheme(
              id: "cyan_accent_light",
              description: "Light theme with cyan accent",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.cyan,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.cyan,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.cyan,
                  onPrimary: Colors.white,
                  secondary: Colors.cyanAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "cyan_accent_dark",
              description: "Dark theme with cyan accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.cyan,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.cyan,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.cyan,
                  onPrimary: Colors.white,
                  secondary: Colors.cyanAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "cyan_accent_amoled",
              description: "AMOLED theme with cyan accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.cyan,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.cyan,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.cyan,
                  onPrimary: Colors.white,
                  secondary: Colors.cyanAccent,
                  onSecondary: Colors.black,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
                ),
              ),
            ),
            // INDIGO ACCENTS
            AppTheme(
              id: "indigo_accent_light",
              description: "Light indigo theme",
              data: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.indigo,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[50],
                colorScheme: ColorScheme.light(
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                  secondary: Colors.indigoAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[100]!,
                  onSurface: Colors.black,
                  error: Colors.red[700]!,
                  onError: Colors.white,
                ),
              ),
            ),
            AppTheme(
              id: "indigo_accent_dark",
              description: "Dark theme with indigo accent",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.indigo,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.indigo,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.grey[900],
                colorScheme: ColorScheme.dark(
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                  secondary: Colors.indigoAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                ),
              ),
            ),
            AppTheme(
              id: "indigo_accent_amoled",
              description: "AMOLED indigo theme",
              data: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                primaryColor: Colors.indigo,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.indigo,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                cardColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                  secondary: Colors.indigoAccent,
                  onSecondary: Colors.white,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                  error: Colors.redAccent,
                  onError: Colors.black,
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
    );
  }
}
