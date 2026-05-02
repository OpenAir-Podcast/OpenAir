import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';

class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  final Future<List<PackageLicenses>> _licensesFuture =
      LicenseRegistry.licenses.fold<List<PackageLicenses>>(
    [],
    (List<PackageLicenses> previous, LicenseEntry license) {
      final package = license.packages.first;
      final existing = previous.firstWhere(
        (pl) => pl.name == package,
        orElse: () {
          final newPackage = PackageLicenses(package);
          previous.add(newPackage);
          return newPackage;
        },
      );
      existing.licenses.add(license);
      return previous;
    },
  ).then((List<PackageLicenses> licenses) {
    licenses.sort((a, b) => a.name.compareTo(b.name));
    return licenses;
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('licenses'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<PackageLicenses>>(
        future: _licensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(Translations.of(context).text('oopsAnErrorOccurred')),
            );
          }

          final licenses = snapshot.data ?? [];

          return ListView.separated(
            itemCount: licenses.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
            itemBuilder: (context, index) {
              final package = licenses[index];
              return _LicensePackageTile(
                package: package,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _LicensePackageTile extends StatelessWidget {
  final PackageLicenses package;
  final bool isDark;

  const _LicensePackageTile({
    required this.package,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        package.name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        '${package.licenses.length} license(s)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
      ),
      children: package.licenses.map((license) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SelectableText(
            license.paragraphs.map((p) => p.text).join('\n\n'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  height: 1.5,
                ),
          ),
        );
      }).toList(),
    );
  }
}

class PackageLicenses {
  final String name;
  final List<LicenseEntry> licenses;

  PackageLicenses(this.name) : licenses = [];
}
