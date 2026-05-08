import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> synchronizationSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getSynchronizationSettings();
});

class SynchronizationPage extends ConsumerStatefulWidget {
  const SynchronizationPage({super.key});

  @override
  ConsumerState<SynchronizationPage> createState() =>
      SynchronizationPageState();
}

class SynchronizationPageState extends ConsumerState<SynchronizationPage> {
  bool _isSyncing = false;

  Widget _buildCard(Widget child, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _saveSynchronizationSettings(Map syncData, BuildContext context) {
    ref
        .watch(openAirProvider)
        .hiveService
        .saveSynchronizationSettings(syncData);
  }

  @override
  Widget build(BuildContext context) {
    final synchronization = ref.watch(synchronizationSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('synchronization'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: synchronization.when(
        data: (data) {
          final syncData = data!;

          final syncFavourites = syncData['syncFavourites'] ?? true;
          final syncQueue = syncData['syncQueue'] ?? true;
          final syncHistory = syncData['syncHistory'] ?? true;
          final syncPlaybackPosition = syncData['syncPlaybackPosition'] ?? true;
          final syncSettings = syncData['syncSettings'] ?? true;

          return Column(
            children: [
              _buildSectionHeader(
                  Translations.of(context).text('synchronization'), context),
              _buildCard(
                Column(
                  children: [
                    _buildToggleTile(
                      label: Translations.of(context).text('syncFavourites'),
                      value: syncFavourites,
                      onChanged: (value) {
                        syncData['syncFavourites'] = value;
                        syncFavouritesConfig = value;
                        _saveSynchronizationSettings(syncData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context).text('syncQueue'),
                      value: syncQueue,
                      onChanged: (value) {
                        syncData['syncQueue'] = value;
                        syncQueueConfig = value;
                        _saveSynchronizationSettings(syncData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context).text('syncHistory'),
                      value: syncHistory,
                      onChanged: (value) {
                        syncData['syncHistory'] = value;
                        syncHistoryConfig = value;
                        _saveSynchronizationSettings(syncData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label:
                          Translations.of(context).text('syncPlaybackPosition'),
                      value: syncPlaybackPosition,
                      onChanged: (value) {
                        syncData['syncPlaybackPosition'] = value;
                        syncPlaybackPositionConfig = value;
                        _saveSynchronizationSettings(syncData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context).text('syncSettings'),
                      value: syncSettings,
                      onChanged: (value) {
                        syncData['syncSettings'] = value;
                        syncSettingsConfig = value;
                        _saveSynchronizationSettings(syncData, context);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSyncing
                    ? null
                    : () async {
                        setState(() => _isSyncing = true);
                        try {
                          await ref.read(openAirProvider).synchronize(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(Translations.of(context)
                                    .text('syncComplete')),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${Translations.of(context).text('syncFailed')} $e',
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSyncing = false);
                        }
                      },
                icon: _isSyncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  Translations.of(context).text('synchronizeNow'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(Translations.of(context).text('oopsAnErrorOccurred')),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
