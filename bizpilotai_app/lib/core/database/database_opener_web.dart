import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:bizpilotai/core/security/secure_key_store.dart';

LazyDatabase openConnection(SecureKeyStore keyStore) {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'bizpilot_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
