import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/settings_pages/account_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _termsAndPrivacyPolicy = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) {
        final session = event.session;
        if (session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabaseService = ref.read(supabaseServiceProvider);

    try {
      final response = await supabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (response.user != null && mounted) {
        _showSuccess('checkYourEmail');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
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

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null) return;
    try {
      await launchUrl(
        Uri.parse(urlString),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        _showErrorWithMessage('oopsAnErrorOccurred', 'oopsTryAgainLater');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('openAir'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
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
                        Icons.person_add_alt_rounded,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Translations.of(context).text('signUp'),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Translations.of(context).text('typeYourUsername'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Translations.of(context)
                                .text('requiredField');
                          }
                          if (value.length < 3) {
                            return Translations.of(context)
                                .text('invalidUsername');
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: Translations.of(context).text('username'),
                          hintText:
                              Translations.of(context).text('typeYourUsername'),
                          prefixIcon: const Icon(Icons.person_outline),
                          suffixIcon: _usernameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _usernameController.clear();
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Translations.of(context)
                                .text('requiredField');
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return Translations.of(context)
                                .text('invalidEmail');
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
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Translations.of(context)
                                .text('requiredField');
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
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => _handleSignUp(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return Translations.of(context)
                                .text('requiredField');
                          }
                          if (value != _passwordController.text) {
                            return Translations.of(context)
                                .text('passwordsDoNotMatch');
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText:
                              Translations.of(context).text('confirmPassword'),
                          hintText: Translations.of(context)
                              .text('typeYourPasswordAgain'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible,
                                ),
                              ),
                              if (_confirmPasswordController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _confirmPasswordController.clear();
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
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _termsAndPrivacyPolicy,
                            onChanged: (value) {
                              setState(() => _termsAndPrivacyPolicy = value!);
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                Translations.of(context)
                                    .text('termsAndPrivacyPolicy'),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _launchUrl(dotenv.env['TERMS_OF_SERVICE']),
                            child: Text(Translations.of(context).text('terms')),
                          ),
                          TextButton(
                            onPressed: () =>
                                _launchUrl(dotenv.env['PRIVACY_POLICY']),
                            child: Text(
                                Translations.of(context).text('privacyPolicy')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _termsAndPrivacyPolicy && !_isLoading
                            ? _handleSignUp
                            : null,
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
                                    .text('signUp')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
