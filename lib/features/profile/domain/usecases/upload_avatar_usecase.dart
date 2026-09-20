import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repo/profile_repo.dart';

class UploadAvatarUseCase {
  final ProfileRepo repository;

  const UploadAvatarUseCase(this.repository);

  Future<Result<String>> call({required String userId, required String filePath}) async {
    if (filePath.trim().isEmpty) {
      return Result.error(const ServerFailure('No image selected'));
    }

    return repository.uploadAvatar(userId: userId, filePath: filePath);
  }
}
