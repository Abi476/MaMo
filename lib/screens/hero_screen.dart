import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class HeroScreen extends StatefulWidget {
  const HeroScreen({super.key});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Cek apakah user sudah login sebelumnya
  void _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // Jika sudah login, langsung ke Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Jika belum, hentikan loading dan tampilkan halaman Hero
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading berputar sebentar saat sedang mengecek sesi
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Atas: Teks Judul dan Deskripsi
              const SizedBox(height: 40),
              const Text(
                'Welcome to\nMaMo',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Menggunakan blueAccent
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Navigate complex spaces with confidence. Explore your destination easily using our integrated map mobile system.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              // Bagian Tengah: Ikon/Ilustrasi Pengganti Gambar
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined, // Ikon peta
                        size: 150,
                        color: Colors.blueAccent, // Menggunakan blueAccent
                      ),
                      SizedBox(height: 20),
                      Icon(
                        Icons.location_on, // Ikon pin lokasi
                        size: 50,
                        color: Colors.blueAccent, // Menggunakan blueAccent
                      ),
                    ],
                  ),
                ),
              ),

              // Bagian Bawah: Tombol Get Started (Login) & Register
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Menggunakan blueAccent
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent, width: 2), // Menggunakan blueAccent
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold)), // Menggunakan blueAccent
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}