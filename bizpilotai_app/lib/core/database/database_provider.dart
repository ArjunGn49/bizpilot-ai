import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/app_database.dart';
import 'package:bizpilotai/core/security/secure_key_store_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.withKeyStore(ref.watch(secureKeyStoreProvider));
});
