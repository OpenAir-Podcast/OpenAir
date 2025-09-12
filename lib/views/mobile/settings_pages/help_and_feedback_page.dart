import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
                color: Brightness.dark == Theme.of(context).brightness
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.forum_rounded),
            title: Text(Translations.of(context).text('joinOurDiscord')),
            onTap: () async {
              try {
                final String discordUrl = dotenv.env['DISCORD_URL']!;
                await launchUrl(
                  Uri.parse(discordUrl),
                  mode: LaunchMode.externalApplication,
                );
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
                final String gitHubIssuesUrl = dotenv.env['GITHUB_ISSUES_URL']!;
                await launchUrl(
                  Uri.parse(gitHubIssuesUrl),
                  mode: LaunchMode.externalApplication,
                );
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
                final String gitHubDiscussionsUrl =
                    dotenv.env['GITHUB_DISCUSSION_URL']!;
                await launchUrl(
                  Uri.parse(gitHubDiscussionsUrl),
                  mode: LaunchMode.externalApplication,
                );
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
                final String privacyPolicyUrl = dotenv.env['PRIVACY_POLICY']!;
                await launchUrl(
                  Uri.parse(privacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                );
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
