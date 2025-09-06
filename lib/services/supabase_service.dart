import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Example function to get user data
  Future<User?> getUser() async {
    return client.auth.currentUser;
  }
}
