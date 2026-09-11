import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/notification_entity.dart';
import '../../domain/repo/notification_repo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo repository;
  StreamSubscription? _subscription;

  NotificationCubit({required this.repository}) : super(const NotificationState());

  void startListening(String userId) {
    _subscription?.cancel();
    _subscription = repository
        .watchNotifications(userId: userId)
        .listen(
          (notifications) => emit(
            state.copyWith(
              status: NotificationStatus.loaded,
              notifications: notifications,
            ),
          ),
          onError: (error) => emit(
            state.copyWith(
              status: NotificationStatus.error,
              error: error.toString(),
            ),
          ),
        );
  }

  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final updated = state.notifications.map((n) {
      if (n.id == notificationId) {
        return NotificationEntity(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));

    // Server call
    await repository.markAsRead(notificationId: notificationId);
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    final updated = state.notifications.map((n) {
      return NotificationEntity(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();
    emit(state.copyWith(notifications: updated));

    // Server call
    await repository.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    // Optimistic update
    final updated = state.notifications
        .where((n) => n.id != notificationId)
        .toList();
    emit(state.copyWith(notifications: updated));

    // Server call
    await repository.deleteNotification(notificationId: notificationId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
