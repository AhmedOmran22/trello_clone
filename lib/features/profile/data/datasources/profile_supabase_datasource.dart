import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, StorageException;

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../../../auth/data/models/user_model.dart';
import 'profile_remote_datasource.dart';

class ProfileSupabaseDatasource implements ProfileRemoteDatasource {
  static const _avatarBucket = 'avatars';

  final SupabaseServices services;

  ProfileSupabaseDatasource(this.services);

  String get _currentUserId {
    final user = services.client.auth.currentUser;
    if (user == null) throw const AuthException('No authenticated user found.');
    return user.id;
  }

  // Path inside the bucket — RLS keys on the first segment being the user's id.
  String _avatarPath(String userId) => '$userId/avatar.jpg';

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await services.getById(SupabaseTables.profiles, _currentUserId);
      return UserModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<UserModel> updateProfile({required String fullName}) async {
    try {
      final response = await services.update(SupabaseTables.profiles, _currentUserId, {
        'full_name': fullName,
      });
      return UserModel.fromJson(response);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<String> uploadAvatar({required String userId, required String filePath}) async {
    try {
      final path = _avatarPath(userId);
      final bucket = services.client.storage.from(_avatarBucket);

      await bucket.upload(
        path,
        File(filePath),
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );

      // The object path never changes, so the CDN/Image cache would keep serving
      // the old picture — a fresh `t` makes every client treat it as a new URL.
      final avatarUrl =
          '${bucket.getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

      await services.update(SupabaseTables.profiles, userId, {'avatar_url': avatarUrl});
      return avatarUrl;
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }

  @override
  Future<void> removeAvatar({required String userId}) async {
    try {
      try {
        await services.client.storage.from(_avatarBucket).remove([_avatarPath(userId)]);
      } on StorageException catch (e) {
        // Nothing to delete is fine — we still need to clear avatar_url below.
        if (e.statusCode != '404') rethrow;
      }

      await services.update(SupabaseTables.profiles, userId, {'avatar_url': null});
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } on Exception catch (e) {
      throw mapToAppException(e);
    }
  }
}
