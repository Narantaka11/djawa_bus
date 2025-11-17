import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? role;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .get();

      if (doc.exists) {
        setState(() {
          role = doc['role'];
          name = doc['name'];
          email = doc['email'];
        });
      } else {
        setState(() {
          role = 'user';
          name = u.email;
          email = u.email;
        });
      }
    } catch (e) {
      setState(() {
        role = 'user';
        name = u.email;
        email = u.email;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name ?? "Loading..."),
              accountEmail: Text(email ?? ""),
              currentAccountPicture: CircleAvatar(
                child: Text((name ?? 'U')[0].toUpperCase()),
              ),
            ),

            // ——————————————————
            // Menu umum
            // ——————————————————
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Beranda"),
              onTap: () => Navigator.pushReplacementNamed(context, '/beranda'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profil"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text("Tiket Saya"),
              onTap: () => Navigator.pushNamed(context, '/tickets'),
            ),

            const Divider(),

            // ——————————————————
            // Menu Admin
            // ——————————————————
            if (role == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text("Kelola Bus"),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/admin/bus'),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Kelola Jadwal"),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/admin/schedule'),
              ),
              const Divider(),
            ],

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Tentang Aplikasi"),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
