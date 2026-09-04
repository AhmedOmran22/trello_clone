import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] (e.g. a Cubit's state stream) to a [Listenable] so
/// GoRouter can be notified to re-evaluate `redirect` when it emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
