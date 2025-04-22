import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_state.dart';
import 'package:flutter_application_1_user/bloc/donation/donation_bloc.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_bloc.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/screens/participated_events_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1_user/views/screens/authentication/sign_in_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          AndroidProvider.debug, // Use PlayIntegrity for production
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        // ...other providers
        BlocProvider(create: (context) => AdoptionBloc()),
        BlocProvider(create: (context) => EventRegistrationBloc()),
        BlocProvider(create: (context) => DonationBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furever Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF32649B),
          secondary: Color.fromARGB(255, 46, 199, 255),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/participated-events': (context) => const ParticipatedEventsScreen(),
      },
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle auth state changes if needed
        },
        builder: (context, state) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return const HomeScreen();
              }

              return const SignInScreen();
            },
          );
        },
      ),
    );
  }
}
