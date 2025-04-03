import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Input validation
    if (email.isEmpty) {
      throw 'Email cannot be empty';
    }
    if (!email.contains('@')) {
      throw 'Please enter a valid email';
    }
    if (name.isEmpty) {
      throw 'Full name cannot be empty';
    }
    if (password.isEmpty) {
      throw 'Password cannot be empty';
    }
    if (password.length < 6) {
      throw 'Password must be at least 6 characters';
    }

    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional admin data in Firestore
      await _firestore.collection('admins').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'This email is already registered';
        case 'invalid-email':
          throw 'Please enter a valid email address';
        case 'weak-password':
          throw 'Password is too weak. Please use a stronger password';
        case 'operation-not-allowed':
          throw 'Email/Password accounts are not enabled';
        default:
          throw e.message ?? 'An error occurred during registration';
      }
    } catch (e) {
      throw 'Failed to create account: $e';
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      throw 'Email cannot be empty';
    }
    if (password.isEmpty) {
      throw 'Password cannot be empty';
    }

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verify if user is admin
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (!adminDoc.exists) {
        await _firebaseAuth.signOut();
        throw 'Not authorized as admin';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Wrong password provided';
        case 'user-disabled':
          throw 'This account has been disabled';
        case 'invalid-email':
          throw 'Please enter a valid email address';
        default:
          throw e.message ?? 'An error occurred during sign in';
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign out';
    }
  }
}