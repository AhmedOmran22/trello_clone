import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/work_space_entity.dart';
import '../../domain/entity/workspace_member_entity.dart';
import '../../domain/repo/workspace_repo.dart';
import '../data_source/work_space_remote_data_source.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepo {
  final WorkspaceRemoteDatasource datasource;

  WorkspaceRepositoryImpl(this.datasource);

  @override
  Future<Result<List<WorkspaceEntity>>> getWorkspaces() async {
    try {
      final models = await datasource.getWorkspaces();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<WorkspaceEntity>> createWorkspace({
    required String name,
    required String userId,
  }) async {
    try {
      final model = await datasource.createWorkspace(name: name, userId: userId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<WorkspaceEntity>> updateWorkspace({
    required String id,
    required String name,
  }) async {
    try {
      final model = await datasource.updateWorkspace(id: id, name: name);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteWorkspace({required String id}) async {
    try {
      await datasource.deleteWorkspace(id: id);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<WorkspaceMemberEntity>> addMember({
    required String workspaceId,
    required String email,
  }) async {
    try {
      final model = await datasource.addMember(workspaceId: workspaceId, email: email);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await datasource.removeMember(workspaceId: workspaceId, userId: userId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }
}
