import 'package:drift/drift.dart';
import 'package:bizpilotai/core/security/secure_key_store.dart';

LazyDatabase openConnection(SecureKeyStore keyStore) {
  throw UnsupportedError(
    'SQLCipher encrypted SQLite database is supported on native platforms (Windows, macOS, Linux, Android, iOS). '
    'Please run the app on Windows or Android.',
  );
}
