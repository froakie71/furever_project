import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_state.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1_user/views/screens/authentication/sign_in_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1_user/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (context) => AuthBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Furever Home',
        theme: AppTheme.theme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return const HomeScreen();
                }

                return const SignInScreen();
              },
            );
          },
        ),
      ),
    );
  }
}
