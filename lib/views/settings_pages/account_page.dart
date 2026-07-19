import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/firebase_provider.dart';
import 'package:openair/config/firebase_config.dart';
import 'package:openair/services/firebase_service.dart';
import 'package:openair/views/nav_pages/sign_up_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:intl/intl.dart';
import 'package:openair/controllers/subscription_controller.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/navigation/list_drawer.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _lastSyncAt;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLastSyncTimestamp();
  }

  Future<void> _loadLastSyncTimestamp() async {
    final hiveService = ref.read(hiveServiceProvider);
    final timestamp = await hiveService.getLastSyncTimestamp();
    if (mounted) {
      setState(() {
        _lastSyncAt = timestamp != null
            ? DateFormat.yMMMd().add_jm().format(timestamp.toLocal())
            : null;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      await firebaseService.logInUsingGoogle();
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorWithMessage('loginFailed', e.message ?? 'Unknown error');
    } catch (e) {
      if (mounted) _showErrorWithMessage('loginFailed', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final response = await firebaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        _showSuccess('loginSuccess');
      } else if (mounted) {
        _showError('loginFailed');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorWithMessage('loginFailed', e.message ?? 'Unknown error');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String key) {
    final msg = Translations.of(context).text(key);
    if (!Platform.isAndroid && !Platform.isIOS) {
      ref.read(notificationServiceProvider).showNotification(
            'OpenAir ${Translations.of(context).text('notification')}',
            msg,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _showError(String key) {
    final msg = Translations.of(context).text(key);
    if (!Platform.isAndroid && !Platform.isIOS) {
      ref.read(notificationServiceProvider).showNotification(
            'OpenAir ${Translations.of(context).text('notification')}',
            msg,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _showErrorWithMessage(String key, String message) {
    final msg = '${Translations.of(context).text(key)}: $message';
    if (!Platform.isAndroid && !Platform.isIOS) {
      ref.read(notificationServiceProvider).showNotification(
            'OpenAir ${Translations.of(context).text('notification')}',
            msg,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _getInitials(User user) {
    final email = user.email ?? '';
    if (email.isEmpty) return '?';
    return email[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.watch(firebaseServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('account')),
      ),
      body: !FirebaseConfig.isAvailable
          ? const SizedBox.shrink()
          : getConnectionStatusValue.when(
        data: (connectionData) {
          if (connectionData == false) {
            return const NoConnection();
          }

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 75.0,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          Translations.of(context).text('oopsAnErrorOccurred'),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 180.0,
                          height: 40.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              ref.invalidate(getConnectionStatusProvider);
                              setState(() {});
                            },
                            child: Text(Translations.of(context).text('retry')),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final user = snapshot.data;

              if (user == null) {
                return _buildSignInForm(colorScheme, textTheme);
              }

              return _buildAccountDetails(
                  user, firebaseService, colorScheme, textTheme);
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildSignInForm(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_person_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Translations.of(context).text('signIn'),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translations.of(context).text('typeYourEmail'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Translations.of(context).text('requiredField');
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return Translations.of(context).text('invalidEmail');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: Translations.of(context).text('email'),
                        hintText:
                            Translations.of(context).text('typeYourEmail'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: _emailController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _emailController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _handleSignIn(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Translations.of(context).text('requiredField');
                        }
                        if (value.length < 6) {
                          return Translations.of(context)
                              .text('invalidPassword');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: Translations.of(context).text('password'),
                        hintText:
                            Translations.of(context).text('typeYourPassword'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                            if (_passwordController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _passwordController.clear();
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          Translations.of(context).text('forgotPassword'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              Translations.of(context)
                                  .text('signIn')
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            Translations.of(context).text('or'),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/google-white-logo.png'
                            : 'assets/images/google-black-logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        Translations.of(context).text('continueWithGoogle'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Translations.of(context).text('dontHaveAnAccount'),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: Text(
                            Translations.of(context).text('signUp'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetails(User user, FirebaseService firebaseService,
      ColorScheme colorScheme, TextTheme textTheme) {
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    final provider = _getProviderName(providerId);
    final createdAt = user.metadata.creationTime != null
        ? DateFormat.yMMMd().add_jm().format(user.metadata.creationTime!.toLocal())
        : 'Unknown';
    final lastSignIn = user.metadata.lastSignInTime != null
        ? DateFormat.yMMMd().add_jm().format(user.metadata.lastSignInTime!.toLocal())
        : null;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  _getInitials(user),
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.email ?? Translations.of(context).text("noEmail"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              ...[
                const SizedBox(height: 4),
                Chip(
                  avatar: Icon(
                    _getProviderIcon(provider),
                    size: 16,
                  ),
                  label: Text(
                      Translations.of(context).text(provider).toUpperCase()),
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                ),
              ],
              const SizedBox(height: 32),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.badge_outlined,
                        label: Translations.of(context).text('userID'),
                        value: user.uid,
                        colorScheme: colorScheme,
                      ),
                      const Divider(),
                      _buildInfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: Translations.of(context).text('accountCreated'),
                        value: createdAt,
                        colorScheme: colorScheme,
                      ),
                      if (lastSignIn != null) ...[
                        const Divider(),
                        _buildInfoTile(
                          icon: Icons.login_outlined,
                          label: Translations.of(context).text('lastSignIn'),
                          value: lastSignIn,
                          colorScheme: colorScheme,
                        ),
                      ],
                      if (_lastSyncAt != null) ...[
                        const Divider(),
                        _buildInfoTile(
                          icon: Icons.schedule,
                          label: Translations.of(context).text('lastSync'),
                          value: _lastSyncAt!,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSyncing
                    ? null
                    : () async {
                        setState(() => _isSyncing = true);
                        try {
                          await ref.read(openAirProvider).synchronize(context);
                          await _loadLastSyncTimestamp();
                          if (mounted) _showSuccess('syncComplete');
                        } catch (e) {
                          if (mounted) {
                            _showErrorWithMessage('syncFailed', e.toString());
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
                    : const Icon(Icons.sync),
                label: Text(_isSyncing
                    ? Translations.of(context).text('syncing')
                    : Translations.of(context).text('sync')),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(subscriptionControllerProvider)
                      .clearAllSubscriptions();
                  ref.invalidate(drawerCountsProvider);
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: Text(Translations.of(context).text('signOut')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _showDeleteAccountDialog(firebaseService),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: Text(
                  Translations.of(context).text('deleteAccount'),
                  style: const TextStyle(color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(FirebaseService firebaseService) async {
    final provider = firebaseService.getAuthProvider();
    final passwordController = TextEditingController();
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    Future<void> performDelete() async {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(subscriptionControllerProvider)
            .clearAllSubscriptions();
        ref.invalidate(drawerCountsProvider);
        await firebaseService.deleteUserData();
        await firebaseService.deleteAccount();
        if (mounted) _showSuccess('accountDeletedSuccessfully');
      } catch (e) {
        if (mounted) {
          _showErrorWithMessage('errorDeletingAccount', e.toString());
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    Future<void> handleDelete() async {
      try {
        if (provider == 'password') {
          final password = passwordController.text.trim();
          if (password.isEmpty) return;
          await firebaseService.reauthenticate(userEmail, password);
        } else if (provider != null) {
          Navigator.of(context).pop();
          await firebaseService.reauthenticateWithProvider(provider);
        }
        await performDelete();
      } catch (e) {
        if (mounted) {
          _showErrorWithMessage('errorDeletingAccount', e.toString());
        }
      }
    }

    if (provider == 'password') {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(Translations.of(context).text('deleteAccount')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Translations.of(context).text('deleteAccountConfirmation')),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: Translations.of(context).text('password'),
                    hintText: Translations.of(context).text('typeYourPassword'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(Translations.of(context).text('cancel')),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: Text(
                  Translations.of(context).text('delete'),
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await handleDelete();
                },
              ),
            ],
          );
        },
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(Translations.of(context).text('deleteAccount')),
          content: Text(Translations.of(context).text('deleteAccountConfirmation')),
          actions: <Widget>[
            TextButton(
              child: Text(Translations.of(context).text('cancel')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                Translations.of(context).text('delete'),
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await handleDelete();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getProviderName(String providerId) {
    switch (providerId) {
      case 'google.com':
        return 'google';
      case 'github.com':
        return 'github';
      case 'password':
        return 'email';
      default:
        return providerId;
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'github':
        return Icons.code;
      case 'email':
        return Icons.email_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
