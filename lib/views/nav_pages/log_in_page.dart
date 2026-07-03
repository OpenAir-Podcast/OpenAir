import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openair/providers/firebase_provider.dart';
import 'package:openair/views/nav_pages/sign_up_page.dart';
import 'package:openair/views/settings_pages/account_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState<LogIn> createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
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
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      final response = await firebaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        _showSuccess('loginSuccess');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountPage()),
        );
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
                        Translations.of(context).text('login'),
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
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => _handleSignIn(),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Add the logic there to handle password reset
                          },
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
                                    .text('login')
                                    .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                final firebaseService =
                                    ref.read(firebaseServiceProvider);
                                try {
                                  await firebaseService.logInUsingGoogle();
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountPage(),
                                      ),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (mounted) {
                                    _showErrorWithMessage(
                                      'loginFailed',
                                      e.message ?? 'Unknown error',
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    _showErrorWithMessage(
                                      'loginFailed',
                                      e.toString(),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              },
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
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUp(),
                                ),
                              );
                            },
                            child: Text(
                              Translations.of(context).text('signUp'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
