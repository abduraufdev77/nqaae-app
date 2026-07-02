import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/university.dart';
import '../repositories/university_repository.dart';

final universityRepositoryProvider = Provider<UniversityRepository>(
  (ref) => UniversityRepository(),
);

final universityListProvider = FutureProvider<UniversityListResponse>((ref) {
  return ref.watch(universityRepositoryProvider).fetchUniversities();
});

final universityListControllerProvider =
    StateNotifierProvider<UniversityListNotifier, UniversityListState>((ref) {
      return UniversityListNotifier(ref.watch(universityRepositoryProvider));
    });

final universityDetailProvider = FutureProvider.family<University, int>((
  ref,
  sourceId,
) {
  return ref.watch(universityRepositoryProvider).fetchUniversity(sourceId);
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
    refresh();
  }

  final UniversityRepository _repository;
  int _requestSerial = 0;

  Future<void> refresh({String? search}) async {
    final nextSearch = search ?? state.search;
    final serial = ++_requestSerial;
    state = state.copyWith(
      items: const [],
      page: 0,
      total: 0,
      search: nextSearch,
      isLoading: true,
      isLoadingMore: false,
      error: null,
    );

    try {
      final response = await _repository.fetchUniversities(
        search: nextSearch,
        page: 1,
        pageSize: state.pageSize,
      );
      if (serial != _requestSerial) return;
      state = state.copyWith(
        items: response.items,
        page: response.page,
        total: response.total,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      if (serial != _requestSerial) return;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final response = await _repository.fetchUniversities(
        search: state.search,
        page: nextPage,
        pageSize: state.pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...response.items],
        page: response.page,
        total: response.total,
        isLoadingMore: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }
}
