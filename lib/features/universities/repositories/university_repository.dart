import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/university.dart';
import 'university_cache_store.dart';

class UniversityRepository {
  UniversityRepository({
    http.Client? client,
    String? baseUrl,
    UniversityCacheStore? cacheStore,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _cacheStore =
           cacheStore ?? const SharedPreferencesUniversityCacheStore(),
       _now = now ?? DateTime.now;

  final http.Client _client;
  final String _baseUrl;
  final UniversityCacheStore _cacheStore;
  final DateTime Function() _now;
  final Map<String, Future<dynamic>> _inFlight = {};

  String listCacheKey({String? search, int page = 1, int pageSize = 20}) {
    final normalizedSearch = (search ?? '').trim().toLowerCase();
    final canonical = jsonEncode({
      'search': normalizedSearch,
      'page': page,
      'page_size': pageSize,
    });
    final encoded = base64Url
        .encode(utf8.encode(canonical))
        .replaceAll('=', '');
    return 'nqaae.universities.list.v1.$encoded';
  }

  String detailCacheKey(int sourceId) {
    return 'nqaae.universities.detail.v1.$sourceId';
  }

  Future<CachedUniversityValue<UniversityListResponse>?>
  readCachedUniversities({String? search, int page = 1, int pageSize = 20}) {
    return _readCached(
      listCacheKey(search: search, page: page, pageSize: pageSize),
      (body) => UniversityListResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      ),
    );
  }

  Future<CachedUniversityValue<University>?> readCachedUniversity(
    int sourceId,
  ) {
    return _readCached(
      detailCacheKey(sourceId),
      (body) => University.fromJson(jsonDecode(body) as Map<String, dynamic>),
    );
  }

  Future<UniversityListResponse> fetchUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    final cacheKey = listCacheKey(
      search: search,
      page: page,
      pageSize: pageSize,
    );
    return _deduplicate(cacheKey, () async {
      final uri = Uri.parse('$_baseUrl/api/universities').replace(
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': '$page',
          'page_size': '$pageSize',
        },
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw UniversityApiException('Failed to load universities');
      }
      final body = utf8.decode(response.bodyBytes);
      final value = UniversityListResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );
      await _writeCacheSafely(cacheKey, body);
      return value;
    });
  }

  Future<University> fetchUniversity(int sourceId) {
    final cacheKey = detailCacheKey(sourceId);
    return _deduplicate(cacheKey, () async {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/universities/$sourceId'),
      );
      if (response.statusCode == 404) {
        throw UniversityApiException('University not found');
      }
      if (response.statusCode != 200) {
        throw UniversityApiException('Failed to load university details');
      }
      final body = utf8.decode(response.bodyBytes);
      final value = University.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );
      await _writeCacheSafely(cacheKey, body);
      return value;
    });
  }

  Future<CachedUniversityValue<T>?> _readCached<T>(
    String key,
    T Function(String body) decode,
  ) async {
    try {
      final entry = await _cacheStore.read(key);
      if (entry == null) return null;
      try {
        return CachedUniversityValue(
          value: decode(entry.body),
          isFresh: entry.isFreshAt(_now()),
        );
      } catch (_) {
        await _cacheStore.remove(key);
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCacheSafely(String key, String body) async {
    try {
      await _cacheStore.write(
        key,
        UniversityCacheEntry(body: body, savedAt: _now().toUtc()),
      );
    } catch (_) {
      // A successful API response remains usable when persistence is unavailable.
    }
  }

  Future<T> _deduplicate<T>(String key, Future<T> Function() load) {
    final existing = _inFlight[key];
    if (existing != null) {
      return existing.then((value) => value as T);
    }

    final future = load();
    _inFlight[key] = future;
    return future.whenComplete(() {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
      }
    });
  }
}

class CachedUniversityValue<T> {
  const CachedUniversityValue({required this.value, required this.isFresh});

  final T value;
  final bool isFresh;
}

class UniversityApiException implements Exception {
  final String message;

  const UniversityApiException(this.message);

  @override
  String toString() => message;
}
