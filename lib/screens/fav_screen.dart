import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../helpers/database_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _favoritesData = [];
  bool _isLoading = true;

  final List<int> _animatingDeletes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // 1. Tampilkan status loading saat ditarik ke bawah
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // 2. Beri jeda waktu agar animasi reload (lingkaran) sempat terlihat
    await Future.delayed(const Duration(milliseconds: 500));

    final data = await _dbHelper.getAllDestinasi();
    if (mounted) {
      setState(() {
        _favoritesData = data
            .where((item) => item['is_favorite'] == 1)
            .toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _bukaMaps(String namaTempat) async {
    final String encodedName = Uri.encodeComponent(namaTempat);
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedName',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  void _prosesHapusFavorit(int id) async {
    setState(() {
      _animatingDeletes.add(id);
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await _dbHelper.updateDestinasiFavorit(id, 0);

    _animatingDeletes.remove(id);
    _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari daftar Favorit'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Lokasi Favorit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : _favoritesData.isEmpty
          // (PULL-TO-REFRESH) SAAT KOSONG
          ? RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.blueAccent, 
              onRefresh: _loadFavorites,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Paksa bisa di-scroll
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
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
                              child: const Icon(
                                Icons.favorite,
                                size: 80,
                                color: Colors.pink,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Daftar Favorit Kosong',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tambahkan lokasi atau destinasi perjalanan Anda dari halaman dashboard ke daftar favorit agar mudah diakses kembali di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          // TAMPILAN SAAT ADA DATA
          : RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              onRefresh: _loadFavorites,
              child: ListView.builder(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Pastikan selalu bisa ditarik
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _favoritesData.length,
                itemBuilder: (context, index) {
                  final item = _favoritesData[index];
                  final int id = item['id'];

                  final bool isCurrentlyDeleting = _animatingDeletes.contains(
                    id,
                  );

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          item['image_path'] != null &&
                                  item['image_path'].toString().isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(item['image_path']),
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.pink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.pink,
                                  ),
                                ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_tempat'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['deskripsi'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _bukaMaps(item['nama_tempat']),
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.near_me,
                                    color: Colors.blueAccent,
                                    size: 24,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _prosesHapusFavorit(id),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    isCurrentlyDeleting
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    color: Colors.redAccent,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
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
}
