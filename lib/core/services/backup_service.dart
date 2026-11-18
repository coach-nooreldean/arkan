import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

/// Exports and restores user preferences, worship logs, khatmah plans, notes,
/// coins, and achievements stored in local [SharedPreferences].
class BackupService {
  static const List<String> _includedPrefixes = ['arkan_', 'islamic_'];

  static bool _isUserKey(String key) {
    return _includedPrefixes.any((prefix) => key.startsWith(prefix));
  }

  /// Serializes all typed `arkan_*` and `islamic_*` keys into an envelope JSON.
  static Future<String> exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(_isUserKey).toList()..sort();
    final entries = <String, dynamic>{};

    for (final key in keys) {
      final val = prefs.get(key);
      if (val is bool) {
        entries[key] = {'type': 'bool', 'value': val};
      } else if (val is int) {
        entries[key] = {'type': 'int', 'value': val};
      } else if (val is double) {
        entries[key] = {'type': 'double', 'value': val};
      } else if (val is String) {
        entries[key] = {'type': 'string', 'value': val};
      } else if (val is List<String>) {
        entries[key] = {'type': 'string_list', 'value': val};
      } else if (val is List) {
        entries[key] = {
          'type': 'string_list',
          'value': val.map((e) => e.toString()).toList(),
        };
      }
    }

    final envelope = <String, dynamic>{
      'app': 'arkan',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'entries': entries,
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Writes the exported backup JSON to a timestamped temporary `.json` file.
  static Future<File> writeBackupToTempFile() async {
    final json = await exportBackupJson();
    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/arkan_backup_$stamp.json');
    await file.writeAsString(json);
    return file;
  }

  /// Validates and restores typed entries from [rawJson] into [SharedPreferences].
  /// Returns the count of restored keys, or throws [FormatException] on invalid data.
  static Future<int> importBackupJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup JSON root');
    }
    if (decoded['app'] != 'arkan' || decoded['entries'] is! Map) {
      throw const FormatException('Not a valid Arkan backup file');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawEntries = Map<String, dynamic>.from(decoded['entries'] as Map);
    int restored = 0;

    for (final entry in rawEntries.entries) {
      final key = entry.key;
      if (!_isUserKey(key) || entry.value is! Map) continue;
      final item = Map<String, dynamic>.from(entry.value as Map);
      final type = item['type'] as String?;
      final value = item['value'];

      switch (type) {
        case 'bool':
          if (value is bool) {
            await prefs.setBool(key, value);
            restored++;
          }
          break;
        case 'int':
          if (value is num) {
            await prefs.setInt(key, value.toInt());
            restored++;
          }
          break;
        case 'double':
          if (value is num) {
            await prefs.setDouble(key, value.toDouble());
            restored++;
          }
          break;
        case 'string':
          if (value is String) {
            await prefs.setString(key, value);
            restored++;
          }
          break;
        case 'string_list':
          if (value is List) {
            await prefs.setStringList(
              key,
              value.map((e) => e.toString()).toList(),
            );
            restored++;
          }
          break;
      }
    }

    return restored;
  }
}
