import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/database_provider.dart';
import 'package:bizpilotai/core/database/app_database.dart';

final settingsProvider = StreamProvider.autoDispose<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.settings)).watch().map((rows) {
    final map = <String, String>{};
    for (final row in rows) {
      map[row.key] = row.value;
    }
    return map;
  });
});

final settingsControllerProvider =
    Provider<SettingsController>((ref) => SettingsController(ref.watch(databaseProvider)));

class SettingsController {
  final AppDatabase _db;

  SettingsController(this._db);

  Future<void> saveSetting(String key, String value) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> saveBusinessDetails({
    required String name,
    required String phone,
    required String address,
    required String taxLabel,
    required String currencySymbol,
  }) async {
    await saveSetting('business_name', name);
    await saveSetting('business_phone', phone);
    await saveSetting('business_address', address);
    await saveSetting('tax_label', taxLabel);
    await saveSetting('currency_symbol', currencySymbol);
  }
}
