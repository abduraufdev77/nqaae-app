import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const universityCacheTtl = Duration(hours: 3);

class UniversityCacheEntry {
  const UniversityCacheEntry({required this.body, required this.savedAt});

  final String body;
  final DateTime savedAt;

  bool isFreshAt(DateTime now) {
    return now.difference(savedAt) < universityCacheTtl;
  }
}

abstract class UniversityCacheStore {
  Future<UniversityCacheEntry?> read(String key);

  Future<void> write(String key, UniversityCacheEntry entry);

  Future<void> remove(String key);
}

class SharedPreferencesUniversityCacheStore implements UniversityCacheStore {
  const SharedPreferencesUniversityCacheStore();

  @override
  Future<UniversityCacheEntry?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(key);
    if (encoded == null) return null;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return UniversityCacheEntry(
        body: json['body'] as String,
        savedAt: DateTime.fromMillisecondsSinceEpoch(
          json['saved_at_ms'] as int,
          isUtc: true,
        ),
      );
    } catch (_) {
      await preferences.remove(key);
      return null;
    }
  }

  @override
  Future<void> write(String key, UniversityCacheEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode({
        'body': entry.body,
        'saved_at_ms': entry.savedAt.toUtc().millisecondsSinceEpoch,
      }),
    );
  }

  @override
  Future<void> remove(String key) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }
}
