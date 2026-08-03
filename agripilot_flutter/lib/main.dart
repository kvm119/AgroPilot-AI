import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'core/theme/app_theme.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'core/offline/models/sync_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaskTypeAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(SyncTaskAdapter());
  
  // We can open the core boxes here or provide them via Riverpod
  runApp(const ProviderScope(child: AgriPilotApp()));
}

class AgriPilotApp extends ConsumerWidget {
  const AgriPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AgriPilot AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
