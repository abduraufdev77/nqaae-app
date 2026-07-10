import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:nqaae_app/features/dashboard/widgets/accreditation_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/national_rating_section.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_design.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_silver_box.dart';
import '../../../shared/widgets/app_header_controls.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/layout/floating_navbar.dart';
import '../../../shared/widgets/searchbar.dart';
import '../../universities/providers/university_providers.dart';
import '../../universities/models/university.dart';
import '../../universities/widgets/nqaae_ui.dart';
import '../../universities/widgets/university_item_card.dart';
import '../../universities/widgets/university_logo_image.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/institute_summary_card.dart';
import '../widgets/professors_composition_section.dart';
import '../widgets/scientific_potential_section.dart';
import '../widgets/total_students_section.dart';
import '../widgets/specialization_section.dart';
import '../widgets/student_contingent_section.dart';
import '../widgets/types_of_education_section.dart';
import '../widgets/survey_results_section.dart';
import '../widgets/international_activity_section.dart';
import '../widgets/buildings_facilities_section.dart';
import '../widgets/university_dashboard_content.dart';

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
    if (_selectedTabIndex != index) {
      _searchDebounce?.cancel();
      _searchController.clear();
      if (_selectedTabIndex == 1 &&
          ref.read(universityListControllerProvider).search.isNotEmpty) {
        ref.read(universityListControllerProvider.notifier).refresh(search: '');
      }
    }
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

  void _selectUniversity(University university) {
    ref.read(selectedUniversityIdProvider.notifier).state = university.sourceId;
    _onNavTap(0);
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(universityListControllerProvider);
    final selectedUniversityId = ref.watch(selectedUniversityIdProvider);
    final selectedUniversity = selectedUniversityId == null
        ? null
        : ref.watch(universityDetailProvider(selectedUniversityId));

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
                    selectedUniversity: selectedUniversity,
                  ),
                  _UniversitiesTab(
                    scrollController: _scrollController,
                    searchController: _searchController,
                    listState: listState,
                    onSearchChanged: _onSearchChanged,
                    onRefresh: () => ref
                        .read(universityListControllerProvider.notifier)
                        .refresh(search: _searchController.text),
                    onBack: () => _onNavTap(0),
                    onUniversityTap: _selectUniversity,
                  ),
                  const _DashboardPlaceholderTab(
                    title: 'Reyting sahifasi',
                    icon: Iconsax.chart_2,
                  ),
                  SettingsScreen(
                    searchController: _searchController,
                    onSearchChanged: (_) {},
                    onVoiceSearch: () {},
                    onBack: () => _onNavTap(0),
                    onProfileTap: () => context.push('/profile'),
                    onLogout: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
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
              child: IgnorePointer(
                ignoring: _selectedTabIndex == 1 || _selectedTabIndex == 3,
                child: AnimatedSlide(
                  key: const ValueKey('dashboard-floating-nav-shell'),
                  offset: _selectedTabIndex == 1 || _selectedTabIndex == 3
                      ? const Offset(0, 1.35)
                      : Offset.zero,
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity: _selectedTabIndex == 1 || _selectedTabIndex == 3
                        ? 0
                        : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: FloatingNavBar(
                      currentIndex: _selectedTabIndex,
                      onTap: _onNavTap,
                    ),
                  ),
                ),
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
    required this.selectedUniversity,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoiceSearch;
  final AsyncValue<University>? selectedUniversity;

  @override
  Widget build(BuildContext context) {
    final detailState = selectedUniversity;
    final selectedDetail = detailState is AsyncData<University>
        ? detailState.value
        : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        AppScreenHeader(
          contentHeight: 72,
          shadowKey: const ValueKey('dashboard-home-top-shadow'),
          leading: Container(
            key: const ValueKey('dashboard-header-logo'),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            child: ClipRRect(
              key: const ValueKey('dashboard-header-logo-clip'),
              borderRadius: BorderRadius.circular(99),
              child: selectedDetail?.logoUrl != null
                  ? UniversityLogoImage(
                      imageUrl: selectedDetail!.logoUrl!,
                      fallback: Image.asset(
                        'assets/images/university-logo.png',
                        fit: BoxFit.contain,
                      ),
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      'assets/images/university-logo.png',
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          center: DashboardSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onRefresh: onVoiceSearch,
          ),
          trailing: GlassButton(
            key: const ValueKey('dashboard-header-notifications'),
            tooltip: 'Notifications',
            assetName: 'assets/icons/bell.svg',
            onPressed: null,
            width: AppDesign.screenHeaderControlHeight,
            height: AppDesign.screenHeaderControlHeight,
            iconSize: 20,
          ),
        ),

        AppSliverBox(
          left: AppDesign.screenHorizontalPadding,
          right: AppDesign.screenHorizontalPadding,
          top: AppDesign.sectionTopGap,
          child: Text(
            'DASHBOARD',
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),

        if (selectedUniversity != null)
          selectedUniversity!.when(
            data: (university) => AppSliverBox(
              left: AppDesign.screenHorizontalPadding,
              right: AppDesign.screenHorizontalPadding,
              top: 24,
              bottom: 130,
              child: UniversityDashboardContent(university: university),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(message: error.toString()),
            ),
          )
        else ...[
          const AppSliverBox(
            left: AppDesign.screenHorizontalPadding,
            right: AppDesign.screenHorizontalPadding,
            top: 24,
            child: InstituteSummaryCard(),
          ),
          const AppSliverBox(
            left: AppDesign.screenHorizontalPadding,
            right: AppDesign.screenHorizontalPadding,
            top: AppDesign.sectionTopGap,
            bottom: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TotalStudentsSection(),

                SizedBox(height: 56),

                SpecializationSection(),

                SizedBox(height: 56),

                TypesOfEducationSection(),

                SizedBox(height: 56),

                StudentContingentSection(),

                SizedBox(height: 56),

                ProfessorsCompositionSection(),

                SizedBox(height: 56),

                ScientificPotentialSection(),

                SizedBox(height: 56),

                SurveyResultsSection(),

                SizedBox(height: 56),

                InternationalActivitySection(),

                SizedBox(height: 56),

                BuildingsFacilitiesSection(),

                SizedBox(height: 56),

                AccreditationSection(),

                SizedBox(height: 56),

                NationalRatingSection(
                  metrics: [
                    NationalRatingMetric(
                      value: '36',
                      label: 'Milliy reytingdagi o‘rni',
                      assetName: 'assets/icons/bachelor.svg',
                      gradient: AppColors.blueGradient,
                      // onTap: () {
                      //   // context.push('/national-rating/place');
                      // },
                    ),
                    NationalRatingMetric(
                      value: '467',
                      label: 'Umumiy ballar',
                      assetName: 'assets/icons/master.svg',
                      gradient: AppColors.accentGradient,
                    ),
                  ],
                ),

                // completed complex accreditation sample usage with values->
                // AccreditationSection(
                //   items: [
                //     AccreditationItem(
                //       type: AccreditationType.complexStateAccreditation,
                //       status: AccreditationStatus.completed,
                //       certificateNumber: 'AA-2026-001',
                //       givenDate: '12.12.2026',
                //       validUntil: '12.12.2031',
                //       // onCertificateDownload: () {
                //       //   // download certificate
                //       // },
                //     ),
                //     AccreditationItem(
                //       type: AccreditationType.specialStateAccreditation,
                //       status: AccreditationStatus.pending,
                //       accreditedProgramsCount: '0',
                //     ),
                //     AccreditationItem(
                //       type: AccreditationType.internationalAccreditation,
                //       status: AccreditationStatus.pending,
                //       accreditedProgramsCount: '0',
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        ],
      ],
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
    required this.onBack,
    required this.onUniversityTap,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final UniversityListState listState;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final ValueChanged<University> onUniversityTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        AppScreenHeader(
          shadowKey: const ValueKey('universities-header-shadow'),
          center: AppHeaderControls(
            backKey: const ValueKey('universities-header-back'),
            searchShellKey: const ValueKey('universities-search-shell'),
            notificationsKey: const ValueKey(
              'universities-header-notifications',
            ),
            searchController: searchController,
            onSearchChanged: onSearchChanged,
            onVoiceSearch: onRefresh,
            onBack: onBack,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDesign.screenHorizontalPadding,
            AppDesign.screenTitleTopGap,
            AppDesign.screenHorizontalPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'UNIVERSITIES',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
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
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDesign.screenHorizontalPadding,
              14,
              AppDesign.screenHorizontalPadding,
              128,
            ),
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
                return UniversityItemCard(
                  university: listState.items[index],
                  onTap: () => onUniversityTap(listState.items[index]),
                );
              },
            ),
          ),
      ],
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
            Colors.black.withValues(alpha: 0.78),
          ],
          stops: const [0, 1],
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
