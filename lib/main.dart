import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:nearesthospital/location_service.dart';
import 'package:flutter_map/flutter_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seyi Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData _currentLocation;

  Future _getCurrentLocation() async {
    setState(() {});
    _currentLocation = await LocationService().requestLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearest Hospital")),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(),
        tooltip: 'Get Current Location',
        child: const Icon(Icons.pin_drop),
      ),
    );
  }

  Widget _buildBody() {
    Widget child;
    if (_currentLocation != null) {
      child = FlutterMap(
        options: MapOptions(
          center: LatLng(
            _currentLocation?.latitude,
            _currentLocation?.longitude,
          ),
          zoom: 15.0,
          enableScrollWheel: false,
          allowPanningOnScrollingParent: false,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return const Text("© OpenStreetMap contributors");
            },
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  _currentLocation?.latitude,
                  _currentLocation?.longitude,
                ),
                builder: (ctx) => const SizedBox(
                  child: Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      child = const Center(
        child: Text("Please press the icon below"),
      );
    }
    return child;
  }
}
