import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthCubitState extends Equatable {
  const AuthCubitState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthCubitState {}

class Unauthenticated extends AuthCubitState {}

class AuthLoading extends AuthCubitState {}

class AuthOtpRequested extends AuthCubitState {
  final String email;

  const AuthOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class Authenticated extends AuthCubitState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user.id];
}

class AuthError extends AuthCubitState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
