import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/router/app_router.dart';
import 'package:flutter_app/core/theme/app_theme.dart';

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
    
    return MaterialApp.router(
      title: 'BizPilotAI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
