import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  auth.User? get user => auth.FirebaseAuth.instance.currentUser;

  Future<void> deleteUserData() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final db = FirebaseFirestore.instance;
    final collections = [
      'subscriptions',
      'history',
      'queue',
      'favorites',
      'episode_positions',
      'settings',
    ];
    for (final collection in collections) {
      final snapshot = await db
          .collection('users')
          .doc(user.uid)
          .collection(collection)
          .get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

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

  Future<void> reauthenticate(String email, String password) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');
    final credential = auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  String? getAuthProvider() {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('password')) return 'password';
    if (providers.contains('google.com')) return 'google.com';
    if (providers.contains('github.com')) return 'github.com';
    return providers.isNotEmpty ? providers.first : null;
  }

  Future<void> reauthenticateWithProvider(String providerId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    switch (providerId) {
      case 'google.com':
        if (kIsWeb) {
          await user.reauthenticateWithPopup(auth.GoogleAuthProvider());
        } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser == null) {
            throw Exception('Google re-authentication cancelled');
          }
          final googleAuth = await googleUser.authentication;
          final credential = auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.reauthenticateWithCredential(credential);
        } else {
          await user.reauthenticateWithProvider(auth.GoogleAuthProvider());
        }
      case 'github.com':
        if (kIsWeb) {
          await user.reauthenticateWithPopup(auth.GithubAuthProvider());
        } else {
          await user.reauthenticateWithProvider(auth.GithubAuthProvider());
        }
      default:
        throw Exception('Unsupported auth provider: $providerId');
    }
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
      rethrow;
    }
  }

  Future<auth.UserCredential> logInUsingGoogle() async {
    try {
      final googleProvider = auth.GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        return await auth.FirebaseAuth.instance.signInWithPopup(googleProvider);
      }
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        await GoogleSignIn().signOut();
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw Exception('Google sign-in cancelled');
        }
        final googleAuth = await googleUser.authentication;
        final credential = auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await auth.FirebaseAuth.instance.signInWithCredential(credential);
      }
      return await auth.FirebaseAuth.instance.signInWithProvider(googleProvider);
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
