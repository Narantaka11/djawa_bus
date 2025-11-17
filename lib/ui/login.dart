import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/user_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() => loading = true);

    try {
      if (isLogin) {
        // LOGIN
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        // setelah login, AuthGate akan otomatis mem-navigate berdasarkan role
      } else {
        // REGISTER
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );

        // setelah account Auth berhasil dibuat, kita bikin dokumen profile di Firestore
        try {
          await UserProvider.createUserDocument(
            cred.user!.uid,
            _name.text.trim(),
            _email.text.trim(),
            'user', // default role saat register = user
          );
          // kalau createUserDocument sukses, AuthGate akan meng-handle navigasi
        } catch (e) {
          // jika gagal menyimpan profile di Firestore, hapus akun Auth agar tidak setengah jadi
          try {
            await cred.user?.delete();
          } catch (_) {}
          rethrow; // lempar lagi supaya tampil error ke pengguna
        }
      }
    } on FirebaseAuthException catch (e) {
      // tangani error firebase auth spesifik
      String msg = 'Terjadi kesalahan';
      if (e.code == 'weak-password') {
        msg = 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Email sudah terdaftar.';
      } else if (e.code == 'user-not-found') {
        msg = 'User tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        msg = 'Password salah.';
      } else {
        msg = e.message ?? msg;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Setelah signOut, StreamBuilder di AuthGate akan menampilkan Login()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Register'),
        actions: [
          IconButton(
            tooltip: 'Sign out (if logged)',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isLogin ? 'Login' : 'Register'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: loading ? null : () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Buat akun baru' : 'Sudah punya akun? Login'),
            ),
            const SizedBox(height: 8),
            // Info singkat
            if (isLogin)
              const Text('Masuk dengan akun yang sudah terdaftar.')
            else
              const Text('Register akan membuat akun dan profil user di Firestore.'),
          ],
        ),
      ),
    );
  }
}
