import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bizpilotai/core/utils/app_logger.dart';
import 'package:bizpilotai/core/security/secure_key_store.dart';

LazyDatabase openConnection(SecureKeyStore keyStore) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bizpilot.sqlite'));
    
    final encryptionKey = await keyStore.getOrCreateDatabaseKey();
    
    return NativeDatabase(file, setup: (rawDb) {
      // Use raw hex blob form (x'<hex>') to safely pass 64-character hex strings to SQLCipher
      rawDb.execute("PRAGMA key = \"x'$encryptionKey'\";");
      rawDb.execute("PRAGMA cipher_memory_security = ON;");
      rawDb.execute("PRAGMA foreign_keys = ON;");
      
      final result = rawDb.select("PRAGMA cipher_version;");
      if (result.isEmpty || result.first.values.first == null || result.first.values.first.toString().isEmpty) {
        throw StateError('SQLCipher is not working. The database is unencrypted.');
      }
      
      final cipherVersion = result.first.values.first.toString();
      logger.d('SQLCipher version at startup: $cipherVersion');
    });
  });
}
