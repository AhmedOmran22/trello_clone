import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/constants/supabase_constants.dart';
import 'core/di/di_container.dart';
import 'firebase_options.dart';

// Runs in its own isolate when a push arrives while the app is backgrounded
// or terminated, so it needs to be a top-level function, not a method, and
// re-initializes Firebase since that isolate doesn't share the main one's.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initDependencies();
  await Supabase.initialize(
    url: SupabaseConstants.apiUrl,
    publishableKey: SupabaseConstants.publishableKey,
  );

  runApp(TrelloCloneApp(routerConfig: AppRouter.router));
}
