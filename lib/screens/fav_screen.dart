import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Lokasi Favorit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, size: 80, color: Colors.pink),
              ),
              const SizedBox(height: 24),
              const Text(
                'Daftar Favorit Anda Kosong',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tambahkan lokasi atau destinasi perjalanan Anda dari halaman dashboard ke daftar favorit agar mudah diakses kembali di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}