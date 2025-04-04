import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../widgets/auth_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF32649B),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/Furever_logo.png',
                    height: 250,
                    width: 250,
                  ),
                   const Text(
                    'Help a Pet Find their Furver Home.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Sign In Button
                  SizedBox(
                    width: 250,
                    child:  AuthButton(
                    title: 'Sign In',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                  ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Sign Up Button
                  SizedBox(
                    width: 250,
                    child:  AuthButton(
                    title: 'Sign Up',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
