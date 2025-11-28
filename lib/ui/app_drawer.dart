// lib/ui/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Jika kamu menggunakan Google Sign-In, uncomment baris berikut:
// import 'package:google_sign_in/google_sign_in.dart';

import 'login.dart'; // pastikan path ini sesuai dengan proyekmu

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  String role = 'guest';
  String name = 'Tamu';
  String email = '';
  bool loading = false;

  late final AnimationController _ctrl;
  late final Animation<double> _headerScale;
  late final Animation<double> _headerFade;

  // we will use a single controller and create staggered intervals for list items
  static const _animationDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    _loadUser();

    _ctrl = AnimationController(vsync: this, duration: _animationDuration);

    _headerScale = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.28, curve: Curves.easeOutBack)));
    _headerFade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.28, curve: Curves.easeIn));

    // start animation when drawer is built
    // small delay to produce nicer entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      if (!mounted) return;
      setState(() {
        role = 'guest';
        name = 'Tamu';
        email = '';
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (!mounted) return;
        setState(() {
          role = (data['role'] ?? 'user').toString();
          name = (data['name'] ?? u.email ?? 'Tamu').toString();
          email = (data['email'] ?? u.email ?? '').toString();
        });
      } else {
        if (!mounted) return;
        setState(() {
          role = 'user';
          name = u.email ?? 'Tamu';
          email = u.email ?? '';
        });
      }
    } catch (e, st) {
      debugPrint('AppDrawer._loadUser error: $e\n$st');
      if (!mounted) return;
      setState(() {
        role = 'user';
        name = u.email ?? 'Tamu';
        email = u.email ?? '';
      });
    }
  }

  Future<void> _logout() async {
    if (loading) return;
    setState(() => loading = true);

    final before = FirebaseAuth.instance.currentUser;
    debugPrint('>>> logout: before uid = ${before?.uid}');

    try {
      // jika kamu menggunakan GoogleSignIn, uncomment dan gunakan:
      // final google = GoogleSignIn();
      // await google.signOut();

      await FirebaseAuth.instance.signOut();

      final after = FirebaseAuth.instance.currentUser;
      debugPrint('>>> logout: after uid = ${after?.uid}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout berhasil')));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    } catch (e, st) {
      debugPrint('>>> logout ERROR: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // helper to build animated list tile with staggered interval
  Widget _buildAnimatedTile({required int index, required Widget child}) {
    final start = 0.28 + (index * 0.08);
    final end = (start + 0.4).clamp(0.28, 1.0);
    final anim = CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  // small styled leading icon
  Widget _leadingCircle(IconData icon, {Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: (color ?? Colors.grey.shade100),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color == null ? Colors.black54 : Colors.white, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarLetter = (name.isNotEmpty ? name[0] : 'U').toUpperCase();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // animated header (custom to allow nicer look)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ScaleTransition(
                scale: _headerScale,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text(avatarLetter, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(email.isNotEmpty ? email : 'Belum login', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                          ]),
                        ),
                        // small role chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // menu items (staggered)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: [
                  _buildAnimatedTile(
                    index: 0,
                    child: ListTile(
                      leading: _leadingCircle(Icons.home, color: Colors.blue),
                      title: const Text("Beranda"),
                      onTap: () => Navigator.pushReplacementNamed(context, '/beranda'),
                    ),
                  ),
                  _buildAnimatedTile(
                    index: 1,
                    child: ListTile(
                      leading: _leadingCircle(Icons.person, color: Colors.green),
                      title: const Text("Profil"),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ),
                  _buildAnimatedTile(
                    index: 2,
                    child: ListTile(
                      leading: _leadingCircle(Icons.confirmation_number, color: Colors.orange),
                      title: const Text("Tiket Saya"),
                      onTap: () => Navigator.pushNamed(context, '/tickets'),
                    ),
                  ),
                  const Divider(),

                  // admin section (kept same behavior)
                  if (role == 'admin') ...[
                    _buildAnimatedTile(
                      index: 3,
                      child: ListTile(
                        leading: _leadingCircle(Icons.directions_bus, color: Colors.purple),
                        title: const Text("Kelola Bus"),
                        onTap: () => Navigator.pushReplacementNamed(context, '/admin/bus'),
                      ),
                    ),
                    _buildAnimatedTile(
                      index: 4,
                      child: ListTile(
                        leading: _leadingCircle(Icons.schedule, color: Colors.teal),
                        title: const Text("Kelola Jadwal"),
                        onTap: () => Navigator.pushReplacementNamed(context, '/admin/schedule'),
                      ),
                    ),
                    const Divider(),
                  ],

                  _buildAnimatedTile(
                    index: 5,
                    child: ListTile(
                      leading: _leadingCircle(Icons.info_outline, color: Colors.cyan),
                      title: const Text("Tentang Aplikasi"),
                      onTap: () => Navigator.pushNamed(context, '/about'),
                    ),
                  ),
                ],
              ),
            ),

            // logout button fixed at bottom
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : _logout,
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.logout),
                  label: Text(loading ? 'Keluar...' : 'Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
