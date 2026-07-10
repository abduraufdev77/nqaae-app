import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nqaae_app/main.dart';
import 'package:nqaae_app/core/config/api_config.dart';
import 'package:nqaae_app/core/constants/app_colors.dart';
import 'package:nqaae_app/core/constants/app_design.dart';
import 'package:nqaae_app/core/theme/app_theme.dart';
import 'package:nqaae_app/features/auth/providers/auth_provider.dart';
import 'package:nqaae_app/features/auth/screens/login_screen.dart';
import 'package:nqaae_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:nqaae_app/features/dashboard/widgets/charts/rounded_pie_chart.dart';
import 'package:nqaae_app/features/dashboard/widgets/institute_summary_card.dart';
import 'package:nqaae_app/features/dashboard/widgets/accreditation_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/professors_composition_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/scientific_potential_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/sheets/survey_results_sheet.dart';
import 'package:nqaae_app/features/dashboard/widgets/survey_results_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/specialization_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/student_contingent_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/total_students_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/types_of_education_section.dart';
import 'package:nqaae_app/features/dashboard/widgets/university_dashboard_content.dart';
import 'package:nqaae_app/shared/layout/floating_navbar.dart';
import 'package:nqaae_app/shared/widgets/app_header_controls.dart';
import 'package:nqaae_app/shared/widgets/app_silver_box.dart';
import 'package:nqaae_app/shared/widgets/cupertino_liquid_pressable.dart';
import 'package:nqaae_app/shared/widgets/searchbar.dart';
import 'package:nqaae_app/features/profile/screens/profile_screen.dart';
import 'package:nqaae_app/features/settings/screens/settings_screen.dart';
import 'package:nqaae_app/shared/widgets/card.dart';
import 'package:nqaae_app/shared/widgets/glass_card.dart';
import 'package:nqaae_app/features/universities/models/university.dart';
import 'package:nqaae_app/features/universities/providers/university_providers.dart';
import 'package:nqaae_app/features/universities/repositories/university_repository.dart';
import 'package:nqaae_app/features/universities/widgets/nqaae_ui.dart';
import 'package:nqaae_app/features/universities/widgets/university_item_card.dart';
import 'package:nqaae_app/shared/widgets/glass_button.dart';
import 'package:nqaae_app/shared/widgets/modal_sheet.dart';
import 'package:nqaae_app/shared/widgets/app_cupertino_theme.dart';

const _glassButtonBackground = Color(0x0C000000);
const _glassButtonBorderGradient = AppDesign.verticalBorderGradient;
const _glassButtonBorderWidth = 1.0;
const _glassButtonBlurStrength = 8.0;

class _FakeUniversityRepository extends UniversityRepository {
  @override
  Future<CachedUniversityValue<UniversityListResponse>?>
  readCachedUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    return null;
  }

  @override
  Future<CachedUniversityValue<University>?> readCachedUniversity(
    int sourceId,
  ) async {
    return null;
  }

  @override
  Future<UniversityListResponse> fetchUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const UniversityListResponse(
      items: [
        University(
          sourceId: 1,
          name: "Toshkent davlat texnika universiteti",
          region: "Toshkent shahri",
          ownership: "Davlat",
        ),
      ],
      page: 1,
      pageSize: 20,
      total: 1,
      pages: 1,
    );
  }

  @override
  Future<University> fetchUniversity(int sourceId) async {
    return University(
      sourceId: sourceId,
      name: 'Selected university $sourceId',
      region: 'Toshkent shahri',
      ownership: 'Davlat',
      foundedYear: 1955,
      metrics: const [
        UniversityMetric(
          section: 'summary',
          key: 'Jami talabalar',
          value: '4242',
        ),
      ],
    );
  }
}

class _CountingUniversityRepository extends _FakeUniversityRepository {
  int listFetches = 0;

  @override
  Future<UniversityListResponse> fetchUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    listFetches++;
    return super.fetchUniversities(
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NqaaeApp()));
  });

  test('App theme uses the NQAAE brand system', () {
    expect(AppColors.primary, const Color(0xFF2D86CA));
    expect(AppColors.accent, const Color(0xFF39A38D));
    expect(AppColors.dashboardSectionCard, const Color(0x0FFFFFFF));
    expect(AppColors.dashboardChip, const Color(0xFF26364E));
    expect(AppColors.dashboardChipSelected, const Color(0xFF39A38D));
    expect(
      AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily,
      startsWith('OpenSans'),
    );
  });

  test('API defaults to the device-reachable LAN backend', () {
    expect(ApiConfig.baseUrl, 'http://172.16.16.70:8000');
  });

  test('Glass border colors stay low-opacity white', () {
    expect(
      AppDesign.diagonalBorderGradient.colors.first,
      const Color(0x18FFFFFF),
    );
    expect(
      AppDesign.verticalBorderGradient.colors.first,
      const Color(0x18FFFFFF),
    );
  });

  test('AuthNotifier keeps existing error visible while retrying', () async {
    final notifier = AuthNotifier();

    await notifier.login('wrong@nqaae.uz', 'wrong');
    expect(notifier.state.error, 'Invalid email or password');

    final retry = notifier.login('wrong@nqaae.uz', 'wrong');
    expect(notifier.state.isLoading, isTrue);
    expect(notifier.state.error, 'Invalid email or password');

    await retry;
  });

  test('AuthNotifier logout clears the logged-in session', () async {
    final notifier = AuthNotifier();

    await notifier.login('admin@nqaae.uz', '123456');
    expect(notifier.state.isLoggedIn, isTrue);

    notifier.logout();
    expect(notifier.state.isLoggedIn, isFalse);
    expect(notifier.state.userRole, isNull);
    expect(notifier.state.userName, isNull);
  });

  testWidgets('Login screen pre-fills demo admin credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller?.text, 'admin@nqaae.uz');
    expect(fields[1].controller?.text, '123456');
  });

  testWidgets('Login screen heading uses Alexandria font', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    final heading = tester.widget<Text>(find.text('Xush kelibsiz'));
    expect(heading.style?.fontFamily, startsWith('Alexandria'));
  });

  testWidgets('Dashboard renders university list in universities tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Universitetlar'), findsOneWidget);
    expect(find.text("Toshkent davlat texnika universiteti"), findsNothing);

    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();

    expect(find.text("Toshkent davlat texnika universiteti"), findsOneWidget);
    expect(find.text('UNIVERSITIES'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedSlide>(
            find.byKey(const ValueKey('dashboard-floating-nav-shell')),
          )
          .offset
          .dy,
      greaterThan(0),
    );
    expect(
      find.byKey(const ValueKey('universities-header-back')),
      findsOneWidget,
    );

    final universitySearchField = find.descendant(
      of: find.byKey(const ValueKey('universities-search-shell')),
      matching: find.byType(TextField),
    );
    await tester.enterText(universitySearchField, 'Toshkent');
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text("Toshkent davlat texnika universiteti"));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('UNIVERSITIES'), findsNothing);
    expect(find.text('Selected university 1'), findsOneWidget);
    expect(find.text('4242'), findsWidgets);
    expect(
      find.byKey(const ValueKey('selected-university-dashboard')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-header-logo-clip')),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
  });

  testWidgets('Selected dashboard keeps every canonical metric visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UniversityDashboardContent(
              university: University(
                sourceId: 404,
                name: 'Empty university',
                accreditations: [
                  Accreditation(
                    accreditationType: 'complex',
                    status: "Akkreditatsiyadan o'tgan",
                    isCompleted: true,
                    certificateNumber: 'OT №123',
                    issuedDate: '01.01.2024',
                    expiresDate: '01.01.2029',
                    certificateUrl: 'https://nqaae.uz/certificate.pdf',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final specializationTiles = tester
        .widgetList<SpecializationTile>(find.byType(SpecializationTile))
        .toList();
    expect(specializationTiles, hasLength(2));
    expect(specializationTiles[0].item.color, AppColors.accent);
    expect(specializationTiles[1].item.color, AppColors.primary);

    final education = tester.widget<TypesOfEducationSection>(
      find.byType(TypesOfEducationSection),
    );
    expect(education.items, hasLength(5));
    expect(education.items.map((item) => item.value), everyElement('0'));

    final science = tester.widget<ScientificPotentialSection>(
      find.byType(ScientificPotentialSection),
    );
    expect(science.metrics, hasLength(6));
    expect(science.rankings, hasLength(7));
    expect(science.rankings.map((item) => item.value), everyElement('0'));

    final surveys = tester.widget<SurveyResultsSection>(
      find.byType(SurveyResultsSection),
    );
    expect(surveys.items, hasLength(2));
    expect(surveys.items.map((item) => item.data), everyElement(isNotNull));

    expect(find.byType(AccreditationSection), findsOneWidget);
    expect(find.text('Sertifikat raqami:'), findsWidgets);
  });

  testWidgets('Universities header back button returns to dashboard tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('universities-header-back')));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedSlide>(
            find.byKey(const ValueKey('dashboard-floating-nav-shell')),
          )
          .offset,
      Offset.zero,
    );
  });

  testWidgets('University navigation reuses the loaded list', (tester) async {
    final repository = _CountingUniversityRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [universityRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.listFetches, 1);

    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();
    expect(find.text('Toshkent davlat texnika universiteti'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('universities-header-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();

    expect(repository.listFetches, 1);
    expect(find.text('Toshkent davlat texnika universiteti'), findsOneWidget);
  });

  testWidgets('Universities search expands while focused', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();

    final beforeWidth = tester
        .getSize(find.byKey(const ValueKey('universities-search-shell')))
        .width;
    final beforeLeft = tester
        .getTopLeft(find.byKey(const ValueKey('universities-search-shell')))
        .dx;
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('universities-search-shell')),
        matching: find.byType(TextField),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
    final midWidth = tester
        .getSize(find.byKey(const ValueKey('universities-search-shell')))
        .width;
    final midLeft = tester
        .getTopLeft(find.byKey(const ValueKey('universities-search-shell')))
        .dx;

    await tester.pumpAndSettle();
    final afterWidth = tester
        .getSize(find.byKey(const ValueKey('universities-search-shell')))
        .width;
    final afterLeft = tester
        .getTopLeft(find.byKey(const ValueKey('universities-search-shell')))
        .dx;

    expect(afterWidth, greaterThan(beforeWidth));
    expect(midWidth, greaterThan(beforeWidth));
    expect(midWidth, lessThan(afterWidth));
    expect(afterLeft, lessThan(beforeLeft));
    expect(midLeft, lessThan(beforeLeft));
    expect(midLeft, greaterThan(afterLeft));
  });

  testWidgets('Universities scroll view starts under notch at physical top', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 44)),
              child: child!,
            );
          },
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Universitetlar'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(CustomScrollView).first).dy, 0);
    expect(
      find.byKey(const ValueKey('universities-header-shadow')),
      findsOneWidget,
    );
  });

  testWidgets('UniversityItemCard matches compact glass list styling', (
    WidgetTester tester,
  ) async {
    const university = University(
      sourceId: 42,
      name: 'Abdulla Qodiriy nomidagi Jizzax davlat pedagogika universiteti',
      region: 'Jizzax viloyati',
      ownership: 'Davlat',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UniversityItemCard(university: university)),
      ),
    );

    final card = tester.widget<GlassCard>(
      find.byKey(const ValueKey('university-item-card-glass')),
    );
    final title = tester.widget<Text>(find.textContaining('Abdulla Qodiriy'));

    expect(card.height, 80);
    expect(card.backgroundColor, Colors.black.withValues(alpha: 0.03));
    expect(card.borderWidth, 1.1);
    expect(title.style?.fontSize, 16);

    final arrow = tester.widget<GlassButton>(
      find.byKey(const ValueKey('university-item-arrow')),
    );
    expect(arrow.backgroundColor, _glassButtonBackground);
    expect(arrow.borderGradient, _glassButtonBorderGradient);
    expect(arrow.borderWidth, _glassButtonBorderWidth);
    expect(arrow.blurStrength, _glassButtonBlurStrength);
  });

  testWidgets(
    'Dashboard header controls reuse university item glass button styling',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            universityRepositoryProvider.overrideWithValue(
              _FakeUniversityRepository(),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final homeNotification = tester.widget<GlassButton>(
        find.byKey(const ValueKey('dashboard-header-notifications')),
      );
      expect(homeNotification.backgroundColor, _glassButtonBackground);
      expect(homeNotification.borderGradient, _glassButtonBorderGradient);
      expect(homeNotification.borderWidth, _glassButtonBorderWidth);
      expect(homeNotification.blurStrength, _glassButtonBlurStrength);

      await tester.tap(find.byTooltip('Universitetlar'));
      await tester.pumpAndSettle();

      final back = tester.widget<GlassButton>(
        find.byKey(const ValueKey('universities-header-back')),
      );
      final universitiesNotification = tester.widget<GlassButton>(
        find.byKey(const ValueKey('universities-header-notifications')),
      );

      for (final button in [back, universitiesNotification]) {
        expect(button.backgroundColor, _glassButtonBackground);
        expect(button.borderGradient, _glassButtonBorderGradient);
        expect(button.borderWidth, _glassButtonBorderWidth);
        expect(button.blurStrength, _glassButtonBlurStrength);
      }
    },
  );

  testWidgets('Dashboard home renders institute overview and key metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('ANDIJAN STATE\nPEDAGOGICAL INSTITUTE'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total Students'), findsOneWidget);
    expect(find.text('Bakalavr'), findsOneWidget);
    expect(find.text('12 510'), findsOneWidget);
  });

  testWidgets('Institute summary values wrap instead of scaling down', (
    WidgetTester tester,
  ) async {
    const longValue = 'KARAKALPAKSTAN REPUBLIC ADMINISTRATION';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InstituteSummaryCard(
              items: [
                InstituteInfoItem(
                  value: longValue,
                  label: 'Hudud',
                  icon: Icons.location_on,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final valueText = tester.widget<Text>(find.text(longValue));

    expect(valueText.maxLines, 3);
    expect(
      find.ancestor(of: find.text(longValue), matching: find.byType(FittedBox)),
      findsNothing,
    );
  });

  testWidgets('SpecializationSection renders specialization cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: SpecializationSection()),
        ),
      ),
    );

    expect(find.text('Ixtisoslashuv', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Taʼlim yo\'nalishlari tarkibi', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets(
    'RoundedPieChart renders center value and legend from generic data',
    (WidgetTester tester) async {
      const segments = [
        RoundedPieChartSegment(
          label: 'Bakalavr',
          value: '11 504',
          amount: 11504,
          color: AppColors.primary,
        ),
        RoundedPieChartSegment(
          label: 'Magistratura',
          value: '467',
          amount: 467,
          color: Color(0xFF18E5E7),
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoundedPieChart(
              centerValue: '12 510',
              segments: segments,
              size: 188,
              showLegend: true,
              showCenterValue: true,
            ),
          ),
        ),
      );

      expect(find.text('12 510'), findsOneWidget);
      expect(find.text('Bakalavr'), findsOneWidget);
      expect(find.text('11 504'), findsOneWidget);
      expect(find.text('Magistratura'), findsOneWidget);
      expect(find.text('467'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('rounded-pie-chart-paint')),
        findsOneWidget,
      );
    },
  );

  testWidgets('TotalStudentsSection uses the reusable rounded pie chart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: TotalStudentsSection()),
        ),
      ),
    );

    expect(find.byType(RoundedPieChart), findsOneWidget);
    expect(find.text('Jami talabalar'), findsOneWidget);
    expect(find.text('12 510'), findsOneWidget);
    expect(find.text('Bakalavr'), findsOneWidget);
    expect(find.text('11 504'), findsOneWidget);
  });

  testWidgets('SurveyQuestionResultCard uses rounded pie chart type scale', (
    WidgetTester tester,
  ) async {
    const question = SurveyQuestionResult(
      question: 'Taʼlim sifati sizni qoniqtiradimi?',
      positiveLabel: 'Ijobiy',
      positivePercent: 75.5,
      negativeLabel: 'Salbiy',
      negativePercent: 24.5,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: SurveyQuestionResultCard(number: 1, question: question),
          ),
        ),
      ),
    );

    expect(find.byType(RoundedPieChart), findsOneWidget);
    final chart = tester.widget<RoundedPieChart>(find.byType(RoundedPieChart));
    expect(chart.size, 64);
    expect(chart.strokeWidth, 12);
    expect(
      tester
          .widget<Text>(find.text('1. Taʼlim sifati sizni qoniqtiradimi?'))
          .style
          ?.fontSize,
      11,
    );
    expect(tester.getSize(find.byType(SurveyAnswerRatioTile).first).height, 44);
    expect(tester.widget<Text>(find.text('Ijobiy')).style?.fontSize, 10);
    expect(tester.widget<Text>(find.text('75.5%')).style?.fontSize, 13);
    expect(tester.widget<Text>(find.text('Salbiy')).style?.fontSize, 10);
    expect(tester.widget<Text>(find.text('24.5%')).style?.fontSize, 13);
  });

  testWidgets('SurveyResultsSheet uses sliver spacing for native scrolling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SurveyResultsSheet(
            assetPath: SurveyResultsSheet.professorsAssetPath,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(AppSliverBox), findsWidgets);
    expect(
      tester.widget<AppSliverBox>(find.byType(AppSliverBox).first).top,
      144,
    );
  });

  testWidgets('StudentContingentSection matches reference content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: StudentContingentSection()),
        ),
      ),
    );

    expect(find.text('Talabalar kontigenti'), findsOneWidget);
    expect(find.text('01.07.2026'), findsOneWidget);
    expect(find.text('Jami talabalar'), findsOneWidget);
    expect(find.text('11 971'), findsOneWidget);
    expect(find.text('96%'), findsOneWidget);
    expect(find.text('4%'), findsOneWidget);
    expect(find.text('11 504'), findsOneWidget);
    expect(find.text('Bachelor'), findsOneWidget);
    expect(find.text('467'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
    expect(find.text('Bitiruvchilar sifat indeksi'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('student-contingent-graduates')),
      findsOneWidget,
    );
  });

  testWidgets('StudentContingentSection does not overflow on phone width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: StudentContingentSection(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('StudentContingentSection uses dashboard metric type scale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: StudentContingentSection()),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('11 971')).style?.fontSize, 42);
    expect(tester.widget<Text>(find.text('2 455')).style?.fontSize, 24);
    expect(
      tester.widget<Text>(find.text('Qabul qilinganlar')).style?.fontSize,
      12,
    );
  });

  testWidgets('Dashboard places student contingent after education types', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final educationTop = tester.getTopLeft(
      find.byType(TypesOfEducationSection, skipOffstage: false),
    );
    final contingentTop = tester.getTopLeft(
      find.byType(StudentContingentSection, skipOffstage: false),
    );

    expect(contingentTop.dy, greaterThan(educationTop.dy));
  });

  testWidgets('ProfessorsCompositionSection matches reference content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfessorsCompositionSection()),
        ),
      ),
    );

    expect(find.text('Professor-o‘qituvchilar tarkibi'), findsOneWidget);
    expect(find.text('01.07.2026'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('Total professors'), findsOneWidget);
    expect(find.text('49,7'), findsOneWidget);
    expect(find.text('Average age'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Student-to-professor ratio'), findsOneWidget);
    expect(find.text('19.91%'), findsOneWidget);
    expect(find.text('Professors holding academic degrees'), findsOneWidget);
  });

  testWidgets('ProfessorsCompositionSection does not overflow on phone width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: ProfessorsCompositionSection(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfessorsCompositionSection uses dashboard metric type scale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ProfessorsCompositionSection()),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('123')).style?.fontSize, 24);
    expect(
      tester.widget<Text>(find.text('Total professors')).style?.fontSize,
      12,
    );
  });

  testWidgets(
    'Dashboard places professor composition after student contingent',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            universityRepositoryProvider.overrideWithValue(
              _FakeUniversityRepository(),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final studentTop = tester.getTopLeft(
        find.byType(StudentContingentSection, skipOffstage: false),
      );
      final professorTop = tester.getTopLeft(
        find.byType(ProfessorsCompositionSection, skipOffstage: false),
      );

      expect(professorTop.dy, greaterThan(studentTop.dy));
    },
  );

  testWidgets('ScientificPotentialSection matches reference content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ScientificPotentialSection()),
        ),
      ),
    );

    expect(find.text('Ilmiy salohiyat'), findsOneWidget);
    expect(find.text('Research Lab'), findsOneWidget);
    expect(find.text('Ilmiy dajali kadrlar ulushi'), findsOneWidget);
    expect(find.text('Ilmiy grantlar hajmi'), findsOneWidget);
    expect(find.text('Xalqaro va milliy ilmiy loyihalar soni'), findsOneWidget);
    expect(find.text('Spin-off korxonalar aylanmasi'), findsOneWidget);
    expect(find.text('Spin-off korxonalar soni'), findsNWidgets(2));
    expect(find.text('Patentlar soni'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Top 1%'), findsOneWidget);
    expect(find.text('Top 10%'), findsOneWidget);
    expect(find.text('Q1'), findsOneWidget);
    expect(find.text('Q2'), findsOneWidget);
    expect(find.text('Q3'), findsOneWidget);
    expect(find.text('Q4'), findsOneWidget);
  });

  testWidgets('ScientificPotentialSection does not overflow on phone width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: ScientificPotentialSection(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('ScientificPotentialSection keeps text at or below 24px', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ScientificPotentialSection()),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('Research Lab')).style?.fontSize, 18);
    expect(tester.widget<Text>(find.text('756').first).style?.fontSize, 24);
    expect(tester.widget<Text>(find.text('10')).style?.fontSize, 24);
    expect(
      tester.widget<Text>(find.text('Ilmiy grantlar hajmi')).style?.fontSize,
      12,
    );
  });

  testWidgets(
    'Dashboard places scientific potential after professor composition',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            universityRepositoryProvider.overrideWithValue(
              _FakeUniversityRepository(),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final professorTop = tester.getTopLeft(
        find.byType(ProfessorsCompositionSection, skipOffstage: false),
      );
      final scientificTop = tester.getTopLeft(
        find.byType(ScientificPotentialSection, skipOffstage: false),
      );

      expect(scientificTop.dy, greaterThan(professorTop.dy));
    },
  );

  testWidgets('DashboardSearchBar uses glass shell styling', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardSearchBar(
            controller: controller,
            onChanged: (_) {},
            onRefresh: () {},
          ),
        ),
      ),
    );

    final glassCard = tester.widget<GlassCard>(
      find.byKey(const ValueKey('dashboard-search-glass')),
    );

    expect(glassCard.backgroundColor, _glassButtonBackground);
    expect(glassCard.borderGradient, _glassButtonBorderGradient);
    expect(glassCard.blurStrength, _glassButtonBlurStrength);
    expect(glassCard.borderWidth, _glassButtonBorderWidth);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'DashboardSearchBar uses accent border while focused and blurs outside',
    (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DashboardSearchBar(
                  controller: controller,
                  onChanged: (_) {},
                  onRefresh: () {},
                ),
                GestureDetector(
                  key: ValueKey('outside-search-area'),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(width: 180, height: 120),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final focusedCard = tester.widget<GlassCard>(
        find.byKey(const ValueKey('dashboard-search-glass')),
      );
      final focusedGradient = focusedCard.borderGradient! as LinearGradient;
      expect(focusedGradient, _glassButtonBorderGradient);
      expect(focusedCard.borderColor, AppColors.accent);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );

      await tester.tap(find.byKey(const ValueKey('outside-search-area')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
    },
  );

  testWidgets('SettingsScreen matches the grouped reference structure', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: NqaaeBackground(
          child: SettingsScreen(
            searchController: controller,
            onSearchChanged: (_) {},
            onVoiceSearch: () {},
            onBack: () {},
            onProfileTap: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byType(CustomScrollView).first).dy, 0);
    expect(
      find.byKey(const ValueKey('settings-header-shadow')),
      findsOneWidget,
    );
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Jaloliddin Ozodov', skipOffstage: false), findsOneWidget);
    expect(find.text('@yourname', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Pause notifications', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('General settings', skipOffstage: false), findsOneWidget);
    expect(find.text('Dark mode', skipOffstage: false), findsOneWidget);
    expect(find.text('Language', skipOffstage: false), findsOneWidget);
    expect(find.text('My Contact', skipOffstage: false), findsOneWidget);
    expect(find.text('FAQ', skipOffstage: false), findsOneWidget);
    expect(find.text('Terms of service', skipOffstage: false), findsOneWidget);
    expect(find.text('User policy', skipOffstage: false), findsOneWidget);
    expect(find.text('Log Out', skipOffstage: false), findsOneWidget);
    expect(find.byType(Switch, skipOffstage: false), findsNWidgets(2));

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -720),
    );
    await tester.pump(const Duration(milliseconds: 450));

    final logoutGlass = tester.widget<GlassCard>(
      find.ancestor(of: find.text('Log Out'), matching: find.byType(GlassCard)),
    );
    final logoutBorder = logoutGlass.borderGradient! as LinearGradient;
    final logoutText = tester.widget<Text>(find.text('Log Out'));

    expect(logoutGlass.backgroundColor, Colors.white.withValues(alpha: 0.035));
    expect(logoutGlass.blurStrength, 16);
    expect(logoutBorder.colors, [
      AppColors.error.withValues(alpha: 0.80),
      AppColors.error.withValues(alpha: 0.80),
    ]);
    expect(logoutText.style?.color, AppColors.error);
  });

  testWidgets('SettingsScreen logout confirmation calls logout callback', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var didLogout = false;

    await tester.pumpWidget(
      MaterialApp(
        home: NqaaeBackground(
          child: SettingsScreen(
            searchController: controller,
            onSearchChanged: (_) {},
            onVoiceSearch: () {},
            onBack: () {},
            onProfileTap: () {},
            onLogout: () => didLogout = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -720),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Log Out'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Log Out').last);
    await tester.pump(const Duration(milliseconds: 500));

    expect(didLogout, isTrue);
  });

  testWidgets('ProfileScreen matches the edit profile reference structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(tester.getTopLeft(find.byType(CustomScrollView).first).dy, 0);
    expect(find.byKey(const ValueKey('profile-header-shadow')), findsOneWidget);
    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-avatar')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-camera-button')), findsOneWidget);
    expect(find.text('Full name', skipOffstage: false), findsOneWidget);
    expect(find.text('Your Name', skipOffstage: false), findsOneWidget);
    expect(find.text('Phone number', skipOffstage: false), findsOneWidget);
    expect(find.text('+998 90 327 97 87', skipOffstage: false), findsOneWidget);
    expect(find.text('Email', skipOffstage: false), findsOneWidget);
    expect(
      find.text('youremail@email.com', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Username', skipOffstage: false), findsOneWidget);
    expect(find.text('@yourname', skipOffstage: false), findsOneWidget);
    expect(find.text('Save Changes', skipOffstage: false), findsNothing);
  });

  testWidgets('Profile screen edits a value inline and saves the draft', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(platform: TargetPlatform.iOS),
        home: const ProfileScreen(),
      ),
    );

    expect(find.byKey(const ValueKey('profile-save-button')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('profile-value-full-name')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('profile-editor-full-name')),
      'Jaloliddin Ozodov',
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('profile-save-button')), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Jaloliddin Ozodov'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-save-button')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('profile-save-button')), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byKey(const ValueKey('app-top-toast')), findsOneWidget);
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(find.text('Changes saved'), findsOneWidget);
    final toastDecoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey('app-toast-glass-surface')),
                )
                .decoration
            as BoxDecoration;
    expect(
      (toastDecoration.border! as Border).top.color.a,
      lessThanOrEqualTo(0.18),
    );
    expect(toastDecoration.color, isNull);
    expect(toastDecoration.gradient, isA<LinearGradient>());
    expect(
      tester.widget<Text>(find.text('Changes saved')).style?.decoration,
      TextDecoration.none,
    );

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Profile camera opens a themed iOS source action sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Theme(
          data: AppTheme.darkTheme.copyWith(platform: TargetPlatform.iOS),
          child: const ProfileScreen(),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile-camera-button')));
    await tester.pumpAndSettle();

    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose from Library'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Take Photo')).style?.fontSize,
      AppCupertinoTheme.actionFontSize,
    );
    expect(
      tester.widget<Text>(find.text('Cancel')).style?.color,
      AppColors.error,
    );
    expect(
      CupertinoTheme.of(tester.element(find.text('Take Photo'))).primaryColor,
      AppTheme.darkTheme.colorScheme.primary,
    );
    expect(
      CupertinoTheme.of(tester.element(find.text('Take Photo'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('AppCupertinoTheme maps Material colors to Cupertino actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: AppCupertinoTheme(
          child: Builder(
            builder: (context) => Text(
              'theme probe',
              style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('theme probe')).style?.color,
      AppTheme.darkTheme.colorScheme.primary,
    );
    expect(
      CupertinoTheme.of(tester.element(find.text('theme probe'))).brightness,
      Brightness.dark,
    );
    expect(
      CupertinoTheme.of(
        tester.element(find.text('theme probe')),
      ).textTheme.actionTextStyle.fontSize,
      17,
    );
  });

  testWidgets('NqaaeApp is dark mode only', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: NqaaeApp()));

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('Dashboard home scrolls under notch with sticky shadow header', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 44)),
              child: child!,
            );
          },
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(CustomScrollView).first).dy, 0);
    expect(
      find.byKey(const ValueKey('dashboard-home-top-shadow')),
      findsOneWidget,
    );

    final headerTopBefore = tester
        .getTopLeft(find.byKey(const ValueKey('dashboard-header-logo')))
        .dy;
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('dashboard-header-logo'))).dy,
      headerTopBefore,
    );
  });

  testWidgets(
    'Dashboard and universities headers share top position and gutter',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            universityRepositoryProvider.overrideWithValue(
              _FakeUniversityRepository(),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: const EdgeInsets.only(top: 44)),
                child: child!,
              );
            },
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final dashboardHeaderTop = tester.getTopLeft(
        find.byKey(const ValueKey('dashboard-header-logo')),
      );

      await tester.tap(find.byTooltip('Universitetlar'));
      await tester.pumpAndSettle();

      final universitiesHeaderTop = tester.getTopLeft(
        find.byType(AppHeaderControls),
      );

      expect(universitiesHeaderTop.dx, dashboardHeaderTop.dx);
      expect(universitiesHeaderTop.dy, dashboardHeaderTop.dy);
    },
  );

  testWidgets('GlassButton uses press scale feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassButton(
            key: const ValueKey('pressable-glass-button'),
            tooltip: 'Notifications',
            assetName: 'assets/icons/bell.svg',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('pressable-glass-button')),
        matching: find.byType(AnimatedScale),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('pressable-glass-button')),
        matching: find.byType(CupertinoLiquidPressable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Dashboard bottom modal uses native draggable sheet chrome', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 44),
              viewPadding: const EdgeInsets.only(top: 44),
            ),
            child: child!,
          );
        },
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showDashboardModalSheet<void>(
                    context: context,
                    title: 'Survey results',
                    direction: DashboardModalSheetDirection.bottom,
                    type: DashboardModalSheetType.fullScreen,
                    child: const CustomScrollView(
                      key: ValueKey('modal-full-height-scroll'),
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 120,
                            child: Text('Sheet body'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open sheet'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(bottomSheet.enableDrag, isTrue);
    expect(bottomSheet.showDragHandle, isFalse);
    expect(tester.getTopLeft(find.byType(BottomSheet)).dy, 0);
    expect(tester.getSize(find.byType(BottomSheet)).height, 852);
    expect(tester.getTopLeft(find.byType(DashboardModalSheet)).dy, 0);
    expect(tester.getSize(find.byType(DashboardModalSheet)).height, 852);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('modal-full-height-scroll')))
          .dy,
      0,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('modal-full-height-scroll')))
          .height,
      852,
    );
    final sheetClip = tester.widget<ClipRRect>(
      find.byKey(const ValueKey('dashboard-modal-sheet-clip')),
    );
    expect(
      sheetClip.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(34)),
    );
    expect(
      find.byKey(const ValueKey('dashboard-modal-top-shadow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-modal-bottom-shadow')),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('dashboard-modal-top-shadow')))
          .dy,
      0,
    );
    expect(
      tester
          .getBottomLeft(
            find.byKey(const ValueKey('dashboard-modal-bottom-shadow')),
          )
          .dy,
      852,
    );
    expect(find.text('Survey results'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('dashboard-modal-floating-header')),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(
            find.byKey(const ValueKey('dashboard-modal-close-button')),
          )
          .dy,
      greaterThanOrEqualTo(44),
    );
    expect(
      find.descendant(
        of: find.byType(DashboardModalSheet),
        matching: find.byType(GlassButton),
      ),
      findsOneWidget,
    );
  });

  testWidgets('FloatingNavBar items use press scale feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FloatingNavBar())),
    );

    expect(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byType(AnimatedScale),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byType(CupertinoLiquidPressable),
      ),
      findsWidgets,
    );
  });

  testWidgets('DashboardCard supports solid, outline, and gradient variants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            DashboardCard(
              variant: DashboardCardVariant.solid,
              child: Text('Solid card'),
            ),
            DashboardCard(
              variant: DashboardCardVariant.outline,
              child: Text('Outline card'),
            ),
            DashboardCard(
              variant: DashboardCardVariant.gradient,
              gradientColors: [Colors.red, Colors.blue],
              child: Text('Gradient card'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Solid card'), findsOneWidget);
    expect(find.text('Outline card'), findsOneWidget);
    expect(find.text('Gradient card'), findsOneWidget);
  });

  testWidgets('Dashboard floating nav switches tab pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          universityRepositoryProvider.overrideWithValue(
            _FakeUniversityRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('dashboard-bottom-shadow')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byTooltip('Reyting'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reyting sahifasi'), findsOneWidget);
  });

  testWidgets('FloatingNavBar renders iOS-style items and reports taps', (
    WidgetTester tester,
  ) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloatingNavBar(
            currentIndex: 2,
            onTap: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Asosiy'), findsOneWidget);
    expect(find.byTooltip('Universitetlar'), findsOneWidget);
    expect(find.byTooltip('Reyting'), findsOneWidget);
    expect(find.byTooltip('Sozlamalar'), findsOneWidget);

    expect(find.byType(CustomPaint), findsWidgets);

    await tester.tap(find.byTooltip('Universitetlar'));
    expect(selectedIndex, 1);
  });
}
