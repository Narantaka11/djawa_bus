import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_drawer.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Kelola Jadwal")),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Admin: ${u?.email}"),
      ),
    );
  }
}
