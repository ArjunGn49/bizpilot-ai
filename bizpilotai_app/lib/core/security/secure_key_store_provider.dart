import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bizpilotai/core/security/secure_key_store.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return SecureKeyStore(ref.watch(secureStorageProvider));
});
