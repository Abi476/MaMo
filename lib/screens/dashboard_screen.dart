import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as p; 
import 'package:geocoding/geocoding.dart'; 

import '../helpers/database_helper.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onProfileTap; 

  const DashboardScreen({super.key, this.onProfileTap}); 

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _destinasiData = [];
  bool _isLoading = true;
  String _userName = '';
  File? _profileImage; 

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;
    String savedName = prefs.getString('userName') ?? 'User';

    final userData = await _dbHelper.getUserProfile(userId);

    setState(() {
      _userName = savedName;
      if (userData != null &&
          userData['profile_image_path'] != null &&
          userData['profile_image_path'].toString().isNotEmpty) {
        _profileImage = File(userData['profile_image_path']);
      } else {
        _profileImage = null; 
      }
    });
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() { _isLoading = true; });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    final data = await _dbHelper.getAllDestinasi();
    if (mounted) {
      setState(() {
        _destinasiData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // PERBAIKAN: URL Google Maps resmi agar pencarian tempat akurat saat di-redirect
  Future<void> _bukaMaps(String namaTempat) async {
    final String encodedName = Uri.encodeComponent(namaTempat);
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedName');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  void _toggleFavorit(int id, int currentStatus) async {
    int newStatus = currentStatus == 1 ? 0 : 1;
    await _dbHelper.updateDestinasiFavorit(id, newStatus);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 1 ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showForm(int? id) async {
    File? pickedFormImage; 

    if (id != null) {
      final dataLama = _destinasiData.firstWhere(
        (element) => element['id'] == id,
      );
      _namaController.text = dataLama['nama_tempat'];
      _deskripsiController.text = dataLama['deskripsi'];
      if (dataLama['image_path'] != null && dataLama['image_path'].toString().isNotEmpty) {
        pickedFormImage = File(dataLama['image_path']);
      }
    } else {
      _namaController.clear();
      _deskripsiController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) => StatefulBuilder( 
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id == null ? 'Tambah Lokasi Tujuan' : 'Edit Lokasi Tujuan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 600,
                          maxHeight: 600,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setModalState(() {
                            pickedFormImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          image: pickedFormImage != null
                              ? DecorationImage(image: FileImage(pickedFormImage!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: pickedFormImage == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined, color: Colors.blueAccent, size: 40),
                                    SizedBox(height: 8),
                                    Text('Tambah Foto Lokasi', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tempat / Alamat',
                        hintText: 'Contoh: Patemon Pemandian Jember',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Tulis info detail tempat di sini...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_namaController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama tempat wajib diisi!')),
                            );
                            return;
                          }

                          // Tampilkan loading indikator kecil saat mencari koordinat alamat
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                          );

                          double lat = 0.0;
                          double lng = 0.0;
                          Map<String, dynamic>? dataLama;

                          // 1. Jika ini proses UPDATE, ambil koordinat lama sebagai cadangan
                          if (id != null) {
                            dataLama = _destinasiData.firstWhere((element) => element['id'] == id);
                            lat = dataLama['latitude'] ?? 0.0;
                            lng = dataLama['longitude'] ?? 0.0;
                          }

                          // 2. LOGIKA BARU: Cari koordinat dengan tambahan "Indonesia" agar tidak nyasar
                          try {
                            String searchQuery = "${_namaController.text}, Indonesia"; // Paksa cari di Indonesia
                            List<Location> locations = await locationFromAddress(searchQuery);
                            if (locations.isNotEmpty) {
                              lat = locations.first.latitude;
                              lng = locations.first.longitude;
                            }
                          } catch (e) {
                            // JIKA GAGAL DITEMUKAN:
                            // - Jika lokasi baru, set 0.0 (agar EksplorScreen bisa menyebarnya otomatis)
                            // - Jika update, biarkan lat & lng tetap menggunakan dataLama
                            if (id == null) {
                              lat = 0.0;
                              lng = 0.0;
                            }
                          }

                          // Tutup loading dialog pencarian koordinat
                          if (mounted) Navigator.pop(context);

                          String? finalImagePath;
                          if (pickedFormImage != null) {
                            if (!pickedFormImage!.path.contains('app_flutter/destinasi_')) {
                              final Directory directory = await getApplicationDocumentsDirectory();
                              final String fileName = 'destinasi_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final String pathOnAppDocDir = p.join(directory.path, fileName);
                              final File savedImage = await pickedFormImage!.copy(pathOnAppDocDir);
                              finalImagePath = savedImage.path;
                            } else {
                              finalImagePath = pickedFormImage!.path;
                            }
                          }

                          Map<String, dynamic> dataBaru = {
                            'nama_tempat': _namaController.text,
                            'deskripsi': _deskripsiController.text,
                            'latitude': lat, 
                            'longitude': lng, 
                            // Pertahankan gambar lama jika tidak ada gambar baru yang dipilih
                            'image_path': finalImagePath ?? (dataLama != null ? dataLama['image_path'] : null), 
                          };

                          if (id == null) {
                            await _dbHelper.insertDestinasi(dataBaru);
                          } else {
                            await _dbHelper.updateDestinasi(id, dataBaru);
                          }

                          if (mounted) Navigator.pop(context);
                          _loadData();
                        },
                        child: Text(
                          id == null ? 'Simpan Lokasi' : 'Update Lokasi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _hapusData(int id) async {
    await _dbHelper.deleteDestinasi(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MaMo Dashboard',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hello, $_userName! 👋',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onProfileTap != null) {
                        widget.onProfileTap!();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              )
                            : null, 
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : _destinasiData.isEmpty
                  ? RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      onRefresh: _loadData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    'Belum ada lokasi tujuan.\nTekan + untuk menambah.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      onRefresh: _loadData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _destinasiData.length,
                        itemBuilder: (context, index) {
                          final item = _destinasiData[index];
                          final int isFavorite = item['is_favorite'] ?? 0;

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
                                  item['image_path'] != null && item['image_path'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            File(item['image_path']),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                  const SizedBox(width: 14),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['nama_tempat'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
                                        onTap: () => _showForm(item['id']),
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.edit, color: Colors.orange, size: 22),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _bukaMaps(item['nama_tempat']),
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.near_me, color: Colors.blueAccent, size: 22),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _toggleFavorit(item['id'], isFavorite),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Icon(
                                            isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _hapusData(item['id']),
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.delete_outline, color: Colors.red, size: 22),
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
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85.0),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () => _showForm(null),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}