import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'OpenAirWidgetProvider';
  static const String _iOSWidgetName = 'OpenAirWidgetProvider';

  static Future<void> updateNowPlaying({
    required String title,
    required String author,
    required String imageUrl,
    bool isPlaying = false,
  }) async {
    await HomeWidget.saveWidgetData<String>('title', title);
    await HomeWidget.saveWidgetData<String>('author', author);
    await HomeWidget.saveWidgetData<String>('imageUrl', imageUrl);
    await HomeWidget.saveWidgetData<bool>('isPlaying', isPlaying);
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }
}