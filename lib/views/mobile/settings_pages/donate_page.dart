import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:url_launcher/url_launcher.dart';

class DonatePage extends ConsumerStatefulWidget {
  const DonatePage({super.key});

  @override
  ConsumerState<DonatePage> createState() => DonatePageState();
}

class DonatePageState extends ConsumerState<DonatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('donate')),
      ),
      body: Column(
        spacing: settingsSpacer,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Translations.of(context).text('donateDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.paypal_rounded),
            title: Text(Translations.of(context).text('donateWithPaypal')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(paypalUrl));
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
            leading: Icon(Icons.coffee_rounded),
            title: Text(Translations.of(context).text('buyMeACoffee')),
            onTap: () async {
              try {
                await launchUrl(Uri.parse(buyMeACoffeeUrl));
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
