import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/views/mobile/account_page.dart';
import 'package:openair/views/mobile/settings_pages/about_page.dart';
import 'package:openair/views/mobile/settings_pages/donate_page.dart';
import 'package:openair/views/mobile/settings_pages/automatic_page.dart';
import 'package:openair/views/mobile/settings_pages/help_and_feedback_page.dart';
import 'package:openair/views/mobile/settings_pages/import_export_page.dart';
import 'package:openair/views/mobile/settings_pages/notifications_page.dart';
import 'package:openair/views/mobile/settings_pages/playback_page.dart';
import 'package:openair/views/mobile/settings_pages/synchronization_page.dart';
import 'package:openair/views/mobile/settings_pages/user_interface_page.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('settings')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.account_circle_rounded),
              title: Text(
                Translations.of(context).text('account'),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.display_settings_rounded),
              title: Text(Translations.of(context).text('userInterface')),
              subtitle:
                  Text(Translations.of(context).text('userInterfaceSubtitle')),
              onTap: () => Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => const UserInterface(),
                ),
              )
                  .then(
                (value) {
                  setState(() {});
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow_rounded),
              title: Text(Translations.of(context).text('playback')),
              subtitle: Text(Translations.of(context).text('playbackSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlaybackPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.autorenew_rounded),
              title: Text(Translations.of(context).text('automatic')),
              subtitle:
                  Text(Translations.of(context).text('downloadsSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AutomaticPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_download_outlined),
              title: Text(Translations.of(context).text('synchronization')),
              subtitle: Text(
                  Translations.of(context).text('synchronizationSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SynchronizationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sd_card_rounded),
              title: Text(Translations.of(context).text('importExport')),
              subtitle:
                  Text(Translations.of(context).text('importExportSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ImportExportPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications_none_rounded),
              title: Text(Translations.of(context).text('notifications')),
              subtitle:
                  Text(Translations.of(context).text('notificationsSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.thumb_up_alt_rounded),
              title: Text(Translations.of(context).text('donate')),
              subtitle: Text(Translations.of(context).text('donateSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DonatePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline_rounded),
              title: Text(Translations.of(context).text('helpAndFeedback')),
              subtitle: Text(
                  Translations.of(context).text('helpAndFeedbackSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpAndFeedbackPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text(Translations.of(context).text('about')),
              subtitle: Text(Translations.of(context).text('aboutSubtitle')),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
