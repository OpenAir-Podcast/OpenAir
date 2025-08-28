import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndFeedbackPage extends ConsumerStatefulWidget {
  const HelpAndFeedbackPage({super.key});

  @override
  ConsumerState<HelpAndFeedbackPage> createState() =>
      HelpAndFeedbackPageState();
}

class HelpAndFeedbackPageState extends ConsumerState<HelpAndFeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('helpAndFeedback')),
      ),
      body: Column(
        spacing: settingsSpacer,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Translations.of(context).text('helpAndFeedbackDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.forum_rounded),
            title: Text(Translations.of(context).text('joinOurDiscord')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(discordUrl));
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
            leading: Icon(Icons.bug_report_rounded),
            title: Text(Translations.of(context).text('reportABug')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(gitHubIssuesUrl));
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
            leading: Icon(Icons.lightbulb_rounded),
            title: Text(Translations.of(context).text('suggestAFeature')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(gitHubDiscussionsUrl));
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
            title: Text(Translations.of(context).text('privacyPolicy')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(privacyPolicyUrl));
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
        ],
      ),
    );
  }
}
