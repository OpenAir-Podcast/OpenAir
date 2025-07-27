import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState createState() => _SettingsState();
}

// TODO This is next
class _SettingsState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.display_settings_rounded),
              title: Text('User Interface'),
              subtitle: Text('Apperance and theme'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.play_arrow_rounded),
              title: Text('Playback'),
              subtitle: Text('Skip Inteveral, Queue, Speed, Timer'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.download_rounded),
              title: Text('Downloads'),
              subtitle: Text(
                  'Update Interval, Automactic Downloads, Automactic Delete'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.cloud_download_outlined),
              title: Text('Synchronization'),
              subtitle: Text('Synchronize podcasts'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.sd_card_rounded),
              title: Text('Import/Export'),
              subtitle: Text('Move subscriptions, queue, and history'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications_none_rounded),
              title: Text('Notificatins'),
              subtitle: Text('New Episode, Playback, Download'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.thumb_up_alt_rounded),
              title: Text('Donate'),
              subtitle: Text('Support the developers'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline_rounded),
              title: Text('Help & Feedback'),
              subtitle: Text('Report a bug, Request a feature'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('About'),
              subtitle: Text('Version, Licenses, Third-Party'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
