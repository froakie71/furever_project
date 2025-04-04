import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFF32649B), // Light blue background
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                // Email TextField
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white, // White background
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF32649B),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Icon(Icons.email_outlined,
                          color: Color(0xFF32649B)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Added internal padding
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10), // Increased spacing

                // Password TextField
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white, // White background
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF32649B),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Icon(Icons.lock_outline,
                          color: Color(0xFF32649B)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Added internal padding
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30), // Increased spacing

                // Login Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF38B6FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20), // Increased button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // Made text bold
                    ),
                  ),
                ),
                const SizedBox(height: 80),

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
                    onTap: () {
                      // Add your Google sign in logic here
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
    );
  }
}
