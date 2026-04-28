import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/services/supabase_service.dart';
import 'package:openair/views/nav_pages/sign_up_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabaseService = ref.read(supabaseServiceProvider);

    try {
      final response = await supabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        _showSuccess('loginSuccess');
      } else if (mounted) {
        _showError('loginFailed');
      }
    } on AuthException catch (e) {
      if (mounted) _showErrorWithMessage('loginFailed', e.message);
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
    final supabaseService = ref.watch(supabaseServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('account')),
        centerTitle: true,
      ),
      body: StreamBuilder<AuthState>(
        stream: supabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(
                child: Text('No authentication data available.'));
          }

          final user = snapshot.data!.session?.user;

          if (user == null) {
            return _buildSignInForm(colorScheme, textTheme);
          }

          return _buildAccountDetails(
              user, supabaseService, colorScheme, textTheme);
        },
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Row(
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

  Widget _buildAccountDetails(User user, SupabaseService supabaseService,
      ColorScheme colorScheme, TextTheme textTheme) {
    final provider = user.appMetadata['provider'] as String?;
    final createdAt =
        DateFormat.yMMMd().add_jm().format(DateTime.parse(user.createdAt));
    final lastSignIn = user.lastSignInAt != null
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(user.lastSignInAt!))
        : null;
    final updatedAt = user.updatedAt != null
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(user.updatedAt!))
        : null;

    return SingleChildScrollView(
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
                user.email ?? 'No email',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: colorScheme.onSurface,
                ),
              ),
              if (provider != null) ...[
                const SizedBox(height: 4),
                Chip(
                  avatar: Icon(
                    _getProviderIcon(provider),
                    size: 16,
                  ),
                  label: Text(provider.toUpperCase()),
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 12,
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
                        value: user.id,
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
                      if (updatedAt != null) ...[
                        const Divider(),
                        _buildInfoTile(
                          icon: Icons.update_outlined,
                          label: Translations.of(context).text('lastUpdate'),
                          value: updatedAt,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(openAirProvider).synchronize(context);
                  await supabaseService.client.auth.refreshSession();
                },
                icon: const Icon(Icons.sync),
                label: Text(Translations.of(context).text('sync')),
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
                  await supabaseService.client.auth.signOut();
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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
