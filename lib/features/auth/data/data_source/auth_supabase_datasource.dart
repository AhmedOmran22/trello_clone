import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthSupabaseDatasource implements AuthRemoteDatasource {
  final SupabaseServices services;

  AuthSupabaseDatasource(this.services);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await services.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Login failed. No user returned.');
      }

      return await _fetchProfile(response.user!.id);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await services.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw const AuthException('Registration failed. No user returned.');
      }

      return await _fetchProfile(response.user!.id);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final response = await services.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.omran.trello.clone://login-callback/',
      );

      if (!response) {
        throw const AuthException('Google sign in was cancelled.');
      }

      // Wait for the auth state to change after OAuth redirect
      final completer = await services.client.auth.onAuthStateChange.firstWhere(
        (data) => data.session != null,
      );

      return await _fetchProfile(completer.session!.user.id);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await services.client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = services.client.auth.currentUser;

      if (user == null) {
        throw const AuthException('No authenticated user found.');
      }

      return await _fetchProfile(user.id);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  /// Private helper - fetches the profile from our profiles table
  Future<UserModel> _fetchProfile(String userId) async {
    try {
      final response = await services.getById(SupabaseTables.profiles, userId);

      return UserModel.fromJson(response);
    } on ServerException {
      rethrow;
    }
  }
}
