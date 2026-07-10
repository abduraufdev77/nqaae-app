import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/university.dart';
import '../repositories/university_repository.dart';

final universityRepositoryProvider = Provider<UniversityRepository>(
  (ref) => UniversityRepository(),
);

final selectedUniversityIdProvider = StateProvider<int?>((ref) => null);

final universityListProvider = FutureProvider<UniversityListResponse>((ref) {
  return ref.watch(universityRepositoryProvider).fetchUniversities();
});

final universityListControllerProvider =
    StateNotifierProvider<UniversityListNotifier, UniversityListState>((ref) {
      return UniversityListNotifier(ref.watch(universityRepositoryProvider));
    });

final universityDetailProvider =
    StateNotifierProvider.family<
      UniversityDetailNotifier,
      AsyncValue<University>,
      int
    >((ref, sourceId) {
      return UniversityDetailNotifier(
        ref.watch(universityRepositoryProvider),
        sourceId,
      );
    });

class UniversityListState {
  final List<University> items;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String search;
  final String? error;

  const UniversityListState({
    this.items = const [],
    this.page = 0,
    this.pageSize = 20,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.search = '',
    this.error,
  });

  bool get hasMore => items.length < total || total == 0 && page == 0;

  UniversityListState copyWith({
    List<University>? items,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? search,
    String? error,
  }) {
    return UniversityListState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      error: error,
    );
  }
}

class UniversityListNotifier extends StateNotifier<UniversityListState> {
  UniversityListNotifier(this._repository)
    : super(const UniversityListState()) {
    initialized = _loadQuery('');
  }

  final UniversityRepository _repository;
  late final Future<void> initialized;
  int _requestSerial = 0;
  final Map<int, UniversityListResponse> _pages = {};

  Future<void> refresh({String? search}) async {
    final nextSearch = (search ?? state.search).trim();
    if (search != null &&
        _normalizeSearch(nextSearch) != _normalizeSearch(state.search)) {
      return _loadQuery(nextSearch);
    }

    await _fetchPage(
      page: 1,
      serial: _requestSerial,
      preserveItems: state.items.isNotEmpty,
    );
  }

  Future<void> _loadQuery(String search) async {
    final serial = ++_requestSerial;
    _pages.clear();
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      search: search,
      isLoading: true,
      isLoadingMore: false,
      error: null,
    );

    final cached = await _repository.readCachedUniversities(
      search: search,
      page: 1,
      pageSize: state.pageSize,
    );
    if (serial != _requestSerial) return;

    if (cached != null) {
      _pages[1] = cached.value;
      _publishPages(isLoading: false);
      if (cached.isFresh) return;
      unawaited(_fetchPage(page: 1, serial: serial, preserveItems: true));
      return;
    }

    await _fetchPage(page: 1, serial: serial, preserveItems: false);
  }

  Future<void> _fetchPage({
    required int page,
    required int serial,
    required bool preserveItems,
  }) async {
    final isFirstPage = page == 1;
    if (isFirstPage) {
      state = state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        error: null,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final response = await _repository.fetchUniversities(
        search: state.search,
        page: page,
        pageSize: state.pageSize,
      );
      if (serial != _requestSerial) return;
      _pages[response.page] = response;
      _publishPages(isLoading: false, isLoadingMore: false);
    } catch (error) {
      if (serial != _requestSerial) return;
      if (!preserveItems && state.items.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: error.toString(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: null,
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);
    final serial = _requestSerial;
    final cached = await _repository.readCachedUniversities(
      search: state.search,
      page: nextPage,
      pageSize: state.pageSize,
    );
    if (serial != _requestSerial) return;

    if (cached != null) {
      _pages[nextPage] = cached.value;
      _publishPages(isLoadingMore: false);
      if (cached.isFresh) return;
      unawaited(
        _fetchPage(page: nextPage, serial: serial, preserveItems: true),
      );
      return;
    }

    await _fetchPage(
      page: nextPage,
      serial: serial,
      preserveItems: state.items.isNotEmpty,
    );
  }

  void _publishPages({bool? isLoading, bool? isLoadingMore}) {
    final pageNumbers = _pages.keys.toList()..sort();
    final items = <University>[
      for (final page in pageNumbers) ..._pages[page]!.items,
    ];
    final lastPage = pageNumbers.isEmpty ? 0 : pageNumbers.last;
    final total = pageNumbers.isEmpty ? 0 : _pages[pageNumbers.first]!.total;
    state = state.copyWith(
      items: items,
      page: lastPage,
      total: total,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      error: null,
    );
  }

  String _normalizeSearch(String value) => value.trim().toLowerCase();
}

class UniversityDetailNotifier extends StateNotifier<AsyncValue<University>> {
  UniversityDetailNotifier(this._repository, this._sourceId)
    : super(const AsyncLoading()) {
    unawaited(_initialize());
  }

  final UniversityRepository _repository;
  final int _sourceId;

  Future<void> _initialize() async {
    final cached = await _repository.readCachedUniversity(_sourceId);
    if (cached != null) {
      state = AsyncData(cached.value);
      if (cached.isFresh) return;
    }
    await _refresh(preserveValue: cached != null);
  }

  Future<void> refresh() {
    return _refresh(preserveValue: state is AsyncData<University>);
  }

  Future<void> _refresh({required bool preserveValue}) async {
    if (!preserveValue) {
      state = const AsyncLoading();
    }
    try {
      state = AsyncData(await _repository.fetchUniversity(_sourceId));
    } catch (error, stackTrace) {
      if (!preserveValue) {
        state = AsyncError(error, stackTrace);
      }
    }
  }
}
