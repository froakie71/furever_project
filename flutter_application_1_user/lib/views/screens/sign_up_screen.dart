import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_state.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrl = pickedFile.path;
        });
        // Add your image upload logic here
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF32649B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Container(
              color: Color(0xFF32649B),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/Furever_logo.png',
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
                                child:
                                    _imageUrl != null
                                        ? ClipOval(
                                          child: Image.file(
                                            File(_imageUrl!),
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
                                    onTap: pickImage,
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
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Full Name',
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
                                  Icons.person,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _addressController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Address',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Address',
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
                                  Icons.location_on,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 60,
                                child: TextFormField(
                                  controller: _ageController,
                                  style: TextStyle(
                                    color: Color(0xFF32649B),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    hintText: 'Age',
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
                                        Icons.person_outline,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your age';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 60,
                                child: TextFormField(
                                  controller: _genderController,
                                  style: TextStyle(
                                    color: Color(0xFF32649B),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    hintText: 'Gender',
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
                                        Icons.person_2_rounded,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your gender';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _phoneController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Phone Number',
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
                                  Icons.phone_outlined,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _usernameController,
                            style: TextStyle(
                              color: Color(0xFF32649B),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Username',
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
                                  Icons.account_circle_outlined,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              if (value.contains(' ')) {
                                return 'Username cannot contain spaces';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 60,
                          child: TextFormField(
                            controller: _emailController,
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
                            controller: _passwordController,
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
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed:
                                state is AuthLoading
                                    ? null
                                    : () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Check if username already exists
                                        final usernameQuery =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .where(
                                                  'username',
                                                  isEqualTo:
                                                      _usernameController.text
                                                          .trim(),
                                                )
                                                .get();

                                        if (usernameQuery.docs.isNotEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Username already taken. Please choose another.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final userData = {
                                          'fullName': _nameController.text,
                                          'username':
                                              _usernameController.text
                                                  .trim(), // Ensure username is trimmed
                                          'email': _emailController.text,
                                          'address': _addressController.text,
                                          'age': _ageController.text,
                                          'gender': _genderController.text,
                                          'phone': _phoneController.text,
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        };

                                        if (_imageFile == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select a profile image',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (_imageFile is File) {
                                          context.read<AuthBloc>().add(
                                            SignUpRequested(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                              userData: userData,
                                              imageFile: _imageFile,
                                            ),
                                          );
                                        }
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF38B6FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
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
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
