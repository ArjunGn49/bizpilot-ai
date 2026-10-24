import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/router/app_router.dart';
import 'package:bizpilotai/core/theme/app_theme.dart';
import 'package:bizpilotai/core/theme/theme_provider.dart';

class BizPilotApp extends StatelessWidget {
  final List<Override>? overrides;

  const BizPilotApp({super.key, this.overrides});

  @override
  Widget build(BuildContext context) {
    // ProviderScope remains at the root but now accepts testing overrides.
    // The routing logic is delegated to the ConsumerWidget underneath it.
    return ProviderScope(
      overrides: overrides ?? [],
      child: const _BizPilotAppRouter(),
    );
  }
}

class _BizPilotAppRouter extends ConsumerWidget {
  const _BizPilotAppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We observe the dynamic GoRouter provided by Riverpod
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BizPilotAI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
