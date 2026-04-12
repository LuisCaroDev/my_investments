import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_investments/auth/data/repositories/auth_repository.dart';
import 'package:my_investments/auth/presentation/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(AuthInitial()) {
    _init();
  }

  void _init() {
    _authStateSubscription = _repository.authStateChanges.listen((state) {
      final user = state.session?.user;
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        // If we are currently entering OTP, don't immediately revert to Unauthenticated
        // just because the session is null, wait for verifyOtp to succeed or fail.
        if (this.state is! AuthOtpRequested && this.state is! AuthLoading) {
           emit(Unauthenticated());
        }
      }
    });

    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      emit(Authenticated(user: currentUser));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> requestOtp(String email, {Map<String, dynamic>? data}) async {
    try {
      emit(AuthLoading());
      await _repository.signInWithOtp(email, data: data);
      emit(AuthOtpRequested(email: email));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
      emit(Unauthenticated());
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    try {
      emit(AuthLoading());
      final response = await _repository.verifyOtp(email: email, token: code);
      if (response.session != null && response.user != null) {
        emit(Authenticated(user: response.user!));
      } else {
        emit(const AuthError(message: 'Código inválido o expirado.'));
        emit(AuthOtpRequested(email: email));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
      emit(AuthOtpRequested(email: email));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado al verificar código.'));
      emit(AuthOtpRequested(email: email));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _repository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión.'));
    }
  }

  void resetToLogin() {
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
