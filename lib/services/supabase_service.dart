import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  String? redirectToString = dotenv.env['CALLBACK_METHOD'];

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
        emailRedirectTo: redirectToString,
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

  logInUsingGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : redirectToString,
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

  logInUsingGithub() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb ? null : redirectToString,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
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
