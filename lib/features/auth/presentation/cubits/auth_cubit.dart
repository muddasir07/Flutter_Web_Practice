import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  String? get username => user?.username;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isAuth = await repository.isAuthenticated();
      if (isAuth) {
        final user = await repository.getCurrentUser();
        if (user != null) {
          emit(AuthState(
            status: AuthStatus.authenticated,
            user: user,
          ));
          return;
        }
      }
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> signup(String username, String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await repository.signup(username, email, password);
      if (success) {
        // Auto login after signup
        final user = await repository.login(username, password);
        if (user != null) {
          emit(AuthState(
            status: AuthStatus.authenticated,
            user: user,
          ));
          return true;
        }
      }
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: 'Username or email already exists',
      ));
      return false;
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await repository.login(username, password);
      if (user != null) {
        emit(AuthState(
          status: AuthStatus.authenticated,
          user: user,
        ));
        return true;
      }
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: 'Invalid username or password',
      ));
      return false;
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}

