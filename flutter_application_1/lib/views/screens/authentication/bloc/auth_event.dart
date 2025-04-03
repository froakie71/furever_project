abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpRequested(this.email, this.password, this.name);
}

class AuthCheckRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;

  final String password;

  SignInRequested({required this.email, required this.password});
}
