import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 
import 'dart:io';

import '../helpers/database_helper.dart';

class EksplorScreen extends StatefulWidget {
  const EksplorScreen({super.key});

  @override
  State<EksplorScreen> createState() => _EksplorScreenState();
}

class _EksplorScreenState extends State<EksplorScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final MapController _mapController = MapController();
  
  List<Map<String, dynamic>> _destinasiData = [];
  LatLng? _currentLocation;
  bool _isLoading = true;

  final LatLng _defaultLocation = const LatLng(-8.1699975, 113.7214757);

  @override
  void initState() {
    super.initState();
    _inisialisasiPeta();
  }

  Future<void> _inisialisasiPeta() async {
    await _getCurrentLocation(isInitialLoad: true); 
    await _loadDestinasi();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation({bool isInitialLoad = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      if (!isInitialLoad) {
        _mapController.move(_currentLocation!, 15.0);
      }
    }
  }

  Future<void> _loadDestinasi() async {
    final data = await _dbHelper.getAllDestinasi();
    if (mounted) {
      setState(() {
        _destinasiData = data;
      });
    }
  }

  void _tampilkanInfoLokasi(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              item['image_path'] != null && item['image_path'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(item['image_path']),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                    ),
              const SizedBox(height: 18),
              
              Text(
                item['nama_tempat'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['deskripsi'].toString().isEmpty 
                    ? 'Tidak ada deskripsi detail.' 
                    : item['deskripsi'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eksplorasi Peta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SizedBox.expand(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? _defaultLocation,
                initialZoom: 13.0, // Zoom sedikit dijauhkan agar titik tersebar terlihat
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mapm',
                ),
                MarkerLayer(
                  markers: [
                    // 1. PIN LOKASI KAMU (Warna Merah Radar)
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                    
                    // 2. PIN SEMUA DESTINASI DARI DATABASE (Ikon Poin Navigasi Biru)
                    ..._destinasiData.map((item) {
                      // LOGIKA BARU: Tangani data lama yang bernilai 0.0
                      double lat = item['latitude'];
                      double lng = item['longitude'];
                      
                      // Jika koordinatnya 0.0 (data sebelum fitur geocoding)
                      if (lat == 0.0 && lng == 0.0) {
                        // Geser sedikit posisi default Jember berdasarkan ID agar tidak menumpuk 100%
                        lat = -8.1699975 + (item['id'] * 0.001);
                        lng = 113.7214757 + (item['id'] * 0.001);
                      }

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 50,
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _tampilkanInfoLokasi(item),
                          child: const Icon(
                            Icons.location_on, // Poin navigasi bawaan Flutter
                            color: Colors.blueAccent,
                            size: 45,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'btn_refresh',
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.refresh, color: Colors.blueAccent),
              onPressed: () {
                _loadDestinasi();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Peta diperbarui!'), duration: Duration(seconds: 1)),
                );
              },
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'btn_gps',
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () => _getCurrentLocation(), 
            ),
          ],
        ),
      ),
    );
  }
}