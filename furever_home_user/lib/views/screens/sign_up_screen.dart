import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFF32649B),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 24.0),
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

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                          
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  _imageFile!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: _pickImage,
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                 TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
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
                      child: const Icon(Icons.person,
                      color:Color(0xFF32649B)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Added internal padding
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 5),

                 TextField(
                  decoration: InputDecoration(
                    labelText: 'Address',
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
                      child: const Icon(Icons.location_on_outlined,color:Color(0xFF32649B)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Added internal padding
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 5),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Age',
                          filled: true,
                          fillColor: Colors.white,
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
                            child: const Icon(Icons.person_outline, color: Color(0xFF32649B)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between fields
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          filled: true,
                          fillColor: Colors.white,
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
                            child: const Icon(Icons.person_2_rounded, color: Color(0xFF32649B)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                TextField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          filled: true,
                          fillColor: Colors.white,
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
                            child: const Icon(Icons.phone_outlined, color: Color(0xFF32649B)),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          
                        ),
                        
                      ),

                const SizedBox(height: 5),
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
                      child: const Icon(Icons.email_outlined, color:Color(0xFF32649B)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12), // Added internal padding
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 5), // Increased spacing

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
                      child: const Icon(Icons.lock_outline, color:Color(0xFF32649B)),
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
                         horizontal: 10, vertical: 20), // Increased button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // Made text bold
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                '-Or sign in with-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),

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
                        height:35,
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
