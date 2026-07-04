import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class FirebaseService {
  auth.User? get user => auth.FirebaseAuth.instance.currentUser;

  Future<auth.UserCredential> signIn(String email, String password) async {
    try {
      return await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<auth.UserCredential> signUp(
      String email, String password, String username) async {
    try {
      final credential =
          await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(username);
      await credential.user?.sendEmailVerification();
      return credential;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Sign-up error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      throw Exception('Sign-up failed: $e');
    }
  }

  Future<void> signOut() {
    return auth.FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      await signOut();
    } catch (e) {
      debugPrint('An error occurred during account deletion: $e');
      throw Exception('Account deletion failed: $e');
    }
  }

  Future<auth.UserCredential> logInUsingGoogle() async {
    try {
      if (kIsWeb) {
        return await auth.FirebaseAuth.instance.signInWithPopup(
          auth.GoogleAuthProvider(),
        );
      }
      return await auth.FirebaseAuth.instance.signInWithProvider(
        auth.GoogleAuthProvider(),
      );
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Google sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during Google sign-in: $e');
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.message}');
      rethrow;
    }
  }

  Future<void> logInUsingGithub() async {
    try {
      await auth.FirebaseAuth.instance.signInWithProvider(
        auth.GithubAuthProvider(),
      );
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('GitHub sign-in error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during GitHub sign-in: $e');
      throw Exception('GitHub sign-in failed: $e');
    }
  }
}
