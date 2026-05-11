import 'package:flutter/foundation.dart';
import 'package:openair/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  String? supabaseRedirectToString = Env.callbackMethod;
  String? googleRedirectToString = Env.supabaseGoogleCallback;
  String? githubRedirectToString = Env.supabaseGithubCallback;

  // Example function to get user data
  Future<User?> getUser() async {
    return client.auth.currentUser;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // Handle sign-in errors
      debugPrint('Sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<AuthResponse> signUp(
      String email, String password, String username) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        // emailRedirectTo: supabaseRedirectToString,
      );
    } on AuthException catch (e) {
      // Handle sign-up errors
      debugPrint('Sign-up error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      throw Exception('Sign-up failed: $e');
    }
  }

  Future<void> signOut() {
    return client.auth.signOut(scope: SignOutScope.global);
  }

  Future<void> deleteAccount() async {
    try {
      // Calls a stored procedure on Supabase to delete the authenticated user
      await client.rpc('delete_user');
      await signOut();
    } catch (e) {
      debugPrint('An error occurred during account deletion: $e');
      throw Exception('Account deletion failed: $e');
    }
  }

  Future<void> logInUsingGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        // redirectTo: kIsWeb ? null : googleRedirectToString,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      debugPrint('Google sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during Google sign-in: $e');
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<void> logInUsingGithub() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.github,
        // redirectTo: kIsWeb ? null : githubRedirectToString,
        // authScreenLaunchMode: kIsWeb
        //     ? LaunchMode.platformDefault
        //     : LaunchMode.externalApplication,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );
    } on AuthException catch (e) {
      debugPrint('GitHub sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during GitHub sign-in: $e');
      throw Exception('GitHub sign-in failed: $e');
    }
  }
}
