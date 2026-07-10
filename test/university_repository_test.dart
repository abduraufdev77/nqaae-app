import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nqaae_app/features/universities/repositories/university_cache_store.dart';
import 'package:nqaae_app/features/universities/repositories/university_repository.dart';

class _MemoryUniversityCacheStore implements UniversityCacheStore {
  final entries = <String, UniversityCacheEntry>{};
  bool failWrites = false;

  @override
  Future<UniversityCacheEntry?> read(String key) async => entries[key];

  @override
  Future<void> remove(String key) async {
    entries.remove(key);
  }

  @override
  Future<void> write(String key, UniversityCacheEntry entry) async {
    if (failWrites) throw StateError('cache unavailable');
    entries[key] = entry;
  }
}

void main() {
  test('fetchUniversities sends search and paging query parameters', () async {
    Uri? requestedUri;
    final repository = UniversityRepository(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"items":[],"page":3,"page_size":12,"total":0,"pages":0}',
          200,
        );
      }),
    );

    await repository.fetchUniversities(
      search: 'samarqand',
      page: 3,
      pageSize: 12,
    );

    expect(requestedUri?.path, '/api/universities');
    expect(requestedUri?.queryParameters['search'], 'samarqand');
    expect(requestedUri?.queryParameters['page'], '3');
    expect(requestedUri?.queryParameters['page_size'], '12');
  });

  test('fresh university list cache is decoded without an HTTP call', () async {
    var calls = 0;
    final now = DateTime.utc(2026, 7, 10, 9);
    final store = _MemoryUniversityCacheStore();
    final repository = UniversityRepository(
      baseUrl: 'http://localhost:8000',
      cacheStore: store,
      now: () => now,
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 500);
      }),
    );
    await store.write(
      repository.listCacheKey(search: '', page: 1, pageSize: 20),
      UniversityCacheEntry(
        body: '{"items":[],"page":1,"page_size":20,"total":0,"pages":0}',
        savedAt: now.subtract(const Duration(hours: 2)),
      ),
    );

    final cached = await repository.readCachedUniversities();

    expect(cached?.isFresh, isTrue);
    expect(cached?.value.page, 1);
    expect(calls, 0);
  });

  test('university cache becomes stale at three hours', () async {
    final now = DateTime.utc(2026, 7, 10, 12);
    final store = _MemoryUniversityCacheStore();
    final repository = UniversityRepository(cacheStore: store, now: () => now);
    await store.write(
      repository.detailCacheKey(7),
      UniversityCacheEntry(
        body: '{"source_id":7,"name":"Stale university"}',
        savedAt: now.subtract(const Duration(hours: 3)),
      ),
    );

    final cached = await repository.readCachedUniversity(7);

    expect(cached?.value.name, 'Stale university');
    expect(cached?.isFresh, isFalse);
  });

  test('list cache keys normalize search and separate paging', () {
    final repository = UniversityRepository(
      cacheStore: _MemoryUniversityCacheStore(),
    );

    expect(
      repository.listCacheKey(search: ' TOSHKENT ', page: 1, pageSize: 20),
      repository.listCacheKey(search: 'toshkent', page: 1, pageSize: 20),
    );
    expect(
      repository.listCacheKey(search: 'toshkent', page: 1, pageSize: 20),
      isNot(repository.listCacheKey(search: 'toshkent', page: 2, pageSize: 20)),
    );
  });

  test('concurrent detail fetches share one HTTP request', () async {
    var calls = 0;
    final completer = Completer<http.Response>();
    final repository = UniversityRepository(
      baseUrl: 'http://localhost:8000',
      cacheStore: _MemoryUniversityCacheStore(),
      client: MockClient((_) {
        calls++;
        return completer.future;
      }),
    );

    final first = repository.fetchUniversity(7);
    final second = repository.fetchUniversity(7);
    completer.complete(
      http.Response('{"source_id":7,"name":"Shared request"}', 200),
    );

    final results = await Future.wait([first, second]);
    expect(results.map((item) => item.name), everyElement('Shared request'));
    expect(calls, 1);
  });

  test(
    'malformed university cache is removed and treated as missing',
    () async {
      final store = _MemoryUniversityCacheStore();
      final repository = UniversityRepository(cacheStore: store);
      final key = repository.detailCacheKey(7);
      await store.write(
        key,
        UniversityCacheEntry(body: '{broken', savedAt: DateTime.now()),
      );

      final cached = await repository.readCachedUniversity(7);

      expect(cached, isNull);
      expect(store.entries, isNot(contains(key)));
    },
  );

  test('cache write failure does not discard a successful response', () async {
    final store = _MemoryUniversityCacheStore()..failWrites = true;
    final repository = UniversityRepository(
      baseUrl: 'http://localhost:8000',
      cacheStore: store,
      client: MockClient(
        (_) async =>
            http.Response('{"source_id":8,"name":"Network value"}', 200),
      ),
    );

    final university = await repository.fetchUniversity(8);

    expect(university.name, 'Network value');
  });

  test(
    'successful fetch persists raw response with the current timestamp',
    () async {
      final now = DateTime.utc(2026, 7, 10, 14);
      final store = _MemoryUniversityCacheStore();
      final repository = UniversityRepository(
        baseUrl: 'http://localhost:8000',
        cacheStore: store,
        now: () => now,
        client: MockClient(
          (_) async => http.Response('{"source_id":9,"name":"Persisted"}', 200),
        ),
      );

      await repository.fetchUniversity(9);

      final stored = store.entries[repository.detailCacheKey(9)];
      expect(stored?.savedAt, now);
      expect(stored?.body, contains('Persisted'));
    },
  );
}
