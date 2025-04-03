import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;
  const AuthError(this.error);
}