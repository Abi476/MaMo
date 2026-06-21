import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; 
import 'dashboard_screen.dart';
import 'eksplor_screen.dart';
import 'fav_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Buat GlobalKey khusus untuk mengontrol State dari ProfileScreen
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();

  // Hubungkan key tersebut ke dalam instansiasi halaman profil
  // Catatan: 'const' dihapus dari List karena ProfileScreen sekarang menerima key dinamis
  List<Widget> get _pages => [
    const DashboardScreen(),
    const EksplorScreen(), 
    const FavoritesScreen(), 
    ProfileScreen(key: _profileKey), // Key dipasang di sini
  ];

  // Modifikasi fungsi tap navigasi untuk melakukan validasi
  void _onItemTapped(int index) async {
    // Jika posisi saat ini di Tab Profil (index 3) dan user menekan tab lain
    if (_selectedIndex == 3 && index != 3) {
      final profileState = _profileKey.currentState;
      
      // Panggil fungsi validasi milik ProfileScreen
      if (profileState != null && profileState.hasUnsavedChanges()) {
        bool? tinggalkan = await _tampilkanDialogBelumSimpan();
        if (tinggalkan != true) {
          return; // Gagalkan perpindahan, user tetap berada di halaman profil
        }
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // Pop-Up Validasi ketika data profil belum disimpan
  Future<bool?> _tampilkanDialogBelumSimpan() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Perubahan Belum Disimpan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda memiliki perubahan data atau foto yang belum disimpan. Jika Anda pergi, perubahan tersebut akan hilang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false), // Kembali/Batal pindah
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true), // Konfirmasi tinggalkan halaman
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.orangeAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Tinggalkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent, 
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Keluar Aplikasi?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 12),
              const Text('Apakah Anda yakin ingin meninggalkan MaMo?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false), 
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact(); 
                        SystemNavigator.pop(); 
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true, 
        body: _pages[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          height: 65.0,
          color: Colors.white, 
          buttonBackgroundColor: Colors.blueAccent, 
          backgroundColor: Colors.transparent, 
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 400),
          onTap: _onItemTapped, // Mengeksekusi logika validasi sebelum pindah tab
          items: <Widget>[
            Icon(Icons.dashboard_rounded, size: 30, color: _selectedIndex == 0 ? Colors.white : Colors.blueAccent),
            Icon(Icons.map_rounded, size: 30, color: _selectedIndex == 1 ? Colors.white : Colors.blueAccent),
            Icon(Icons.favorite_rounded, size: 30, color: _selectedIndex == 2 ? Colors.white : Colors.blueAccent),
            Icon(Icons.person_rounded, size: 30, color: _selectedIndex == 3 ? Colors.white : Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}