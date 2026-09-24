import '../models/notification_model.dart';

abstract class NotificationRemoteDatasource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String notificationId});
  Stream<List<NotificationModel>> watchNotifications({required String userId});
}