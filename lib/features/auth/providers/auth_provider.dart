import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userRole; // 'admin' or 'user'
  final String? universityId;
  final String? userName;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.userRole,
    this.universityId,
    this.userName,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userRole,
    String? universityId,
    String? userName,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userRole: userRole ?? this.userRole,
      universityId: universityId ?? this.universityId,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    // Demo login logic — replace with real API
    if (email == 'admin@nqaae.uz' && password == '123456') {
      state = state.copyWith(
        isLoggedIn: true,
        userRole: 'admin',
        userName: 'Admin',
        isLoading: false,
      );
    } else if (email == 'user@nqaae.uz' && password == '123456') {
      state = state.copyWith(
        isLoggedIn: true,
        userRole: 'user',
        userName: 'University Specialist',
        universityId: 'uni_001',
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
