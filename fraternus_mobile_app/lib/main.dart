import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/env.dart';
import 'app/fraternus_app.dart';
import 'app/shared_preferences_provider.dart';
import 'features/app_version/data/app_version_repository.dart';
import 'features/app_version/providers/app_version_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  // Resolved before runApp (and fails open, see resolveAppVersionStatus)
  // so the router's redirect can force-update the user before any UI —
  // signed in or not — is reachable.
  final appVersionStatus = await resolveAppVersionStatus(
    SupabaseAppVersionRepository(Supabase.instance.client),
  );
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        appVersionStatusProvider.overrideWithValue(appVersionStatus),
      ],
      child: const FraternusApp(),
    ),
  );
}
