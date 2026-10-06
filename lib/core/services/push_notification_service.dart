import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';

/// Registers this device for push (FCM token → `fcm_tokens` table) and wires
/// up the message handlers. The Supabase edge function / DB webhook that
/// actually sends the push is set up outside this app.
///
/// Token save/delete failures are swallowed on purpose — push is a
/// nice-to-have on top of the in-app notification list, not something that
/// should block login or logout if it hiccups.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // Set eagerly, not after the awaits below — a second call that arrives
    // while the first is still mid-flight (e.g. a quick logout+login) must
    // not register the onMessage/onMessageOpenedApp listeners twice.
    _initialized = true;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  Future<void> _saveToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from(SupabaseTables.fcmTokens).upsert({
        'user_id': userId,
        'token': token,
        'device_name': 'flutter_app',
      }, onConflict: 'user_id, token');
    } catch (_) {
      // Not critical — the user just won't get push until the next refresh.
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // In-app notifications already cover live updates while the app is
    // open; nothing to show here for now.
  }

  void _handleMessageTap(RemoteMessage message) {
    // message.data carries 'type' / 'task_id' / 'workspace_id'.
    // : navigate based on type, once there's a global navigator/router
    // handle to do it from here:
    // - task_assigned / task_moved → open the board screen for task_id
    // - member_added → open the workspace screen for workspace_id
    // For now this just leaves the app open on whatever screen it was on.
  }

  Future<void> removeToken() async {
    try {
      final token = await _messaging.getToken();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (token == null || userId == null) return;

      await Supabase.instance.client
          .from(SupabaseTables.fcmTokens)
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (_) {
      // User is logging out regardless — a stale token just means this
      // device stops getting push next time someone looks at this table.
    }
  }
}
