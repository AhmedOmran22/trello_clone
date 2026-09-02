import 'package:get_it/get_it.dart';

import '../services/subabase_services.dart';
final getIt = GetIt.instance;
void setupServiceLocator() 
{
  getIt.registerSingleton<SupabaseServices>(SupabaseServices());
}
