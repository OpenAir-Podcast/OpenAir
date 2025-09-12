import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/mobile/account_page.dart';
import 'package:openair/views/mobile/nav_pages/log_in_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  TextEditingController usernameInputControl = TextEditingController();
  TextEditingController emailInputControl = TextEditingController();
  TextEditingController passwordInputControl = TextEditingController();
  TextEditingController confirmPasswordInputControl = TextEditingController();

  bool termsAndPrivacyPolicy = false;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) {
        final session = event.session;

        if (session != null) {
          Navigator.removeRoute(
            context,
            MaterialPageRoute(
              builder: (context) => LogIn(),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccountPage(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    emailInputControl.dispose();
    passwordInputControl.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  Translations.of(context).text('signUp'),
                  style: TextStyle(
                    color: Brightness.dark == Theme.of(context).brightness
                        ? Colors.white
                        : Colors.black,
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextFormField(
                style: TextStyle(
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Translations.of(context).text('requiredField');
                  } else if (value.length < 3) {
                    return Translations.of(context).text('invalidUsername');
                  }

                  return null;
                },
                keyboardType: TextInputType.text,
                controller: usernameInputControl,
                onChanged: (value) {
                  if (usernameInputControl.text.isNotEmpty) {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  label: Text(Translations.of(context).text('username')),
                  border: OutlineInputBorder(),
                  hintText: Translations.of(context).text('typeYourUsername'),
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: usernameInputControl.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            usernameInputControl.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
              TextFormField(
                style: TextStyle(
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Translations.of(context).text('requiredField');
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return Translations.of(context).text('invalidEmail');
                  }

                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                controller: emailInputControl,
                onChanged: (value) {
                  if (emailInputControl.text.isNotEmpty) {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  label: Text(Translations.of(context).text('email')),
                  border: OutlineInputBorder(),
                  hintText: Translations.of(context).text('typeYourEmail'),
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: emailInputControl.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            emailInputControl.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
              TextFormField(
                style: TextStyle(
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Translations.of(context).text('requiredField');
                  } else if (value.length < 6) {
                    return Translations.of(context).text('invalidPassword');
                  }

                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
                obscureText: !isPasswordVisible,
                controller: passwordInputControl,
                onChanged: (value) {
                  if (passwordInputControl.text.isNotEmpty) {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  label: Text(Translations.of(context).text('password')),
                  border: OutlineInputBorder(),
                  hintText: Translations.of(context).text('typeYourPassword'),
                  prefixIcon: Icon(Icons.lock_rounded),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      passwordInputControl.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                passwordInputControl.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              TextFormField(
                style: TextStyle(
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Translations.of(context).text('requiredField');
                  } else if (value != passwordInputControl.text) {
                    return Translations.of(context).text('passwordsDoNotMatch');
                  }

                  return null;
                },
                keyboardType: TextInputType.visiblePassword,
                obscureText: !isConfirmPasswordVisible,
                controller: confirmPasswordInputControl,
                onChanged: (value) {
                  if (confirmPasswordInputControl.text.isNotEmpty) {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  label: Text(Translations.of(context).text('confirmPassword')),
                  border: OutlineInputBorder(),
                  hintText:
                      Translations.of(context).text('typeYourPasswordAgain'),
                  prefixIcon: Icon(Icons.lock_rounded),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                        icon: Icon(isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      confirmPasswordInputControl.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                confirmPasswordInputControl.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: termsAndPrivacyPolicy,
                        onChanged: (value) {
                          setState(() {
                            termsAndPrivacyPolicy = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.widthOf(context) * 0.88,
                        child: Text(
                          Translations.of(context).text(
                            'termsAndPrivacyPolicy',
                          ),
                          maxLines: 2,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color:
                                Brightness.dark == Theme.of(context).brightness
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    spacing: 8.0,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final String termsUrl =
                                dotenv.env['TERMS_OF_SERVICE']!;

                            await launchUrl(
                              Uri.parse(termsUrl),
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
                        child: Text(
                          Translations.of(context).text('terms'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final String privacyPolicyUrl =
                                dotenv.env['PRIVACY_POLICY']!;

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
                        child: Text(
                          Translations.of(context).text('privacyPolicy'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 380.0,
                  height: 48.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey;
                          }
                          return Theme.of(context).colorScheme.primary;
                        },
                      ),
                    ),
                    onPressed: termsAndPrivacyPolicy
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              final username = usernameInputControl.text.trim();
                              final email = emailInputControl.text.trim();
                              final password = passwordInputControl.text.trim();

                              if (mounted) {
                                try {
                                  AuthResponse response = await supabaseService
                                      .signUp(email, password, username);

                                  if (response.user != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          Translations.of(context)
                                              .text('checkYourEmail'),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          Translations.of(context)
                                              .text('loginFailed'),
                                        ),
                                      ),
                                    );
                                  }
                                } on AuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${Translations.of(context).text('loginFailed')}: ${e.message}',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              }
                            }
                          }
                        : null,
                    child: Text(
                      Translations.of(context)
                          .text(
                            'signUp',
                          )
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
