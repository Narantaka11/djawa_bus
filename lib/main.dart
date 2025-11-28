// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ui/splashscreen.dart';
import 'helpers/user_provider.dart';
import 'ui/login.dart';
import 'ui/beranda.dart';

// admin pages yang bener
import 'ui/admin/admin_buses_page.dart';
import 'ui/admin/admin_schedules_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Ticketing (Firebase)',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),

      routes: {
        '/login': (_) => const Login(),
        '/beranda': (_) => const Beranda(),
        '/admin/bus': (_) => const AdminBusesPage(),
        '/admin/schedule': (_) => const AdminSchedulesPage(),
        '/auth' : (_) => const AuthGate(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint ('[AuthGate] build() called');
    // Listen ke auth state dulu
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        debugPrint('[AuthGate] authSnap state=${authSnap.connectionState} data=${authSnap.data} error=${authSnap.error}');
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnap.data;
        if (user == null) {
          // belum login
          return const Login();
        }

        // sudah login -> listen realtime ke users/{uid} role
        return StreamBuilder<String?>(
          stream: UserProvider.roleStream(user.uid),
          builder: (context, roleSnap) {
            // Jika kita sedang menunggu snapshot pertama (misalnya jaringan lambat)
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Jika error saat listen doc user => fallback ke Beranda
            if (roleSnap.hasError) {
              debugPrint('[AuthGate] roleStream ERROR: ${roleSnap.error}');
              return const Beranda();
            }

            final role = roleSnap.data ?? 'user';
            debugPrint('[AuthGate] auth uid=${user.uid} role=$role');

            if (role == 'admin') {
              return const AdminSchedulesPage();
            }
            return const Beranda();
          },
        );
      },
    );
  }
}
