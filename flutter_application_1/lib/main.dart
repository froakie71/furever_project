import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/views/screens/Donations/bloc/donator_bloc.dart';
import 'package:flutter_application_1/views/screens/Donations/bloc/donator_event.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_event.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_bloc.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_event.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_bloc.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_event.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_state.dart';
import 'package:flutter_application_1/views/screens/authentication/repository/auth_repository.dart';
import 'package:flutter_application_1/views/screens/homepage/admin_homepage.dart';
import 'package:flutter_application_1/views/screens/rescue_reports/admin_rescue_reports_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'views/screens/Dogs/bloc/dog_bloc.dart';
import 'views/screens/authentication/login/admin_signin_view.dart';
import 'views/screens/Events/bloc/event_bloc.dart';
import 'views/screens/Merch/bloc/merch_bloc.dart';
import 'views/screens/schedule_checkup/ScheduleCheckupBloc/schedule_checkup_bloc.dart';
import 'views/screens/schedule_checkup/admin_schedule_checkup_screen.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Add error logging for Firebase initialization
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  AuthBloc(authRepository: AuthRepository())
                    ..add(AuthCheckRequested()),
        ),
        BlocProvider<EventBloc>(create: (context) => EventBloc()),
        BlocProvider<DogBloc>(create: (context) => DogBloc()),
        BlocProvider<MerchBloc>(
          create: (context) => MerchBloc()..add(LoadMerch()),
        ),
        BlocProvider<AdoptionBloc>(
          create: (context) => AdoptionBloc()..add(LoadPendingAdoptions()),
        ),
        BlocProvider<DonatorBloc>(
          create: (context) => DonatorBloc()..add(LoadDonators()),
        ),
        BlocProvider<ScheduleCheckupBloc>(
          create: (context) => ScheduleCheckupBloc(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furever Home Admin',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Force navigation to AdminHomeView when authentication is successful
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AdminHomeView()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show loading screen for initial state
            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is Authenticated) {
              return const AdminHomeView();
            }

            return AdminSignInView();
          },
        ),
      ),
      routes: {
        '/admin-rescue-reports': (context) => const AdminRescueReportsScreen(),
      },
    );
  }
}
