import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapsFragment extends StatefulWidget {
  const MapsFragment({super.key});

  @override
  _MapsFragmentState createState() => _MapsFragmentState();
}

class _MapsFragmentState extends State<MapsFragment> {
  GoogleMapController? _mapController;
  Marker? _currentLocationMarker;
  BitmapDescriptor? _carIcon;
  String? _nearestVehicleID;
  String? _nearestVehicleCarNo;
  final Location _location = Location();
  LatLng? _currentLocation;

  final Set<Marker> _carMarkers = {};

  @override
  void initState() {
    super.initState();
    // _loadCarIcon();
    _initMarker();
    _checkLocationPermission();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _initMarker() async {
    final markerImage = await _getScaledMarkerImage();

    setState(() {
      _carIcon = markerImage; // Assign the scaled image to your variable
    });
  }

  Future<BitmapDescriptor> _getScaledMarkerImage() async {
    final ByteData bytes = await rootBundle.load('assets/car.png');
    final Uint8List list = bytes.buffer.asUint8List();

    final ui.Codec codec =
        await ui.instantiateImageCodec(list, targetWidth: 90, targetHeight: 90);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  // Check location permission
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    final locationData = await _location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
    _updateCurrentLocationMarker();
    _loadCarLocations();
  }

  // Add or update the current location marker
  void _updateCurrentLocationMarker() {
    if (_currentLocation != null) {
      final marker = Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'Current Location'),
      );
      setState(() {
        _currentLocationMarker = marker;
      });
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
    }
  }

  // Load car locations from API
  Future<void> _loadCarLocations() async {
    if (_currentLocation == null) return;
    final url = '${GlobalApi.BASE_URL}vehicle.aspx';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("vehicle response::::::::::::::::::::::::\n$jsonResponse");
        final carsArray = jsonResponse['Response'] as List<dynamic>;
        print("carsArray response::::::::::::::::::::::::\n$carsArray");
        _handleCarLocations(jsonResponse);
      } else {
        print('Error fetching car locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Handle car locations
  void _handleCarLocations(carsArray) {
    double minDistance = double.infinity;
    String? nearestVehicleID;
    String? nearestVehicleCarNo;

    // Clear existing car markers
    _carMarkers.clear();

    for (int i = 0; i < carsArray['Response'].length; i++) {
      if (carsArray['Response'][i]['CurrentLocation'] != null) {
        print(":::::::::::::::::::::::::${carsArray['Response'][i]['Long']}");
        print(":::::::::::::::::::::::::${carsArray['Response'][i]['Lat']}");
        final carLat = double.tryParse(
            carsArray['Response'][i]['Lat']); // Convert string to double
        final carLng = double.tryParse(carsArray['Response'][i]['Long']);
        final carID = carsArray['Response'][i]['ID'];
        final carNo = carsArray['Response'][i]['REGNO'];
        final carPosition = LatLng(carLat!, carLng!);

        // Add marker for each car
        final carMarker = Marker(
          markerId:
              MarkerId(carID.toString()), // Ensure the marker ID is a string
          position: carPosition,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Car No.: $carNo'),
        );

        _carMarkers.add(carMarker);

        // Calculate distance to current location
        if (_currentLocation != null) {
          final distance = _calculateDistance(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            carLat,
            carLng,
          );
          if (distance < minDistance) {
            minDistance = distance;
            nearestVehicleID = carID.toString(); // Ensure the ID is a string
            nearestVehicleCarNo = carNo;
            GlobalApi.nearId = nearestVehicleID.toString();
          }
        }
      }
    }

    setState(() {
      _nearestVehicleID = nearestVehicleID;
      _nearestVehicleCarNo = nearestVehicleCarNo;

      // Print the nearest vehicle details
      if (_nearestVehicleID != null) {
        print(
            '::::::::::::::::::::::::::::Nearest Vehicle ID: $_nearestVehicleID, Car No: $_nearestVehicleCarNo');
      } else {
        print(':::::::::::::::::::::::::::No nearest vehicle found.');
      }
    });
  }

  // Calculate the distance between two locations
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371000; // Radius of the Earth in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          if (_currentLocationMarker != null) _currentLocationMarker!,
          ..._carMarkers, // Add car markers to the Google Map
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? const LatLng(0, 0),
          zoom: 15,
        ),
        myLocationEnabled: true,
        trafficEnabled: true,
        buildingsEnabled: true,
      ),
    );
  }
}
