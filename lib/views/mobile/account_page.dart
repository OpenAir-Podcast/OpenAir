import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: StreamBuilder<AuthState>(
        stream: supabaseService.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!.session?.user;

            if (user == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await supabaseService.client.auth.signInWithOAuth(
                      OAuthProvider.github,
                    );
                  },
                  child: const Text('Sign In with GitHub'),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text('Welcome ${snapshot.data!.session!.user.email}'),
                  ElevatedButton(
                    onPressed: () async {
                      await supabaseService.client.auth.signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  await supabaseService.client.auth.signInWithOAuth(
                    OAuthProvider.github,
                  );
                },
                child: const Text('Sign In with GitHub'),
              ),
            );
          }
        },
      ),
    );
  }
}
