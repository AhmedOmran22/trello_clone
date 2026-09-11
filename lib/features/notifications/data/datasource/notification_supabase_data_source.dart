import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/subabase_services.dart';
import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

class NotificationSupabaseDatasource implements NotificationRemoteDatasource {
  final SupabaseServices services;

  NotificationSupabaseDatasource(this.services);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = services.client.auth.currentUser!.id;

      final response = await services.client
          .from(SupabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => NotificationModel.fromJson(json)).toList();
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await services.update(SupabaseTables.notifications, notificationId, {
        'is_read': true,
      });
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = services.client.auth.currentUser!.id;

      await services.client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      await services.delete(SupabaseTables.notifications, notificationId);
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<NotificationModel>> watchNotifications({required String userId}) {
    return services.client
        .from(SupabaseTables.notifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => NotificationModel.fromJson(json)).toList(),
        );
  }
}
