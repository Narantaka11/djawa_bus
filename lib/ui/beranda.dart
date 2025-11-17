import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';

class Beranda extends StatelessWidget {
  const Beranda({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Beranda")),
      drawer: const AppDrawer(),
      body: Center(
        child: Text("Halo, ${u?.email ?? ''}"),
      ),
    );
  }
}
