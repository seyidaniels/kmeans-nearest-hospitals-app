import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';

import 'hospital_model.dart';
import 'location_service.dart';

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
  final List<Hospital> _hospitals = [];

  Future _getCurrentLocation() async {
    _currentLocation = await LocationService().requestLocation();
    setState(() {});
    if (_currentLocation != null) {
      _getHosptials();
    }
  }

  Future _getHosptials() async {
    Uri uri = Uri.parse("https://seyicluster-api.herokuapp.com/predict");

    final http.Response res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "X_gps_longitude": _currentLocation.longitude,
        "X_gps_latitude": _currentLocation.latitude,
      }),
    );

    if (res.statusCode == 200) {
      String str = res.body;

      Map mapData = json.decode(json.decode(str));

      int resLength = mapData['facility_name'].length;

      List facilityNames = mapData['facility_name'].values.toList();
      List facilityTypes = mapData['facility_type'].values.toList();
      List facilityCommunities = mapData['community'].values.toList();
      List gpsLongitudes = mapData['X_gps_longitude'].values.toList();
      List gpsLatitudes = mapData['X_gps_latitude'].values.toList();

      for (int i = 0; i < resLength; i++) {
        _hospitals.add(Hospital(
          name: facilityNames[i],
          type: facilityTypes[i],
          community: facilityCommunities[i],
          longitude: gpsLongitudes[i],
          latitude: gpsLatitudes[i],
        ));
      }
    }

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
          zoom: 13.0,
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
              ..._hospitals
                  .map(
                    (e) => Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(
                        e.latitude,
                        e.longitude,
                      ),
                      builder: (ctx) => const SizedBox(
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
