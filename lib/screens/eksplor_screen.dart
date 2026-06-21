import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      

class EksplorScreen extends StatelessWidget {
  const EksplorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Peta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SizedBox.expand(
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-8.1699975, 113.7214757), // Koordinat Area Polije/Jember
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mapm',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(-8.1699975, 113.7214757),
                  width: 40,
                  height: 40,
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}