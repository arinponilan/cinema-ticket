import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/cinema_models.dart';
import 'admin_shell_page.dart';
import 'main_container.dart';

// REGISTER PAGE
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'Customer';
  bool _loading = false;
  bool _showPassword = false;

  Future<void> _register() async {
    final email = _emailCtrl.text;
    if (_role == 'Admin' && email != 'admin@gmail.com') {
      _snack(
        'Akses Ditolak! Hanya akun resmi yang bisa mendaftar sebagai Admin.',
      );
      return;
    }
    if (!email.endsWith('@gmail.com')) {
      _snack('Email harus menggunakan @gmail.com!');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameCtrl.text,
          'email': email,
          'password': _passCtrl.text,
          'admin': _role == 'Admin',
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pop(context);
      } else {
        _snack('Registrasi Gagal! Mungkin email sudah terdaftar.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const Text(
              "Join the premiere cinema club",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
            _field(_nameCtrl, "Full Name", Icons.person),
            const SizedBox(height: 20),
            _field(_emailCtrl, "Email", Icons.email),
            const SizedBox(height: 20),
            _field(
              _passCtrl,
              "Password",
              Icons.lock,
              obscure: !_showPassword,
              suffixIcon: IconButton(
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                "Register as Admin?",
                style: TextStyle(color: Colors.white),
              ),
              value: _role == 'Admin',
              onChanged: (val) =>
                  setState(() => _role = val ? 'Admin' : 'Customer'),
              activeThumbColor: Colors.amber,
            ),
            const SizedBox(height: 40),
            _loading
                ? const CircularProgressIndicator(color: Colors.amber)
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// LOGIN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  Future<void> _login() async {
    String email = _emailCtrl.text.trim();

    // Auto-map username 'admin' to its database email
    if (email.toLowerCase() == 'admin') {
      email = 'admin@gmail.com';
    }

    if (email.isEmpty) {
      _snack('Masukkan email atau username');
      return;
    }

    final isEmail = email.contains('@');
    if (isEmail && !email.endsWith('@gmail.com')) {
      _snack('Format salah! Gunakan email @gmail.com');
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': _passCtrl.text}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final name = (userData['name'] ?? '').toString();
        final loginEmail = (userData['email'] ?? email).toString();
        final userId = MovieData.intValue(userData['userId']);

        // ENFORCE: Only admin@gmail.com can access the Admin panel
        final effectiveRole = (loginEmail.toLowerCase() == 'admin@gmail.com')
            ? 'admin'
            : 'customer';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => effectiveRole == 'admin'
                ? AdminShellPage(
                    userId: userId,
                    userName: name,
                    email: loginEmail,
                    role: effectiveRole,
                  )
                : MainContainer(
                    userId: userId,
                    userName: name,
                    email: loginEmail,
                    role: effectiveRole,
                  ),
          ),
        );
      } else {
        _snack('Login Gagal! Email/Password salah.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "TIXTIX PREMIERE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "PREMIERE ACCESS",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 50),
              _field(_emailCtrl, "Email / Username", Icons.email),
              const SizedBox(height: 20),
              _field(
                _passCtrl,
                "Password",
                Icons.lock,
                obscure: !_showPassword,
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _loading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
