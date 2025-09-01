import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
                color: Brightness.dark == Theme.of(context).brightness
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.paypal_rounded),
            title: Text(Translations.of(context).text('donateWithPayPal')),
            onTap: () async {
              try {
                final String paypalUrl = dotenv.env['PAYPAL_URL']!;
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
                final String buyMeACoffeeUrl =
                    dotenv.env['BUY_ME_A_COFFEE_URL']!;

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
          ListTile(
            leading: Icon(Icons.local_drink_outlined),
            title: Text(Translations.of(context).text('donateWithKofi')),
            onTap: () async {
              try {
                final String donateWithKofiUrl =
                    dotenv.env['DONATE_WITH_KOFI_URL']!;
                await launchUrl(Uri.parse(donateWithKofiUrl));
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
