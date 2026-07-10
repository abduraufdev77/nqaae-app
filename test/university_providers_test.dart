import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nqaae_app/features/universities/models/university.dart';
import 'package:nqaae_app/features/universities/providers/university_providers.dart';
import 'package:nqaae_app/features/universities/repositories/university_repository.dart';

UniversityListResponse _response(String name, {int page = 1, int total = 1}) {
  return UniversityListResponse(
    items: [University(sourceId: page, name: name)],
    page: page,
    pageSize: 20,
    total: total,
    pages: total == 0 ? 0 : 1,
  );
}

class _ControlledUniversityRepository extends UniversityRepository {
  _ControlledUniversityRepository({
    this.cachedList,
    this.cachedDetail,
    this.detailRefresh,
  });

  final CachedUniversityValue<UniversityListResponse>? cachedList;
  final CachedUniversityValue<University>? cachedDetail;
  final Future<University>? detailRefresh;
  int listFetches = 0;
  int detailFetches = 0;

  @override
  Future<CachedUniversityValue<UniversityListResponse>?>
  readCachedUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    return cachedList;
  }

  @override
  Future<CachedUniversityValue<University>?> readCachedUniversity(
    int sourceId,
  ) async {
    return cachedDetail;
  }

  @override
  Future<UniversityListResponse> fetchUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    listFetches++;
    return Future.value(_response('Network list', page: page));
  }

  @override
  Future<University> fetchUniversity(int sourceId) {
    detailFetches++;
    return detailRefresh ??
        Future.value(University(sourceId: sourceId, name: 'Network detail'));
  }
}

void main() {
  test('fresh cached list publishes without fetching', () async {
    final repository = _ControlledUniversityRepository(
      cachedList: CachedUniversityValue(
        value: _response('Cached list'),
        isFresh: true,
      ),
    );
    final container = ProviderContainer(
      overrides: [universityRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(universityListControllerProvider.notifier);
    await notifier.initialized;

    expect(
      container.read(universityListControllerProvider).items.single.name,
      'Cached list',
    );
    expect(repository.listFetches, 0);
  });

  test('stale cached detail stays visible during background refresh', () async {
    final refresh = Completer<University>();
    final repository = _ControlledUniversityRepository(
      cachedDetail: const CachedUniversityValue(
        value: University(sourceId: 1, name: 'Stale detail'),
        isFresh: false,
      ),
      detailRefresh: refresh.future,
    );
    final container = ProviderContainer(
      overrides: [universityRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      universityDetailProvider(1),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(universityDetailProvider(1)).value?.name,
      'Stale detail',
    );
    expect(repository.detailFetches, 1);

    refresh.complete(const University(sourceId: 1, name: 'Fresh detail'));
    await refresh.future;
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(universityDetailProvider(1)).value?.name,
      'Fresh detail',
    );
  });

  test('failed stale detail refresh preserves cached data', () async {
    final refresh = Completer<University>();
    final repository = _ControlledUniversityRepository(
      cachedDetail: const CachedUniversityValue(
        value: University(sourceId: 2, name: 'Offline detail'),
        isFresh: false,
      ),
      detailRefresh: refresh.future,
    );
    final container = ProviderContainer(
      overrides: [universityRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      universityDetailProvider(2),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    refresh.completeError(StateError('offline'));
    await refresh.future.catchError(
      (_) => const University(sourceId: 2, name: 'ignored'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(universityDetailProvider(2)).value?.name,
      'Offline detail',
    );
  });
}
