import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/database_helper.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _destinasiData = [];
  bool _isLoading = true;
  String _userName = '';

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
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _loadData() async {
    final data = await _dbHelper.getAllDestinasi();
    setState(() {
      _destinasiData = data;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  // DI SINI KUNCI PERBAIKANNYA: Menggunakan Nama Tempat, bukan Lat/Lng
  Future<void> _bukaMaps(String namaTempat) async {
    // Encode komponen URL (misal spasi diubah jadi %20 agar terbaca Google Maps)
    final String encodedName = Uri.encodeComponent(namaTempat);
    
    // Gunakan parameter destination=NamaTempat
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedName');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  void _showForm(int? id) async {
    if (id != null) {
      final dataLama = _destinasiData.firstWhere((element) => element['id'] == id);
      _namaController.text = dataLama['nama_tempat'];
      _deskripsiController.text = dataLama['deskripsi'];
    } else {
      _namaController.clear();
      _deskripsiController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id == null ? 'Tambah Lokasi Tujuan' : 'Edit Lokasi Tujuan', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 15),
            TextField(
              controller: _namaController, 
              decoration: const InputDecoration(labelText: 'Nama Tempat / Alamat', hintText: 'Contoh: Politeknik Negeri Jember', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deskripsiController, 
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi', hintText: 'Tulis info detail tempat di sini...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_namaController.text.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tempat wajib diisi!')));
                     return; 
                  }
                  
                  Map<String, dynamic> dataBaru = {
                    'nama_tempat': _namaController.text,
                    'deskripsi': _deskripsiController.text,
                    'latitude': 0.0, 
                    'longitude': 0.0,
                  };

                  if (id == null) {
                    await _dbHelper.insertDestinasi(dataBaru); 
                  } else {
                    await _dbHelper.updateDestinasi(id, dataBaru); 
                  }

                  if (mounted) Navigator.pop(context);
                  _loadData(); 
                },
                child: Text(id == null ? 'Simpan Lokasi' : 'Update Lokasi', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _hapusData(int id) async {
    await _dbHelper.deleteDestinasi(id);
    _loadData(); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MaMo Dashboard', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Hello, $_userName!', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blueAccent),
            onPressed: () async {
              final bool? isUpdated = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProfileScreen())
              );
              if (isUpdated == true) {
                _loadUserData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent)) 
        : _destinasiData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Belum ada lokasi tujuan.\nTekan + untuk menambah.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _destinasiData.length,
              itemBuilder: (context, index) {
                final item = _destinasiData[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade300)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on, color: Colors.blueAccent),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama_tempat'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(item['deskripsi'], style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            // DI SINI JUGA KUNCINYA: Pastikan memanggil item['nama_tempat']
                            IconButton(
                              icon: const Icon(Icons.directions_car, color: Colors.blueAccent, size: 28),
                              tooltip: 'Arahkan ke Maps',
                              onPressed: () => _bukaMaps(item['nama_tempat']),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _showForm(item['id'])),
                                const SizedBox(width: 12),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _hapusData(item['id'])),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}