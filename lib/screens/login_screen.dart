import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../helpers/database_helper.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Controller untuk form Lupa Password
  final TextEditingController _forgotEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Fungsi ala SweetAlert
  void _showAlert(String title, String message, bool isSuccess, VoidCallback onOk) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.blueAccent : Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  onOk(); // Jalankan aksi selanjutnya
                },
                child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    // Validasi 1: Form kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showAlert('Peringatan', 'Maaf, email dan password tidak boleh kosong!', false, () {});
      return;
    }

    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> user = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [_emailController.text, _passwordController.text],
    );

    if (!mounted) return;

    if (user.isNotEmpty) {
      // Login Berhasil
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userId', user.first['id']);
      await prefs.setString('userName', user.first['nama']);

      _showAlert('Berhasil!', 'Login sukses. Selamat datang di MaMo!', true, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } else {
      // Validasi 2: Salah kredensial
      _showAlert('Gagal Login', 'Maaf, email atau password yang Anda masukkan tidak sesuai.', false, () {});
    }
  }

  // FUNGSI BOTTOM SHEET POP-UP LUPA PASSWORD
  void _showForgotPasswordSheet() {
    _forgotEmailController.clear();
    _newPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Reset Password',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Masukkan email Anda yang terdaftar dan buat kata sandi baru.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _forgotEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address terdaftar',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password Baru',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  String email = _forgotEmailController.text.trim();
                  String newPass = _newPasswordController.text.trim();

                  if (email.isEmpty || newPass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email dan Password baru wajib diisi!')),
                    );
                    return;
                  }

                  // Cek apakah email ada di database SQFlite
                  bool emailExist = await _dbHelper.checkEmailExists(email);
                  
                  if (!mounted) return;

                  if (emailExist) {
                    await _dbHelper.resetPasswordByEmail(email, newPass);
                    Navigator.pop(context); // Tutup bottom sheet
                    _showAlert('Berhasil Reset', 'Password berhasil diperbarui. Silakan login kembali.', true, () {});
                  } else {
                    Navigator.pop(context);
                    _showAlert('Email Tidak Ditemukan', 'Maaf, email tersebut belum terdaftar di sistem kami.', false, () {});
                  }
                },
                child: const Text(
                  'Perbarui Password',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Kustom
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  'MaMo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const Text('Map Mobile Explorer', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                // Judul Welcome Back
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(text: 'Register', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Form Input Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Form Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // TOMBOL LUPA PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordSheet,
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}