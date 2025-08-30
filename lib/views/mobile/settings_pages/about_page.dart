import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
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
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 150.0,
                  width: 150.0,
                  child: Image.asset('assets/images/openair_logo.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  Translations.of(context).text('aboutDescription'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
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
                    await launchUrl(Uri.parse(gitHubUrl));
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${Translations.of(context).text('oopsAnErrorOccurred')} ${Translations.of(context).text('oopsTryAgainLater')}'),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.gavel_rounded),
                title: Text(Translations.of(context).text('licenses')),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'OpenAir',
                    applicationVersion: data.version,
                  );
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
}
