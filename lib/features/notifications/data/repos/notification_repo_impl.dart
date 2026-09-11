import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/notification_entity.dart';
import '../../domain/repo/notification_repo.dart';
import '../datasource/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepo {
  final NotificationRemoteDatasource datasource;

  NotificationRepositoryImpl(this.datasource);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    try {
      final models = await datasource.getNotifications();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> markAsRead({required String notificationId}) async {
    try {
      await datasource.markAsRead(notificationId: notificationId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await datasource.markAllAsRead();
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteNotification({required String notificationId}) async {
    try {
      await datasource.deleteNotification(notificationId: notificationId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications({required String userId}) {
    return datasource
        .watchNotifications(userId: userId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
