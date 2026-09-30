import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/context_extensions.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/notification_entity.dart';
import '../cubits/notification_cubit.dart';
import '../cubits/notification_state.dart';
import '../widgets/empty_notifications.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (previous, current) =>
          current.status == NotificationStatus.error &&
          current.error != null &&
          current.error != previous.error,
      listener: (context, state) => context.showErrorSnackBar(state.error!),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          // Once notifications are already on screen, a transient stream
          // error (or the cubit swapping back to "loading") shouldn't blank
          // the list — only show a full-screen state before anything has
          // ever loaded.
          if (state.notifications.isNotEmpty) {
            return _NotificationList(notifications: state.notifications);
          }

          switch (state.status) {
            case NotificationStatus.initial:
            case NotificationStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case NotificationStatus.error:
              return _ErrorView(
                message: state.error ?? 'Something went wrong',
                onRetry: () {
                  final userId = context.read<SessionCubit>().state.user?.id;
                  if (userId != null) {
                    context.read<NotificationCubit>().startListening(userId);
                  }
                },
              );
            case NotificationStatus.loaded:
              return const EmptyNotifications();
          }
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationCubit>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, thickness: 0.5, color: context.colorScheme.outlineVariant),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () {
              if (!notification.isRead) cubit.markAsRead(notification.id);
            },
            onDismissed: () => cubit.deleteNotification(notification.id),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text(message, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
