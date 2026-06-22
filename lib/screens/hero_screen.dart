import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; 
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "MaMo\nMap Mobile Explorer",
      "desc": "Jelajahi area yang belum diketahui dengan percaya diri. Jelajahi tujuan Anda dengan mudah menggunakan sistem peta seluler terintegrasi kami.",
      "image": "assets/images/slide1.png",
    },
    {
      "title": "Temukan\nTempat-tempat Baru",
      "desc": "Temukan tempat-tempat tersembunyi dan destinasi populer di sekitar Anda hanya dengan beberapa ketukan di layar.",
      "image": "assets/images/slide2.png",
    },
    {
      "title": "Navigasi\nLangsung",
      "desc": "Dapatkan petunjuk arah yang akurat dan real-time langsung ke Google Maps agar Anda tidak pernah tersesat.",
      "image": "assets/images/slide3.png",
    },
    {
      "title": "Simpan\nTempat Favorit Anda",
      "desc": "Catat semua tujuan perjalanan yang telah Anda rencanakan dalam satu basis data lokal yang aman dan mudah diakses.",
      "image": "assets/images/slide4.png",
    },
    {
      "title": "Siap\nMenjelajah?",
      "desc": "Bergabunglah bersama kami hari ini dan mulailah perjalanan Anda. Mari jadikan setiap perjalanan berkesan dan terencana dengan baik.",
      "image": "assets/images/slide5.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 5000));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
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
                color: Colors.black.withValues(alpha: 0.1),
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
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keluar Aplikasi?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Apakah Anda yakin ingin meninggalkan MaMo? Perjalanan seru masih menunggu Anda.',
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
                      onPressed: () => Navigator.of(context).pop(false), 
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
                      onPressed: () {
                        HapticFeedback.mediumImpact(); 
                        SystemNavigator.pop(); 
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
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
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Loading Screen
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white, // Diubah menjadi putih
        body: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.elasticOut, 
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MaMo',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87, // Teks disesuaikan jadi gelap
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Map Mobile Explorer',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54, // Teks disesuaikan jadi abu-abu gelap
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30), 
                      
                      // Lottie Animasi Kucing Loading
                      Lottie.asset(
                        'assets/animations/cat_loading.json',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return PopScope(
      canPop: false, 
      onPopInvoked: (didPop) {
        if (didPop) return; 
        _onWillPop();  
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _goToPage(_onboardingData.length - 1),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 ? "" : "Skip",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _onboardingData[index]["title"]!,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _onboardingData[index]["desc"]!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: _onboardingData[index]["image"]!.startsWith('http')
                                      ? Image.network(
                                          _onboardingData[index]["image"]!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          _onboardingData[index]["image"]!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _currentPage == _onboardingData.length - 1
                    ? Row(
                        children: [
                          Expanded(
                            child: BouncingButton(
                              text: 'Login',
                              isPrimary: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BouncingButton(
                              text: 'Register',
                              isPrimary: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _currentPage == 0
                                ? null
                                : () => _goToPage(_currentPage - 1),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: _currentPage == 0
                                  ? Colors.transparent
                                  : Colors.black87,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              _onboardingData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                    ? Colors.blueAccent
                                    : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _goToPage(_currentPage + 1),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BouncingButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const BouncingButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) widget.onPressed();
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: widget.isPrimary ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: widget.isPrimary
                ? null
                : Border.all(color: Colors.blueAccent, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              color: widget.isPrimary ? Colors.white : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}