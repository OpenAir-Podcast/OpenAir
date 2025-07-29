import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class Config {
  Color? cardBackgroundColor = Colors.blueGrey[100];
  Color? highlightColor = Colors.grey[100];
  Color? highlightColor2 = Colors.grey[400];

  double cardElevation = 5.0;

  Color cardHeaderColor = Colors.blue;
  Color cardHeaderTextColor = Colors.white;

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

  int mobileCrossAxisCount = 3;
  double mobileMainAxisExtent = 500.0;

  double subscribedMobileMainAxisExtent = 236.0;

  int mobileItemCountPortrait = 3;
  int mobileItemCountLandscape = 6;

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

  BuildContext context;
  Config(this.context);

  Color get textColor {
    return ThemeProvider.themeOf(context).data.scaffoldBackgroundColor ==
            Colors.black
        ? Colors.white
        : Colors.black;
  }
}
