import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/constants/supabase_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.apiUrl,
    publishableKey: SupabaseConstants.publishableKey,
  );

  runApp(TrelloCloneApp(routerConfig: AppRouter.router));
}
