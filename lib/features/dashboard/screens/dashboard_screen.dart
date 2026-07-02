import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/providers/auth_provider.dart';
import '../../universities/models/university.dart';
import '../../universities/providers/university_providers.dart';
import '../../universities/widgets/nqaae_ui.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 360) {
      ref.read(universityListControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(universityListControllerProvider.notifier)
          .refresh(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(universityListControllerProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: NqaaeColors.page,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _Header(authState: authState)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _SearchSection(
                  controller: _searchController,
                  total: listState.total,
                  onChanged: _onSearchChanged,
                  onRefresh: () => ref
                      .read(universityListControllerProvider.notifier)
                      .refresh(search: _searchController.text),
                ),
              ),
            ),
            if (listState.isLoading && listState.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (listState.error != null && listState.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(message: listState.error!),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList.separated(
                  itemCount:
                      listState.items.length +
                      (listState.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >= listState.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _UniversityListItem(
                      university: listState.items[index],
                    );
                  },
                ),
              ),
            if (!listState.isLoading &&
                listState.items.isEmpty &&
                listState.error == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: NqaaeColors.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ta'lim sifatini ta'minlash milliy agentligi",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: NqaaeColors.text,
                    height: 1.18,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded, color: NqaaeColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Ochiq ma'lumotlar / Ta'lim tashkilotlari ro'yxati",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: NqaaeColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Oliy ta'lim tashkilotlari",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: NqaaeColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.total,
    required this.onChanged,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final int total;
  final ValueChanged<String> onChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return NqaaeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Izlash',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
              filled: true,
              fillColor: NqaaeColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: NqaaeColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: NqaaeColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: NqaaeColors.teal),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            total == 0 ? 'Maʼlumotlar yuklanmoqda' : '$total ta tashkilot',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: NqaaeColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UniversityListItem extends StatelessWidget {
  const _UniversityListItem({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/universities/${university.sourceId}'),
      child: NqaaeSection(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            NqaaeLogo(
              sourceId: university.sourceId,
              hasLogo: university.logoUrl != null,
              fallback: university.name,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                university.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.25,
                  color: NqaaeColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: NqaaeColors.muted),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: NqaaeSection(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: NqaaeColors.teal),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: NqaaeColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Maʼlumot topilmadi',
        style: GoogleFonts.inter(
          color: NqaaeColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
