import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/views/mobile/settings_pages/notifications_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => AboutPageState();
}

class AboutPageState extends ConsumerState<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final appInfoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('about')),
      ),
      body: appInfoAsync.when(
        data: (data) {
          return Column(
            spacing: settingsSpacer,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 150.0,
                  width: 150.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset('assets/icons/icon.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  Translations.of(context).text('aboutDescription'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Brightness.dark == Theme.of(context).brightness
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_rounded),
                title: Text(Translations.of(context).text('version')),
                trailing: Text(
                  data.version,
                ),
              ),
              ListTile(
                leading: Icon(Icons.code_rounded),
                title: Text(Translations.of(context).text('sourceCode')),
                onTap: () async {
                  try {
                    final String gitHubUrl = dotenv.env['GITHUB_URL']!;

                    await launchUrl(Uri.parse(gitHubUrl));
                  } catch (e) {
                    if (context.mounted) {
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              '${Translations.of(context).text('oopsAnErrorOccurred')} ${Translations.of(context).text('oopsTryAgainLater')}',
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${Translations.of(context).text('oopsAnErrorOccurred')} ${Translations.of(context).text('oopsTryAgainLater')}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.gavel_rounded),
                title: Text(Translations.of(context).text('licenses')),
                onTap: () {
                  if (Brightness.dark == Theme.of(context).brightness) {
                    showDarkLicensePage(context);
                  } else {
                    showLicensePage(context: context);
                  }
                },
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
              child: Text(
            Translations.of(context).text('oopsAnErrorOccurred'),
            style: TextStyle(
              fontSize: 18.0,
            ),
          ));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void showDarkLicensePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.blue,
            ),
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ),
          child: const LicensePage(
            applicationName: 'OpenAir',
            applicationVersion: '1.0.0',
          ),
        ),
      ),
    );
  }
}
