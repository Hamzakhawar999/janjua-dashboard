import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final fm.MapController _mapController = fm.MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentLocation = LatLng(37.427961, -122.085749);
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    if (await Geolocator.requestPermission() == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();

    if (!mounted) return;
    setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));

    // ⚡ safe map move
    if (mounted) {
      _mapController.move(_currentLocation, 15);
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() => _searchResults = []);
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&accept-language=en',
    );

    final res = await http.get(url, headers: {"User-Agent": "flutter_map_app"});
    if (!mounted) return;

    if (res.statusCode == 200) {
      setState(() => _searchResults = jsonDecode(res.body));
    }
  }

  void _selectSuggestion(Map<String, dynamic> place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final address = (place['display_name'] as String)
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), ''); // only English

    if (!mounted) return;
    setState(() {
      _currentLocation = LatLng(lat, lon);
      _searchController.text = address;
      _searchResults = [];
    });

    _mapController.move(_currentLocation, 15);

    context.read<Restaurant>().setUserLocation(
          address: address,
          latitude: lat,
          longitude: lon,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Delivery Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _fetchSuggestions,
              decoration: InputDecoration(
                hintText: "Search location...",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final place = _searchResults[i];
                  return ListTile(
                    title: Text(
                      place['display_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSuggestion(place),
                  );
                },
              ),
            ),

          Expanded(
            child: fm.FlutterMap(
              mapController: _mapController,
              options: fm.MapOptions(center: _currentLocation, zoom: 14),
              children: [
                fm.TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.my_auth',
                ),
                fm.MarkerLayer(
                  markers: [
                    fm.Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Confirm Location"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
