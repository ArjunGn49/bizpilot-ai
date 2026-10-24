import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  final FlutterSecureStorage _storage;
  static const String _keyName = 'bizpilot_db_key';

  SecureKeyStore(this._storage);

  Future<String> getOrCreateDatabaseKey() async {
    final existingKey = await _storage.read(key: _keyName);
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    // Generate cryptographically secure random 32-byte key
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final newKey = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    await _storage.write(key: _keyName, value: newKey);
    return newKey;
  }
}
