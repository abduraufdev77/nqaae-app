import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../universities/providers/university_providers.dart';
import '../../universities/widgets/nqaae_ui.dart';
import '../../universities/widgets/university_item.dart';
import '../widgets/dashboard_home_header.dart';
import '../widgets/dashboard_section_chips.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/institute_summary_card.dart';
import '../widgets/searchbar.dart';
import '../widgets/student_contingent_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final TabController _tabController;
  Timer? _searchDebounce;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: FloatingNavBar.defaultItems.length,
      vsync: this,
    );
    _tabController.addListener(_updateSelectedTab);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.removeListener(_updateSelectedTab);
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSelectedTab() {
    if (_tabController.index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = _tabController.index);
  }

  void _onNavTap(int index) {
    setState(() => _selectedTabIndex = index);
    _tabController.animateTo(index);
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

    return Scaffold(
      // backgroundColor: NqaaeColors.page,
      // extendBody: true,
      body: NqaaeBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DashboardHomeTab(
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onVoiceSearch: () {},
                  ),
                  _UniversitiesTab(
                    scrollController: _scrollController,
                    searchController: _searchController,
                    listState: listState,
                    onSearchChanged: _onSearchChanged,
                    onRefresh: () => ref
                        .read(universityListControllerProvider.notifier)
                        .refresh(search: _searchController.text),
                    onLogout: () => ref.read(authProvider.notifier).logout(),
                  ),
                  const _DashboardPlaceholderTab(
                    title: 'Reyting sahifasi',
                    icon: Iconsax.chart_2,
                  ),
                  const _DashboardPlaceholderTab(
                    title: 'Sozlamalar sahifasi',
                    icon: Iconsax.setting_2,
                  ),
                ],
              ),
            ),
            const Positioned(
              key: ValueKey('dashboard-bottom-shadow'),
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: IgnorePointer(child: _DashboardBottomShadow()),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                currentIndex: _selectedTabIndex,
                onTap: _onNavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHomeTab extends StatelessWidget {
  const _DashboardHomeTab({
    required this.searchController,
    required this.onSearchChanged,
    required this.onVoiceSearch,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoiceSearch;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 0),
            sliver: SliverToBoxAdapter(
              child: DashboardHomeHeader(
                searchController: searchController,
                onSearchChanged: onSearchChanged,
                onVoiceSearch: onVoiceSearch,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'DASHBOARD',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 0),
            sliver: const SliverToBoxAdapter(child: InstituteSummaryCard()),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 28, 0, 0),
            sliver: SliverToBoxAdapter(child: DashboardSectionChips()),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 142),
            sliver: SliverToBoxAdapter(child: StudentContingentSection()),
          ),
        ],
      ),
    );
  }
}

class _UniversitiesTab extends StatelessWidget {
  const _UniversitiesTab({
    required this.scrollController,
    required this.searchController,
    required this.listState,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onLogout,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final UniversityListState listState;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: DashboardSearchBar(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      onRefresh: onRefresh,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    tooltip: 'Logout',
                    icon: Iconsax.logout,
                    onPressed: onLogout,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'Universitetlar',
                action: listState.total == 0
                    ? 'Yuklanmoqda'
                    : '${listState.total} ta',
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
          else if (listState.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 128),
              sliver: SliverList.separated(
                itemCount:
                    listState.items.length + (listState.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= listState.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return UniversityItem(university: listState.items[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardPlaceholderTab extends StatelessWidget {
  const _DashboardPlaceholderTab({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 128),
        child: Center(
          child: GlassCard(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            blurStrength: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: NqaaeColors.gradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBottomShadow extends StatelessWidget {
  const _DashboardBottomShadow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const [0, 1],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          action,
          style: GoogleFonts.openSans(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
            const Icon(Iconsax.cloud_cross, color: AppColors.accent),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(color: NqaaeColors.muted),
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
        "Ma'lumot topilmadi",
        style: GoogleFonts.openSans(
          color: NqaaeColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
