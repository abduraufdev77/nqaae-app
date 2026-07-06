import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nqaae_app/main.dart';
import 'package:nqaae_app/core/constants/app_colors.dart';
import 'package:nqaae_app/core/theme/app_theme.dart';
import 'package:nqaae_app/features/auth/providers/auth_provider.dart';
import 'package:nqaae_app/features/auth/screens/login_screen.dart';
import 'package:nqaae_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:nqaae_app/features/dashboard/widgets/floating_navbar.dart';
import 'package:nqaae_app/features/universities/models/university.dart';
import 'package:nqaae_app/features/universities/providers/university_providers.dart';
import 'package:nqaae_app/features/universities/repositories/university_repository.dart';

class _FakeUniversityRepository extends UniversityRepository {
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

  test('AuthNotifier keeps existing error visible while retrying', () async {
    final notifier = AuthNotifier();

    await notifier.login('wrong@nqaae.uz', 'wrong');
    expect(notifier.state.error, 'Invalid email or password');

    final retry = notifier.login('wrong@nqaae.uz', 'wrong');
    expect(notifier.state.isLoading, isTrue);
    expect(notifier.state.error, 'Invalid email or password');

    await retry;
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
  });

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
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);

    await tester.tap(find.text('Students'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('dashboard-chip-Students-selected')),
      findsOneWidget,
    );

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();

    expect(find.text('Student contingent'), findsOneWidget);
    expect(find.text('12 510'), findsOneWidget);
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
