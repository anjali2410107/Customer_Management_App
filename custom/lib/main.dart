import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/constants.dart';
import 'repositories/customer_repository.dart';
import 'providers/theme_cubit.dart';
import 'providers/auth_cubit.dart';
import 'providers/customer_cubit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CustomerRepository customerRepository;
  bool isFirebaseConnected = false;

  try {
    await Firebase.initializeApp();
    customerRepository = FirestoreCustomerRepository();
    isFirebaseConnected = true;
  } catch (e) {
    debugPrint('------------------------------------------------------------');
    debugPrint('Firebase Core failed to load: $e');
    debugPrint('Defaulting to local SharedPreferences database for testing.');
    debugPrint('------------------------------------------------------------');
    customerRepository = LocalCustomerRepository();
  }

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  final themeIndex = prefs.getInt(AppConstants.keyThemeMode);
  final initialTheme = themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.light;

  runApp(
    MyApp(
      customerRepository: customerRepository,
      initialTheme: initialTheme,
      isLoggedIn: isLoggedIn,
      isFirebaseConnected: isFirebaseConnected,
    ),
  );
}

class MyApp extends StatelessWidget {
  final CustomerRepository customerRepository;
  final ThemeMode initialTheme;
  final bool isLoggedIn;
  final bool isFirebaseConnected;

  const MyApp({
    super.key,
    required this.customerRepository,
    required this.initialTheme,
    required this.isLoggedIn,
    required this.isFirebaseConnected,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<CustomerCubit>(
          create: (context) => CustomerCubit(customerRepository),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Customer Management App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
            builder: (context, child) {
              if (!isFirebaseConnected) {
                return Stack(
                  children: [
                    if (child != null) child,
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade800.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_bolt_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Local Demo Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return child ?? const SizedBox();
            },
          );
        },
      ),
    );
  }
}
