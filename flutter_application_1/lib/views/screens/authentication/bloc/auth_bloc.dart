
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final adminDoc = await FirebaseFirestore.instance
              .collection('admins')
              .doc(currentUser.uid)
              .get();

          if (adminDoc.exists) {
            emit(Authenticated(currentUser));
          } else {
            emit(UnAuthenticated());
          }
        } catch (e) {
          emit(UnAuthenticated());
        }
      } else {
        emit(UnAuthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signIn(
          email: event.email,
          password: event.password,
        );

        // Get the current user after sign in
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Check if user is an admin
          final adminDoc = await FirebaseFirestore.instance
              .collection('admins')
              .doc(currentUser.uid)
              .get();

          if (adminDoc.exists) {
            emit(Authenticated(currentUser));
          } else {
            await authRepository.signOut(); // Sign out if not an admin
            emit(AuthError('Not authorized as admin'));
            emit(UnAuthenticated());
          }
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });

    // Add SignUpRequested event handler
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        emit(Authenticated(FirebaseAuth.instance.currentUser!));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(UnAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
