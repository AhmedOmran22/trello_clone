import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';

/// Registers this device for push (FCM token → `fcm_tokens` table) and wires
/// up the message handlers. The Supabase edge function / DB webhook that
/// actually sends the push is set up outside this app.
///
/// [initialize] is called from [SessionCubit]'s "authenticated" transition,
/// which fires both on a fresh login and on a restored session at cold
/// start — and, on a shared device, can fire more than once per process if
/// a different user logs in after the previous one logs out. Only the
/// permission request and the message/token listeners are one-time setup;
/// fetching the current token and attributing it to whoever is signed in
/// right now runs on every call, so a user switch on the same install still
/// ends up with the right row in `fcm_tokens`.
///
/// Token save/delete failures are swallowed on purpose — push is a
/// nice-to-have on top of the in-app notification list, not something that
/// should block login or logout if it hiccups.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _listenersRegistered = false;

  Future<void> initialize() async {
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

    if (_listenersRegistered) return;
    _listenersRegistered = true;

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
    // message.data carries 'type' / 'task_id' / 'workspace_id'. Still
    // unwired: navigating based on type needs a global navigator/router
    // handle, e.g.:
    // - task_assigned / task_moved -> open the board screen for task_id
    // - member_added -> open the workspace screen for workspace_id
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
