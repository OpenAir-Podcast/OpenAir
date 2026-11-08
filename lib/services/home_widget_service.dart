import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'OpenAirWidget';
  static const String _iOSWidgetName = 'OpenAirWidget';

  static Future<void> updateNowPlaying({
    required String title,
    required String author,
    required String imageUrl,
  }) async {
    await HomeWidget.saveWidgetData<String>('title', title);
    await HomeWidget.saveWidgetData<String>('author', author);
    await HomeWidget.saveWidgetData<String>('imageUrl', imageUrl);
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }
}