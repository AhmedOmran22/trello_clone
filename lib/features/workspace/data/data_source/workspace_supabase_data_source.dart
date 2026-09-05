import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/workspace_model.dart';
import 'work_space_remote_data_source.dart';

class WorkspaceSupabaseDatasource implements WorkspaceRemoteDatasource {
  final SupabaseServices services;

  WorkspaceSupabaseDatasource(this.services);

  @override
  Future<List<WorkspaceModel>> getWorkspaces() async {
    try {
      final userId = services.client.auth.currentUser!.id;

      final response = await services.client
          .from(SupabaseTables.workspaceMembers)
          .select('role, workspaces(*)')
          .eq('user_id', userId);

      return response.map((json) => WorkspaceModel.fromJson(json)).toList();
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String userId,
  }) async {
    try {
      final response = await services.client.rpc(
        'create_workspace',
        params: {'workspace_name': name},
      );

      return WorkspaceModel.fromWorkspaceJson(
        Map<String, dynamic>.from(response),
        'owner',
      );
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WorkspaceModel> updateWorkspace({
    required String id,
    required String name,
  }) async {
    try {
      final response = await services.update(SupabaseTables.workspaces, id, {
        'name': name,
      });

      // Get the user's role for this workspace
      final userId = services.client.auth.currentUser!.id;
      final memberResponse = await services.client
          .from(SupabaseTables.workspaceMembers)
          .select('role')
          .eq('workspace_id', id)
          .eq('user_id', userId)
          .single();

      return WorkspaceModel.fromWorkspaceJson(
        response,
        memberResponse['role'] as String,
      );
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteWorkspace({required String id}) async {
    try {
      await services.delete(SupabaseTables.workspaces, id);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addMember({
    required String workspaceId,
    required String email,
  }) async {
    try {
      // Step 1: Find user by email
      final userResponse = await services.client
          .from(SupabaseTables.profiles)
          .select('id')
          .eq('email', email)
          .maybeSingle();

      // Handle: email not found
      if (userResponse == null) {
        throw const ServerException(
          'No user found with this email. They need to create an account first.',
        );
      }

      final userId = userResponse['id'] as String;

      // Handle: user already a member
      final existingMember = await services.client
          .from(SupabaseTables.workspaceMembers)
          .select('id')
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw const ServerException(
          'This user is already a member of this workspace.',
        );
      }

      // Handle: adding yourself
      final currentUserId = services.client.auth.currentUser!.id;
      if (userId == currentUserId) {
        throw const ServerException('You are already a member of this workspace.');
      }

      // Step 2: Add to workspace_members
      await services.insert(SupabaseTables.workspaceMembers, {
        'workspace_id': workspaceId,
        'user_id': userId,
        'role': 'member',
      });
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await services.client
          .from(SupabaseTables.workspaceMembers)
          .delete()
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }
}
