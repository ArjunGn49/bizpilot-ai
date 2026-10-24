import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/database/app_database.dart';
import 'package:flutter_app/core/security/secure_key_store_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.withKeyStore(ref.watch(secureKeyStoreProvider));
});
