# University Data and Logo Cache Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist university lists, details, and logos for three hours so navigation and app restarts reuse fetched data while expired data remains available during background refreshes.

**Architecture:** A feature-scoped `UniversityCacheStore` persists raw JSON and timestamps through `SharedPreferences`; `UniversityRepository` owns key generation, parsing, writes, and in-flight request deduplication. Riverpod notifiers publish fresh or stale cache values before deciding whether to fetch, while one shared `CacheManager` backs every university logo widget.

**Tech Stack:** Flutter, Dart, Riverpod 2, `http`, `shared_preferences`, `cached_network_image`, `flutter_cache_manager`, `flutter_test`.

## Global Constraints

- Cache freshness is exactly three hours from the last successful network response.
- Fresh entries must return without a network request.
- Expired entries must render immediately and refresh in the background.
- Failed refreshes must preserve stale data and retry on later access or explicit refresh.
- List cache keys must separate normalized search text, page, and page size.
- Detail cache keys must use the university source ID.
- Explicit refresh must bypass freshness while preserving same-query visible data.
- Concurrent requests for the same resource must share one network request.
- Cache corruption and cache-write failure must not prevent a network response from rendering.
- Every fetched list page must be cached independently.

---

## File structure

- Create `lib/features/universities/repositories/university_cache_store.dart`: cache entry model, storage interface, and `SharedPreferences` implementation.
- Modify `lib/features/universities/repositories/university_repository.dart`: cache reads, writes, deterministic keys, injected clock, and request deduplication.
- Modify `lib/features/universities/providers/university_providers.dart`: cache-first list/detail controllers with stale-while-revalidate state transitions.
- Create `lib/features/universities/widgets/university_logo_image.dart`: shared persistent image cache and reusable network-logo widget.
- Modify `lib/features/universities/widgets/nqaae_ui.dart`: replace per-build raw logo HTTP futures.
- Modify `lib/features/dashboard/screens/dashboard_screen.dart`: stop forced navigation refetch and use the shared cached header logo.
- Modify `pubspec.yaml` and `pubspec.lock`: add persistent network-image cache packages.
- Modify `test/university_repository_test.dart`: repository cache, TTL, corruption, failure, keying, and deduplication coverage.
- Create `test/university_providers_test.dart`: list/detail provider stale-while-revalidate coverage.
- Modify `test/widget_test.dart`: navigation and logo-widget regression coverage.

### Task 1: Persist and read university API responses

**Files:**
- Create: `lib/features/universities/repositories/university_cache_store.dart`
- Modify: `lib/features/universities/repositories/university_repository.dart`
- Modify: `test/university_repository_test.dart`

**Interfaces:**
- Produces `UniversityCacheEntry(body: String, savedAt: DateTime)` with `isFreshAt(DateTime now)`.
- Produces `UniversityCacheStore.read/write/remove` and `SharedPreferencesUniversityCacheStore`.
- Produces `CachedUniversityValue<T>(value: T, isFresh: bool)`.
- Produces `UniversityRepository.readCachedUniversities`, `readCachedUniversity`, `fetchUniversities`, and `fetchUniversity`.

- [ ] **Step 1: Write failing cache-store and repository tests**

Add an in-memory `UniversityCacheStore` fake and an injected `DateTime now`. Test these concrete behaviors:

```dart
test('fresh list cache is decoded without an HTTP call', () async {
  var calls = 0;
  final store = _MemoryUniversityCacheStore();
  final now = DateTime.utc(2026, 7, 10, 9);
  final repository = UniversityRepository(
    baseUrl: 'http://localhost:8000',
    now: () => now,
    cacheStore: store,
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

test('three-hour-old cache is stale but remains readable', () async {
  // Store at now - const Duration(hours: 3), then expect isFresh == false.
});

test('list cache keys separate normalized query and paging', () {
  expect(repository.listCacheKey(search: ' TOSHKENT ', page: 1, pageSize: 20),
      repository.listCacheKey(search: 'toshkent', page: 1, pageSize: 20));
  expect(repository.listCacheKey(search: 'toshkent', page: 1, pageSize: 20),
      isNot(repository.listCacheKey(search: 'toshkent', page: 2, pageSize: 20)));
});

test('concurrent detail fetches share one request', () async {
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
  completer.complete(http.Response('{"source_id":7,"name":"Cached"}', 200));
  expect((await Future.wait([first, second])).map((item) => item.name),
      everyElement('Cached'));
  expect(calls, 1);
});
```

Also add focused tests for detail cache decoding, malformed-cache removal, a successful response being returned despite cache-write failure, and a network refresh replacing the timestamp/body.

- [ ] **Step 2: Run repository tests and confirm RED**

Run: `flutter test test/university_repository_test.dart`

Expected: FAIL because `UniversityCacheStore`, `UniversityCacheEntry`, cache-aware repository constructor arguments, and cache-read methods do not exist.

- [ ] **Step 3: Implement the cache store**

In `university_cache_store.dart`, add:

```dart
const universityCacheTtl = Duration(hours: 3);

class UniversityCacheEntry {
  const UniversityCacheEntry({required this.body, required this.savedAt});
  final String body;
  final DateTime savedAt;

  bool isFreshAt(DateTime now) => now.difference(savedAt) < universityCacheTtl;
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
    await preferences.setString(key, jsonEncode({
      'body': entry.body,
      'saved_at_ms': entry.savedAt.toUtc().millisecondsSinceEpoch,
    }));
  }

  @override
  Future<void> remove(String key) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }
}
```

- [ ] **Step 4: Make the repository cache-aware and deduplicate requests**

Add optional `UniversityCacheStore? cacheStore` and `DateTime Function()? now` constructor parameters. Generate versioned keys with a base64url-encoded canonical query. Cache raw UTF-8 JSON only after successful parsing. Cache operations are wrapped so storage failure is non-fatal. Implement one `_inFlight` map and a typed `_deduplicate<T>` helper whose `finally` removes only the identical future. Preserve the public fetch signatures so existing test repositories remain valid.

```dart
class CachedUniversityValue<T> {
  const CachedUniversityValue({required this.value, required this.isFresh});
  final T value;
  final bool isFresh;
}

Future<CachedUniversityValue<UniversityListResponse>?> readCachedUniversities({
  String? search,
  int page = 1,
  int pageSize = 20,
}) => _readCached(
  listCacheKey(search: search, page: page, pageSize: pageSize),
  (body) => UniversityListResponse.fromJson(jsonDecode(body)),
);

Future<CachedUniversityValue<University>?> readCachedUniversity(int sourceId) =>
    _readCached(detailCacheKey(sourceId),
        (body) => University.fromJson(jsonDecode(body)));
```

- [ ] **Step 5: Run repository tests and confirm GREEN**

Run: `flutter test test/university_repository_test.dart`

Expected: all repository cache tests pass with zero failures.

- [ ] **Step 6: Commit Task 1**

```bash
git add lib/features/universities/repositories/university_cache_store.dart lib/features/universities/repositories/university_repository.dart test/university_repository_test.dart
git commit -m "feat: persist university API responses"
```

### Task 2: Publish cached list and detail data before refreshing

**Files:**
- Modify: `lib/features/universities/providers/university_providers.dart`
- Create: `test/university_providers_test.dart`

**Interfaces:**
- Consumes repository cache-read and network-fetch methods from Task 1.
- Preserves `universityListControllerProvider` state and `universityDetailProvider(id)` as `AsyncValue<University>`.
- Produces cache-first initialization, query switching, pagination, explicit refresh, and stale background refresh.

- [ ] **Step 1: Write failing provider tests**

Use a controllable fake repository that overrides cache-read and fetch methods. Cover:

```dart
test('fresh cached list publishes without fetching', () async {
  final repository = _ControlledUniversityRepository(
    cachedList: CachedUniversityValue(
      value: responseNamed('Cached list'),
      isFresh: true,
    ),
  );
  final container = ProviderContainer(overrides: [
    universityRepositoryProvider.overrideWithValue(repository),
  ]);
  addTearDown(container.dispose);
  await container.read(universityListControllerProvider.notifier).initialized;
  expect(container.read(universityListControllerProvider).items.single.name,
      'Cached list');
  expect(repository.listFetches, 0);
});

test('stale detail stays visible until background refresh completes', () async {
  final refresh = Completer<University>();
  final repository = _ControlledUniversityRepository(
    cachedDetail: const CachedUniversityValue(
      value: University(sourceId: 1, name: 'Stale detail'),
      isFresh: false,
    ),
    detailRefresh: refresh.future,
  );
  final container = ProviderContainer(overrides: [
    universityRepositoryProvider.overrideWithValue(repository),
  ]);
  addTearDown(container.dispose);
  container.listen(universityDetailProvider(1), (_, __) {}, fireImmediately: true);
  await repository.cacheReadCompleted.future;
  expect(container.read(universityDetailProvider(1)).value?.name, 'Stale detail');
  refresh.complete(const University(sourceId: 1, name: 'Fresh detail'));
  await Future<void>.delayed(Duration.zero);
  expect(container.read(universityDetailProvider(1)).value?.name, 'Fresh detail');
});
```

Add tests for stale-refresh failure preserving data, missing-cache initial errors, explicit refresh bypass, search cache isolation, and cached next-page append.

- [ ] **Step 2: Run provider tests and confirm RED**

Run: `flutter test test/university_providers_test.dart`

Expected: FAIL because the current providers always fetch and the detail provider cannot publish stale data before refresh.

- [ ] **Step 3: Implement cache-first list state**

Give `UniversityListNotifier` an `initialized` future completed after its first cache/network decision. Maintain a request serial and page-response map for the active normalized query. `refresh(search: value)` treats a changed query as cache-first navigation; the same query is an explicit network refresh that preserves current items. `loadMore` reads the next page cache first, publishes it, and refreshes it only when stale. Network failures set `error` only when no visible items exist.

- [ ] **Step 4: Replace the detail FutureProvider with a family notifier**

```dart
final universityDetailProvider = StateNotifierProvider.family<
    UniversityDetailNotifier, AsyncValue<University>, int>((ref, sourceId) {
  return UniversityDetailNotifier(
    ref.watch(universityRepositoryProvider),
    sourceId,
  );
});

class UniversityDetailNotifier extends StateNotifier<AsyncValue<University>> {
  UniversityDetailNotifier(this._repository, this._sourceId)
      : super(const AsyncLoading()) {
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final cached = await _repository.readCachedUniversity(_sourceId);
    if (cached != null) {
      state = AsyncData(cached.value);
      if (cached.isFresh) return;
    }
    await _refresh(preserveValue: cached != null);
  }

  Future<void> refresh() => _refresh(preserveValue: state is AsyncData<University>);
}
```

In `_refresh`, publish `AsyncLoading` only without a visible value; replace state on success; on error publish `AsyncError` only without a visible value.

- [ ] **Step 5: Run provider tests and confirm GREEN**

Run: `flutter test test/university_providers_test.dart`

Expected: all provider tests pass with zero failures.

- [ ] **Step 6: Commit Task 2**

```bash
git add lib/features/universities/providers/university_providers.dart test/university_providers_test.dart
git commit -m "feat: restore cached university state"
```

### Task 3: Stop navigation-triggered list reloads

**Files:**
- Modify: `lib/features/dashboard/screens/dashboard_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes cache-first `UniversityListNotifier.refresh(search:)` from Task 2.
- Produces screen changes that reset the visible query through cache without forcing a network request.

- [ ] **Step 1: Write a failing navigation regression test**

Add a counting fake repository, open Universities, return to Dashboard, open Universities again, and assert the empty-query network fetch count stays at one while the original item remains visible.

```dart
expect(repository.listFetches, 1);
await tester.tap(find.byKey(const ValueKey('universities-header-back')));
await tester.pumpAndSettle();
await tester.tap(find.byTooltip('Universitetlar'));
await tester.pumpAndSettle();
expect(repository.listFetches, 1);
expect(find.text('Cached navigation university'), findsOneWidget);
```

- [ ] **Step 2: Run the focused widget test and confirm RED**

Run: `flutter test test/widget_test.dart --plain-name "University navigation reuses the loaded list"`

Expected: FAIL because `_onNavTap` explicitly refreshes the empty-query list when leaving the Universities tab.

- [ ] **Step 3: Remove the forced refresh**

Delete the `_onNavTap` branch that calls `refresh(search: '')`. Keep query clearing scoped to selection/navigation, and call the cache-first query-switch path only when the active list query actually needs resetting. Do not invalidate either university provider.

- [ ] **Step 4: Run the focused test and confirm GREEN**

Run: `flutter test test/widget_test.dart --plain-name "University navigation reuses the loaded list"`

Expected: PASS with one list fetch.

- [ ] **Step 5: Commit Task 3**

```bash
git add lib/features/dashboard/screens/dashboard_screen.dart test/widget_test.dart
git commit -m "fix: reuse university list across navigation"
```

### Task 4: Persist and reuse university logos

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `lib/features/universities/widgets/university_logo_image.dart`
- Modify: `lib/features/universities/widgets/nqaae_ui.dart`
- Modify: `lib/features/dashboard/screens/dashboard_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Produces singleton `universityLogoCacheManager` with a three-hour stale period.
- Produces `UniversityLogoImage(imageUrl, fallback, fit, width, height)` using the singleton.
- `NqaaeLogo` continues to consume `sourceId`, `hasLogo`, `fallback`, and `size`.

- [ ] **Step 1: Add dependencies**

Run: `flutter pub add cached_network_image flutter_cache_manager`

Expected: `pubspec.yaml` and `pubspec.lock` include both packages with versions compatible with the current Flutter SDK.

- [ ] **Step 2: Write the failing logo-widget test**

```dart
testWidgets('NqaaeLogo uses the shared persistent image cache', (tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: NqaaeLogo(sourceId: 42, hasLogo: true, fallback: 'Cached'),
  ));
  final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
  expect(image.cacheManager, same(universityLogoCacheManager));
  expect(image.imageUrl,
      '${ApiConfig.baseUrl}/api/universities/42/logo');
  expect(find.byType(FutureBuilder<Uint8List>), findsNothing);
});
```

Add a selected-dashboard test asserting its header also contains `UniversityLogoImage` when `logoUrl` exists.

- [ ] **Step 3: Run the focused logo tests and confirm RED**

Run: `flutter test test/widget_test.dart --plain-name "NqaaeLogo uses the shared persistent image cache"`

Expected: FAIL because `CachedNetworkImage`, `UniversityLogoImage`, and `universityLogoCacheManager` are not present.

- [ ] **Step 4: Implement one shared logo cache**

```dart
final BaseCacheManager universityLogoCacheManager = CacheManager(
  Config(
    'nqaaeUniversityLogosV1',
    stalePeriod: universityCacheTtl,
    maxNrOfCacheObjects: 300,
  ),
);

class UniversityLogoImage extends StatelessWidget {
  const UniversityLogoImage({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });
  final String imageUrl;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: imageUrl,
    cacheManager: universityLogoCacheManager,
    fit: fit,
    width: width,
    height: height,
    placeholder: (_, __) => fallback,
    errorWidget: (_, __, ___) => fallback,
  );
}
```

Use this widget in `NqaaeLogo` and the dashboard header. Remove `dart:typed_data`, direct `http` imports, `_loadLogo`, `FutureBuilder`, and the direct header `Image.network`.

- [ ] **Step 5: Run focused tests and confirm GREEN**

Run: `flutter test test/widget_test.dart --plain-name "NqaaeLogo uses the shared persistent image cache"`

Expected: PASS with the singleton cache manager attached.

- [ ] **Step 6: Commit Task 4**

```bash
git add pubspec.yaml pubspec.lock lib/features/universities/widgets/university_logo_image.dart lib/features/universities/widgets/nqaae_ui.dart lib/features/dashboard/screens/dashboard_screen.dart test/widget_test.dart
git commit -m "feat: persist university logo images"
```

### Task 5: Normalize invalid university student values

**Files:**
- Modify: `lib/features/universities/models/university.dart`
- Modify: `test/university_model_test.dart`
- Modify: `test/widget_test.dart`

**Interfaces:** Extends `isDisplayableSourceValue` so spreadsheet error tokens are treated as missing and existing university-dashboard fallbacks render `0`.

- [ ] **Step 1: Add a failing source-value test**

Assert `#VALUE!`, `#N/A`, `#REF!`, and `#DIV/0!` are not displayable.

- [ ] **Step 2: Verify RED**

Run: `flutter test test/university_model_test.dart --plain-name "spreadsheet error tokens are not displayable source values"`

Expected: FAIL because the tokens currently pass validation.

- [ ] **Step 3: Reject spreadsheet errors at the shared validator**

Match the complete normalized token against Excel error forms before the existing placeholder checks.

- [ ] **Step 4: Add and run the details-dashboard regression**

Run: `flutter test test/widget_test.dart --plain-name "University student totals render invalid source values as zero"`

Expected: PASS with total and all invalid/null breakdown segments equal to `0`.

### Task 6: Verify the complete cache behavior

**Files:**
- Modify only files needed to fix failures directly caused by Tasks 1–4.

**Interfaces:** Consumes every prior task; produces a statically clean, fully tested app.

- [ ] **Step 1: Format changed Dart files**

Run: `dart format lib/features/universities/repositories/university_cache_store.dart lib/features/universities/repositories/university_repository.dart lib/features/universities/providers/university_providers.dart lib/features/universities/widgets/university_logo_image.dart lib/features/universities/widgets/nqaae_ui.dart lib/features/dashboard/screens/dashboard_screen.dart test/university_repository_test.dart test/university_providers_test.dart test/widget_test.dart`

Expected: formatter exits 0.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`

Expected: exit 0 with no issues.

- [ ] **Step 3: Run the complete test suite**

Run: `flutter test`

Expected: exit 0 with all tests passing.

- [ ] **Step 4: Inspect final scope**

Run: `git status --short && git diff --check && git log -5 --oneline`

Expected: no whitespace errors; only the plan or any intentional uncommitted verification adjustment remains.

- [ ] **Step 5: Commit final verification adjustments if any**

```bash
git add <only-files-changed-to-fix-verification>
git commit -m "test: verify university cache behavior"
```
