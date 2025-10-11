import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/mobile/nav_pages/sign_up_page.dart';
import 'package:openair/views/mobile/settings_pages/notifications_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  TextEditingController emailInputControl = TextEditingController();
  TextEditingController passwordInputControl = TextEditingController();

  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailInputControl.dispose();
    passwordInputControl.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  Widget build(BuildContext context) {
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('account')),
      ),
      body: StreamBuilder<AuthState>(
        stream: supabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!.session?.user;

            if (user == null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 16.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          Translations.of(context).text('signIn'),
                          style: TextStyle(
                            color:
                                Brightness.dark == Theme.of(context).brightness
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
                            return Translations.of(context)
                                .text('requiredField');
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return Translations.of(context)
                                .text('invalidEmail');
                          }

                          return null;
                        },
                        keyboardType: TextInputType.text,
                        controller: emailInputControl,
                        onChanged: (value) {
                          if (emailInputControl.text.isNotEmpty) {
                            setState(() {});
                          }
                        },
                        decoration: InputDecoration(
                          label: Text(Translations.of(context).text('email')),
                          border: OutlineInputBorder(),
                          hintText:
                              Translations.of(context).text('typeYourEmail'),
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
                            return Translations.of(context)
                                .text('requiredField');
                          } else if (value.length < 6) {
                            return Translations.of(context)
                                .text('invalidPassword');
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
                          label:
                              Text(Translations.of(context).text('password')),
                          border: OutlineInputBorder(),
                          hintText:
                              Translations.of(context).text('typeYourPassword'),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            Translations.of(context).text('forgotPassword'),
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 380.0,
                          height: 48.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () async {
                              if (context.mounted) {
                                if (_formKey.currentState!.validate()) {
                                  final username =
                                      emailInputControl.text.trim();
                                  final password =
                                      passwordInputControl.text.trim();

                                  try {
                                    AuthResponse response =
                                        await supabaseService.signIn(
                                            username, password);

                                    if (response.user != null &&
                                        context.mounted) {
                                      if (!Platform.isAndroid &&
                                          !Platform.isIOS) {
                                        ref
                                            .read(notificationServiceProvider)
                                            .showNotification(
                                              'OpenAir ${Translations.of(context).text('notification')}',
                                              Translations.of(context)
                                                  .text('loginSuccess'),
                                            );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              Translations.of(context)
                                                  .text('loginSuccess'),
                                            ),
                                          ),
                                        );
                                      }

                                      // widget.returnFromSignin();
                                    } else {
                                      if (context.mounted) {
                                        if (!Platform.isAndroid &&
                                            !Platform.isIOS) {
                                          ref
                                              .read(notificationServiceProvider)
                                              .showNotification(
                                                'OpenAir ${Translations.of(context).text('notification')}',
                                                Translations.of(context)
                                                    .text('loginFailed'),
                                              );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                Translations.of(context)
                                                    .text('loginFailed'),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  } on AuthException catch (e) {
                                    if (context.mounted) {
                                      if (!Platform.isAndroid &&
                                          !Platform.isIOS) {
                                        ref
                                            .read(notificationServiceProvider)
                                            .showNotification(
                                              'OpenAir ${Translations.of(context).text('notification')}',
                                              '${Translations.of(context).text('loginFailed')}: ${e.message}',
                                            );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${Translations.of(context).text('loginFailed')}: ${e.message}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                }
                              }
                            },
                            child: Text(
                              Translations.of(context)
                                  .text(
                                    'signIn',
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
                      SizedBox(height: 2.0),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Translations.of(context)
                                      .text('dontHaveAnAccount'),
                                  style: TextStyle(
                                    color: Brightness.dark ==
                                            Theme.of(context).brightness
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUp(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    Translations.of(context).text('signUp'),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.appMetadata['provider'] != null)
                    Text(
                        '${Translations.of(context).text('provider')}: ${user.appMetadata['provider']}'),
                  const SizedBox(height: 16),
                  if (user.email != null)
                    Text(
                        '${Translations.of(context).text('email')}: ${user.email}'),
                  const SizedBox(height: 16),
                  Text(
                      '${Translations.of(context).text('userID')}: ${user.id}'),
                  const SizedBox(height: 16),
                  Text(
                      '${Translations.of(context).text('accountCreated')}: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(user.createdAt))}'),
                  const SizedBox(height: 16),
                  if (user.lastSignInAt != null)
                    Text(
                        '${Translations.of(context).text('lastSignIn')}: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(user.lastSignInAt!))}'),
                  const SizedBox(height: 16),
                  if (user.updatedAt != null)
                    Text(
                        '${Translations.of(context).text('lastUpdate')}: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(user.updatedAt!))}'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      await supabaseService.client.auth.refreshSession();
                    },
                    child: Text(Translations.of(context).text('sync')),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await supabaseService.client.auth.signOut();
                    },
                    child: Text(Translations.of(context).text('signOut')),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No authentication data available.'));
          }
        },
      ),
    );
  }
}
