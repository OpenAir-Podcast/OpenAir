import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationProvider = ChangeNotifierProvider<NotificationService>(
  (ref) {
    return NotificationService(ref);
  },
);

class NotificationService extends ChangeNotifier {
  NotificationService(this.ref);

  Ref ref;

  late BuildContext context;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(BuildContext context) async {
    this.context = context;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'OpenAir',
      appUserModelId: dotenv.env['APP_UNIQUE_ID']!,
      guid: dotenv.env['APP_GUID']!,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }

    // TODO: Implement navigation based on payload if needed
    // Navigate to a specific screen based on the payload
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    if (notificationResponse.payload != null) {
      debugPrint('background notification payload: $payload');
    }
  }

  Future<void> showNotification(
    String title,
    String body,
    // String? payload,
  ) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'openair_notifications_channel',
      'OpenAir Notification',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'OpenAir',
      subtitle: 'OpenAir Notification',
      interruptionLevel: InterruptionLevel.active,
      attachments: <DarwinNotificationAttachment>[
        DarwinNotificationAttachment('assets/images/openair_logo_512.png')
      ],
    );

    DarwinNotificationDetails macOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'OpenAir',
      subtitle: 'OpenAir Notification',
      interruptionLevel: InterruptionLevel.active,
      attachments: <DarwinNotificationAttachment>[
        DarwinNotificationAttachment('assets/images/openair_logo_512.png')
      ],
    );

    const WindowsNotificationDetails windowsPlatformChannelSpecifics =
        WindowsNotificationDetails();

    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
      category: LinuxNotificationCategory.presence,
      urgency: LinuxNotificationUrgency.normal,
      location: LinuxNotificationLocation(1, 1),
      icon: AssetsLinuxIcon('icons/icon.png'),
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: macOSPlatformChannelSpecifics,
      windows: windowsPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      // payload: payload,
    );
  }
}
