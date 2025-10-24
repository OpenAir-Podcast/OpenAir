import 'package:flutter/material.dart';

int wideScreenMinWidth = 800;
double circleSize = 70.0;

double bannerAudioPlayerHeight = 85.0;

Color? highlightColor = Colors.grey[100];
Color? highlightColor2 = Colors.grey[400];

double? cardElevation = 5.0;

Color cardHeaderColor = Colors.blue;

Color cardHeaderTextColor = Colors.black;

Color cardImageShadow = Colors.brown;
Color cardLabelShadow = Colors.brown;

Color cardLabelBackground = Colors.white;
Color cardLabelTextColor = Colors.black;

Color subscriptionCountBoxColor = Colors.red;
Color subscriptionCountBoxTextColor = Colors.white;

double subscriptionCountBoxSize = 38.0;
double subscriptionCountBoxFontSize = 18.0;
FontWeight subscriptionCountBoxFontWeight = FontWeight.normal;

double blurRadius = 10.0;

int narrowCrossAxisCount = 3;
double narrowMainAxisExtent = 500.0;

int wideCrossAxisCount = 5;
double wideMainAxisExtent = 833.0;

double subscribedNarrowMainAxisExtent = 236.0;
double subscribedWideMainAxisExtent = 250.0;

int narrowItemCountPortrait = 3;
int narrowItemCountLandscape = 6;

int wideItemCountPortrait = 3;
int wideItemCountLandscape = 6;

double featuredCardHeight = 230.0;

double cardTopCornersRatio = 12.0;
double cardBottomCornersRatio = 12.0;

double cardImageHeight = 160.0;
double cardImageWidth = 160.0;

double cardSidePadding = 5.0;
double cardTopPadding = 18.0;

double cardLabelHeight = 40.0;
double cardLabelWidth = 160.0;

double cardLabelFontSize = 14.0;
FontWeight cardLabelFontWeight = FontWeight.bold;
int cardLabelMaxLines = 1;
double cardLabelPadding = 8.0;

double cacheExtent = 500.0;

int max = 150;

double settingsSpacer = 8.0;

double fontSizeSmall = 0.875;
double fontSizeMedium = 1.0;
double fontSizeLarge = 1.125;
double fontSizeExtraLarge = 1.25;

bool onChanged = true;
String localeSettings = 'en_US';

AppBarTheme appBarThemeLight = AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: Colors.blue,
);

AppBarTheme appBarThemeDark = AppBarTheme(
  backgroundColor: Colors.black,
  foregroundColor: Colors.blue,
);

FloatingActionButtonThemeData floatingActionButtonTheme =
    FloatingActionButtonThemeData(
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
);

SnackBarThemeData snackBarThemeLight = SnackBarThemeData(
  backgroundColor: Colors.blue,
  contentTextStyle: TextStyle(
    color: Colors.white,
  ),
);

SnackBarThemeData snackBarThemeDark = SnackBarThemeData(
  backgroundColor: Colors.black,
  contentTextStyle: TextStyle(
    color: Colors.white,
  ),
);

ColorScheme colorSchemeLight = ColorScheme.light(
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent,
  onSecondary: Colors.white,
  surface: Colors.grey[100]!,
  onSurface: Colors.black,
  error: Colors.red[700]!,
  onError: Colors.white,
  primaryContainer: Colors.white,
  onPrimaryContainer: Colors.black,
  secondaryContainer: Colors.white,
  onSecondaryContainer: Colors.black,
);

ColorScheme colorSchemeDark = ColorScheme.dark(
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent,
  onSecondary: Colors.white,
  surface: Colors.grey[850]!,
  onSurface: Colors.white,
  error: Colors.red[400]!,
  onError: Colors.black,
  primaryContainer: Colors.grey[900]!,
  onPrimaryContainer: Colors.white,
  secondaryContainer: Colors.grey[900]!,
  onSecondaryContainer: Colors.white,
);

ListTileThemeData listTileThemeDark = ListTileThemeData(
  iconColor: Colors.white,
  textColor: Colors.white,
);

ListTileThemeData listTileThemeLight = ListTileThemeData(
  iconColor: Colors.black,
  textColor: Colors.black,
);

Color scaffoldBackgroundColorLight = Colors.grey[100]!;
Color scaffoldBackgroundColorDark = Colors.black;
Color cardColorLight = Colors.white;
Color cardColorDark = Colors.grey[850]!;
Color primaryColorLight = Colors.blue;
Color primaryColorDark = Colors.blue;

// User Interface
late String fontSizeConfig;
late String themeModeConfig;
late String languageConfig;
late String localeConfig;

// Playback
String fastForwardIntervalConfig = '10';
String rewindIntervalConfig = '10';
String playbackSpeedConfig = '1.0x';

late String enqueuePositionConfig;
late bool enqueueDownloadedConfig;
late bool autoplayNextInQueueConfig;
late String smartMarkAsCompletionConfig;
late bool keepSkippedEpisodesConfig;

// Automatic
late String refreshPodcastsConfig;
late bool downloadNewEpisodesConfig;
late bool downloadQueuedEpisodesConfig;
late String downloadEpisodeLimitConfig;

late bool deletePlayedEpisodesConfig;
late bool keepFavouriteEpisodesConfig;

// Synchronization
late bool syncFavouritesConfig;
late bool syncQueueConfig;
late bool syncHistoryConfig;
late bool syncPlaybackPositionConfig;
late bool syncSettingsConfig;

// Import/Export
late bool automaticExportDatabaseConfig;

// Notifications
late bool receiveNotificationsForNewEpisodesConfig;
late bool receiveNotificationsWhenPlayConfig;
late bool receiveNotificationsWhenDownloadConfig;

// Font size
double smallFontSize = 0.875;
double mediumFontSize = 1.0;
double largeFontSize = 1.125;
double extraLargeFontSize = 1.25;

const TextTheme baseTextTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.w400),
  displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.w400),
  displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w400),
  headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w400),
  headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w400),
  headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400),
  titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
  titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
  labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
  labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
  labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
  bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
  bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
);

TextTheme scaleTextTheme(TextTheme base, double scaleFactor) {
  return base.copyWith(
    displayLarge: base.displayLarge
        ?.copyWith(fontSize: base.displayLarge!.fontSize! * scaleFactor),
    displayMedium: base.displayMedium
        ?.copyWith(fontSize: base.displayMedium!.fontSize! * scaleFactor),
    displaySmall: base.displaySmall
        ?.copyWith(fontSize: base.displaySmall!.fontSize! * scaleFactor),
    headlineLarge: base.headlineLarge
        ?.copyWith(fontSize: base.headlineLarge!.fontSize! * scaleFactor),
    headlineMedium: base.headlineMedium
        ?.copyWith(fontSize: base.headlineMedium!.fontSize! * scaleFactor),
    headlineSmall: base.headlineSmall
        ?.copyWith(fontSize: base.headlineSmall!.fontSize! * scaleFactor),
    titleLarge: base.titleLarge
        ?.copyWith(fontSize: base.titleLarge!.fontSize! * scaleFactor),
    titleMedium: base.titleMedium
        ?.copyWith(fontSize: base.titleMedium!.fontSize! * scaleFactor),
    titleSmall: base.titleSmall
        ?.copyWith(fontSize: base.titleSmall!.fontSize! * scaleFactor),
    labelLarge: base.labelLarge
        ?.copyWith(fontSize: base.labelLarge!.fontSize! * scaleFactor),
    labelMedium: base.labelMedium
        ?.copyWith(fontSize: base.labelMedium!.fontSize! * scaleFactor),
    labelSmall: base.labelSmall
        ?.copyWith(fontSize: base.labelSmall!.fontSize! * scaleFactor),
    bodyLarge: base.bodyLarge
        ?.copyWith(fontSize: base.bodyLarge!.fontSize! * scaleFactor),
    bodyMedium: base.bodyMedium
        ?.copyWith(fontSize: base.bodyMedium!.fontSize! * scaleFactor),
    bodySmall: base.bodySmall
        ?.copyWith(fontSize: base.bodySmall!.fontSize! * scaleFactor),
  );
}
