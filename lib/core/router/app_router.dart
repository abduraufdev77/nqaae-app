import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/general',
        name: 'settings-general',
        builder: (context, state) =>
            const SettingsDetailScreen(title: 'General settings'),
      ),
      GoRoute(
        path: '/settings/contact',
        name: 'settings-contact',
        builder: (context, state) =>
            const SettingsDetailScreen(title: 'My Contact'),
      ),
      GoRoute(
        path: '/settings/faq',
        name: 'settings-faq',
        builder: (context, state) => const SettingsDetailScreen(title: 'FAQ'),
      ),
      GoRoute(
        path: '/settings/terms',
        name: 'settings-terms',
        builder: (context, state) =>
            const SettingsDetailScreen(title: 'Terms of service'),
      ),
      GoRoute(
        path: '/settings/policy',
        name: 'settings-policy',
        builder: (context, state) =>
            const SettingsDetailScreen(title: 'User policy'),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});
