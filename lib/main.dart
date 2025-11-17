import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'helpers/user_provider.dart';
import 'ui/login.dart';
import 'ui/beranda.dart';
import 'ui/admin/schedule_page.dart';
import 'ui/app_drawer.dart';          // pastikan file ini ada
import 'ui/placeholders.dart';       // profile, tickets, about, admin pages
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
      home: const AuthGate(),
      routes: {
        '/beranda': (_) => const Beranda(),
        '/profile': (_) => const ProfilePage(),
        '/tickets': (_) => const TicketsPage(),
        '/about': (_) => const AboutPage(),
        // admin routes (placeholder)
        '/admin/bus': (_) => const AdminBusPage(),
        '/admin/schedule': (_) => const AdminSchedulePage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // masih menunggu auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // belum login -> tampilkan layar login
        if (user == null) {
          return const Login();
        }

        // sudah login -> ambil role dari Firestore,
        // beri timeout agar UI tidak macet bila Firestore lambat/tidak ada dokumen
        return FutureBuilder<String?>(
          future: UserProvider.getRole(user.uid).timeout(
            const Duration(seconds: 6),
            onTimeout: () {
              // debug log — untuk dilihat di console saat debugging
              debugPrint('[AuthGate] getRole TIMEOUT for uid=${user.uid}');
              return null; // fallback -> treat as 'user'
            },
          ),
          builder: (context, roleSnapshot) {
            // masih menunggu result role
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // jika error saat getRole -> log & fallback ke Beranda (user)
            if (roleSnapshot.hasError) {
              debugPrint('[AuthGate] getRole ERROR: ${roleSnapshot.error}');
              return const Beranda();
            }

            // ambil role (null berarti default 'user')
            final role = roleSnapshot.data ?? 'user';
            debugPrint('[AuthGate] role for uid=${user.uid} => $role');

            if (role == 'admin') {
              return const SchedulePage();
            }
            return const Beranda();
          },
        );
      },
    );
  }
}
