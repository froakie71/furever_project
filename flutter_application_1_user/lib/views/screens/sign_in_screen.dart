import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_state.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is Authenticated) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'fullName': user.displayName,
                  'email': user.email,
                  'profileImage': user.photoURL, // <-- This is correct!
                  // ...other fields
                }, SetOptions(merge: true));
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        if (state is AuthError) {
          // Print the error to the debug console
          debugPrint('AuthError: ${state.error}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Color(0xFF32649B),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/Furever_logo.png', // Make sure to add your logo to assets
                            height: 180,
                            width: 180,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Welcome Text
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Login to your account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(221, 255, 255, 255),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 32), // Added top spacing
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: emailController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: Color(0xFF32649B).withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              prefixIcon: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Color(0xFF32649B),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF32649B),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Color(0xFF32649B)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Color(0xFF32649B), width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: passwordController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: Color(0xFF32649B).withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              prefixIcon: Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Color(0xFF32649B),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF32649B),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Color(0xFF32649B)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Color(0xFF32649B), width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30), // Increased spacing
                        // Login Button
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed:
                                state is AuthLoading
                                    ? null
                                    : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                          SignInRequested(
                                            emailController.text,
                                            passwordController.text,
                                          ),
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF38B6FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ), // Increased button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child:
                                state is AuthLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ), // Made text bold
                                    ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ), // Add spacing between buttons
                        // Sign Up Button/Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF38B6FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40), // Adjust spacing

                        const Text(
                          '-Or sign in with-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Sign In Button
                        SizedBox(
                          child: InkWell(
                            onTap:
                                state is AuthLoading
                                    ? null
                                    : () {
                                      context.read<AuthBloc>().add(
                                        GoogleSignInRequested(),
                                      );
                                    },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.asset(
                                'assets/images/google_logo.png',
                                height: 35,
                                width: 35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
