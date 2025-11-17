import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Profil")),
          body: const Center(child: Text("Halaman Profil")));
}

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Tiket Saya")),
          body: const Center(child: Text("Daftar Tiket")));
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Tentang Aplikasi")),
          body: const Center(child: Text("Aplikasi Tiket Bus")));
}

class AdminBusPage extends StatelessWidget {
  const AdminBusPage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Kelola Bus")),
          drawer: const Drawer(),
          body: const Center(child: Text("CRUD Bus")));
}

class AdminSchedulePage extends StatelessWidget {
  const AdminSchedulePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Kelola Jadwal")),
          drawer: const Drawer(),
          body: const Center(child: Text("CRUD Jadwal")));
}
