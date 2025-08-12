import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/settings_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/mobile/settings_pages/user_interface_page.dart';

final FutureProvider<SettingsModel?> settingsDataProvider =
    FutureProvider<SettingsModel?>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.getSettings();
});

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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.download_rounded),
              title: Text(Translations.of(context).text('downloads')),
              subtitle:
                  Text(Translations.of(context).text('downloadsSubtitle')),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_download_outlined),
              title: Text(Translations.of(context).text('synchronization')),
              subtitle: Text(
                  Translations.of(context).text('synchronizationSubtitle')),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.sd_card_rounded),
              title: Text(Translations.of(context).text('importExport')),
              subtitle:
                  Text(Translations.of(context).text('importExportSubtitle')),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications_none_rounded),
              title: Text(Translations.of(context).text('notifications')),
              subtitle:
                  Text(Translations.of(context).text('notificationsSubtitle')),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.thumb_up_alt_rounded),
              title: Text(Translations.of(context).text('donate')),
              subtitle: Text(Translations.of(context).text('donateSubtitle')),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline_rounded),
              title: Text(Translations.of(context).text('helpAndFeedback')),
              subtitle: Text(
                  Translations.of(context).text('helpAndFeedbackSubtitle')),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text(Translations.of(context).text('about')),
              subtitle: Text(Translations.of(context).text('aboutSubtitle')),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
