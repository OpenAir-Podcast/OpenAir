import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:openair/views/mobile/account_page.dart';
import 'package:openair/views/mobile/nav_pages/sign_up_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn extends ConsumerStatefulWidget {
  const LogIn({super.key});

  @override
  ConsumerState createState() => _LogInState();
}

class _LogInState extends ConsumerState<LogIn> {
  TextEditingController emailInputControl = TextEditingController();
  TextEditingController passwordInputControl = TextEditingController();

  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailInputControl.dispose();
    passwordInputControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 44.0;
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
                  Translations.of(context).text('login'),
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
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return Translations.of(context).text('invalidEmail');
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
              SizedBox(height: 16.0),
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
                          final username = emailInputControl.text.trim();
                          final password = passwordInputControl.text.trim();

                          try {
                            AuthResponse response = await supabaseService
                                .signIn(username, password);

                            if (response.user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Translations.of(context)
                                        .text('loginSuccess'),
                                  ),
                                ),
                              );

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AccountPage()));
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
                    },
                    child: Text(
                      Translations.of(context)
                          .text(
                            'login',
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
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      Translations.of(context).text(
                        'or',
                      ),
                      style: TextStyle(
                        color: Brightness.dark == Theme.of(context).brightness
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 300.0,
                          height: 48.0,
                          child: IconButton(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  height: iconSize,
                                  width: iconSize,
                                  Brightness.dark ==
                                          Theme.of(context).brightness
                                      ? 'assets/images/google-white-logo.png'
                                      : 'assets/images/google-black-logo.png',
                                ),
                                Text(
                                  Translations.of(context)
                                      .text('continueWithGoogle'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () => supabaseService.logInUsingGoogle(),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        SizedBox(
                          width: 300.0,
                          height: 48.0,
                          child: IconButton(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  height: iconSize - 20,
                                  width: iconSize - 20,
                                  Brightness.dark ==
                                          Theme.of(context).brightness
                                      ? 'assets/images/github-white-logo.png'
                                      : 'assets/images/github-black-logo.png',
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  Translations.of(context)
                                      .text('continueWithGithub'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () => supabaseService.logInUsingGithub(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Translations.of(context).text('dontHaveAnAccount'),
                          style: TextStyle(
                            color:
                                Brightness.dark == Theme.of(context).brightness
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
      ),
    );
  }
}
