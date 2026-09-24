import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../repo/profile_repo.dart';

class UpdateProfileUseCase {
  final ProfileRepo repository;

  const UpdateProfileUseCase(this.repository);

  Future<Result<UserEntity>> call({required String fullName}) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      return Result.error(const ServerFailure('Name cannot be empty'));
    }

    return repository.updateProfile(fullName: trimmedName);
  }
}
