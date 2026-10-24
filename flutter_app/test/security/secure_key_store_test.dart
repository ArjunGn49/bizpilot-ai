import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app/core/security/secure_key_store.dart';

void main() {
  setUp(() {
    // Ensures in-memory stubbing for Secure Storage so tests don't try to access native iOS/Android keychains.
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('First call generates a key, second call returns the same key', () async {
    final store = SecureKeyStore(const FlutterSecureStorage());
    
    final key1 = await store.getOrCreateDatabaseKey();
    final key2 = await store.getOrCreateDatabaseKey();
    
    expect(key1, key2);
    expect(key1, isNotEmpty);
  });

  test('Two different stores generate different keys', () async {
    // Simulate first install
    FlutterSecureStorage.setMockInitialValues({});
    final store1 = SecureKeyStore(const FlutterSecureStorage());
    final key1 = await store1.getOrCreateDatabaseKey();

    // Clear mock storage to simulate a fresh installation on a separate device
    FlutterSecureStorage.setMockInitialValues({});
    final store2 = SecureKeyStore(const FlutterSecureStorage());
    final key2 = await store2.getOrCreateDatabaseKey();

    expect(key1, isNot(equals(key2)));
  });

  test('Key is exactly 32 bytes of entropy (hex string length 64)', () async {
    final store = SecureKeyStore(const FlutterSecureStorage());
    final key = await store.getOrCreateDatabaseKey();
    
    expect(key.length, 64);
    // Validate that it consists solely of valid hex characters
    expect(RegExp(r'^[0-9a-fA-F]+$').hasMatch(key), isTrue);
  });
}
