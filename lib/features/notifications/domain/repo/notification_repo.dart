import '../../../../core/utils/result.dart';
import '../entity/notification_entity.dart';

abstract class NotificationRepo {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<void>> markAsRead({required String notificationId});
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> deleteNotification({required String notificationId});
  Stream<List<NotificationEntity>> watchNotifications({required String userId});
}