import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
