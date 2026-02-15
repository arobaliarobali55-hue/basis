import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tool_model.dart';
import '../models/user_settings_model.dart';

class SupabaseRepository {
  final SupabaseClient _client;

  SupabaseRepository(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? companyName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: companyName != null ? {'company_name': companyName} : null,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<List<ToolModel>> fetchTools() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('tools')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    return (response as List).map((json) => ToolModel.fromJson(json)).toList();
  }

  Future<void> addTool(ToolModel tool) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('tools').insert({...tool.toJson(), 'user_id': user.id});
  }

  Future<void> updateTool(ToolModel tool) async {
    await _client.from('tools').update(tool.toJson()).eq('id', tool.id);
  }

  Future<void> deleteTool(String id) async {
    await _client.from('tools').delete().eq('id', id);
  }

  Future<UserSettingsModel?> fetchUserSettings() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('user_settings')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return UserSettingsModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('user_settings').upsert({
      ...settings.toJson(),
      'id': user.id,
    });
  }

  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _client.from('tools').delete().eq('user_id', user.id);
      await _client.from('user_settings').delete().eq('id', user.id);
    }
  }
}
