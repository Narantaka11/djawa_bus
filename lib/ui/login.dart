import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/user_provider.dart';
import '../ui/beranda.dart';
import '../ui/admin/admin_schedules_page.dart';

Future<void> _navigateAfterLogin(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  final role = await UserProvider.getRole(uid) ?? 'user';
  if (!context.mounted) return;
  if (role == 'admin') {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminSchedulesPage()),
      (r) => false,
    );
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Beranda()),
      (r) => false,
    );
  }
}

Future<void> _signOutAndGoToLogin(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u == null);
  } catch (_) {}
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const Login()),
    (r) => false,
  );
}

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool loading = false;
  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passwordError;

  late final AnimationController _animCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    debugPrint('[Login] initState called');

    _email.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _password.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoFade = CurvedAnimation(parent: _animCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _cardFade = CurvedAnimation(parent: _animCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeIn));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  String _friendlyAuthMessage(String code, [String? fallback]) {
    switch (code) {
      case 'wrong-password':
        return 'Email atau password salah. Coba periksa kembali.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan. Hubungi admin.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi jaringan bermasalah. Periksa koneksi internetmu.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login atau pakai email lain.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'operation-not-allowed':
        return 'Metode login ini tidak diizinkan pada proyek Firebase.';
      default:
        return fallback ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<void> submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      if (isLogin) {
        // safety: jika ada user aktif, signOut dulu
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
          await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u == null);
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );

        await _navigateAfterLogin(context);
      } else {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await UserProvider.createUserDocument(
          cred.user!.uid, _name.text.trim(), _email.text.trim(), 'user',
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Beranda()),
          (r) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
    debugPrint('[AuthErr] code=${e.code} message=${e.message}');
    final code = e.code ?? '';
    String friendly = _friendlyAuthMessage(code);
    const treatAsWrongCredential = {'invalid-credential', 'invalid-verification-code', 'invalid-verification-id'};

    setState(() {
      _emailError = null;
      _passwordError = null;

      if (code == 'wrong-password') {
        _passwordError = 'Password salah';
      } else if (code == 'user-not-found') {
        _emailError = 'Akun tidak ditemukan';
      } else if (code == 'invalid-email') {
        _emailError = 'Email tidak valid';
      } else if (code == 'weak-password') {
        _passwordError = 'Password terlalu lemah';
      } else if (code == 'email-already-in-use') {
        _emailError = 'Email sudah terdaftar';
      } else if (treatAsWrongCredential.contains(code) && isLogin) {
        _passwordError = 'Password salah';
        friendly = 'Email atau password salah. Coba periksa kembali.';
      } else {
        _emailError = null;
        _passwordError = null;
      }
    });

      _showError(friendly);
    } catch (e) {
      debugPrint('[AuthErr] unknown: $e');
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _fieldDecoration({required String label, IconData? icon, String? errorText}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon) : null,
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[Login] build called');
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 900 ? 520.0 : (width > 600 ? 480.0 : width * 0.92);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
                            ),
                            child: const Center(
                              child: Icon(Icons.directions_bus_rounded, size: 52, color: Colors.blueAccent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "d'JAWA ",
                                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: "BUS",
                                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                    SlideTransition(
                      position: _cardSlide,
                      child: FadeTransition(
                        opacity: _cardFade,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(isLogin ? 'Masuk' : 'Daftar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 12),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      if (!isLogin) ...[
                                        TextFormField(
                                          controller: _name,
                                          decoration: _fieldDecoration(label: 'Nama lengkap', icon: Icons.person),
                                          textInputAction: TextInputAction.next,
                                          validator: (v) {
                                            if (!isLogin && (v == null || v.trim().isEmpty)) return 'Nama wajib';
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      TextFormField(
                                        controller: _email,
                                        decoration: _fieldDecoration(label: 'Email', icon: Icons.email, errorText: _emailError),
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'Email wajib';
                                          if (!v.contains('@')) return 'Email tidak valid';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _password,
                                        decoration: _fieldDecoration(label: 'Password', icon: Icons.lock, errorText: _passwordError).copyWith(
                                          suffixIcon: IconButton(
                                            icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                                            onPressed: () => setState(() => showPassword = !showPassword),
                                          ),
                                        ),
                                        obscureText: !showPassword,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Password wajib';
                                          if (v.length < 6) return 'Minimal 6 karakter';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: loading ? null : submit,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: loading
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : Text(isLogin ? 'Masuk' : 'Daftar'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(isLogin ? 'Belum punya akun?' : 'Sudah punya akun?'),
                                          TextButton(
                                            onPressed: loading
                                                ? null
                                                : () {
                                                    setState(() {
                                                      isLogin = !isLogin;
                                                      _emailError = null;
                                                      _passwordError = null;
                                                    });
                                                    _animCtrl.forward(from: 0.45);
                                                  },
                                            child: Text(isLogin ? 'Daftar' : 'Masuk'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: loading ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hubungi admin untuk bantuan login'))),
                      child: const Text('Butuh bantuan?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
