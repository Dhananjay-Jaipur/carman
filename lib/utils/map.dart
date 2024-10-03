import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:math'; // For calculations

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  Marker? currentLocationMarker;
  BitmapDescriptor? carIcon;
  String? nearestVehicleID;
  String? nearestVehicleCarNo;
  List? vehicles;
  var vehicleNames;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _getUserLocation();
    _loadCarLocations();
    fetchVehicles();
  }

  Future<void> _loadCarIcon() async {
    // Load the car icon from assets
    final Uint8List markerIcon =
        await _getBytesFromAsset('assets/car.png', 100);
    carIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    // ignore: unnecessary_nullable_for_final_variable_declarations
    var codec = await instantiateImageCodec(bytes, targetWidth: width);
    final FrameInfo fi = await codec.getNextFrame();
    final ByteData? resizedData =
        await fi.image.toByteData(format: ImageByteFormat.png);
    return resizedData!.buffer.asUint8List();
  }

  Future<void> _getUserLocation() async {
    Location location = Location();

    // Request location permissions
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the user's location
    LocationData locationData = await location.getLocation();
    setState(() {
      userLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    _refreshMap();
  }

  Future<void> _refreshMap() async {
    if (userLocation == null) return;

    // Update the marker for the user's current location
    if (currentLocationMarker != null) {
      setState(() {
        currentLocationMarker = null; // Remove previous marker
      });
    }

    Marker marker = Marker(
      markerId: MarkerId('currentLocation'),
      position: userLocation!,
      infoWindow: InfoWindow(title: 'Current Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    setState(() {
      currentLocationMarker = marker; // Add the current location marker
    });

    // Move the camera to the user's location
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation!, 15));

    // Load car locations after updating the current location
    await _loadCarLocations();
  }

  Future<void> fetchVehicles() async {
  final url = '${GlobalApi.BASE_URL}vehicle.aspx'; // Your actual base URL

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the JSON response without type parameters
      final data = jsonDecode(response.body);

      // Extract the vehicle data directly into a list
      vehicles = List<Map>.from(data['Response']);

      // Prepare the list of vehicle markers
      List<Marker> vehicleMarkers = vehicles!.map((vehicle) {
        double latitude = double.parse(vehicle['Lat']);
        double longitude = double.parse(vehicle['Long']);
        String vehicleID = vehicle['ID'].toString(); // Ensure ID is a string
        String carNo = vehicle['REGNO'];
        String modelName = vehicle['ModelName'];

        LatLng vehicleLocation = LatLng(latitude, longitude);

        return Marker(
          markerId: MarkerId(vehicleID), // Use the vehicle ID as the marker ID
          position: vehicleLocation,
          infoWindow: InfoWindow(
            title: modelName,
            snippet: 'Reg No: $carNo', // Show registration number in the snippet
          ),
          icon: BitmapDescriptor.defaultMarker, // You can use a custom icon if needed
        );
      }).toList();

      // Update the state to refresh the map with vehicle markers
      setState(() {
        vehicles = vehicleMarkers; // Store the markers in a state variable
      });
    } else {
      throw Exception('Failed to load vehicles');
    }
  } catch (error) {
    print('Error fetching vehicles: $error');
    // Handle the error (e.g., show a message)
  }
}

  Future<void> _loadCarLocations() async {
    String url =
        '${GlobalApi.BASE_URL}vehicle.aspx'; // Replace with your API URL

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        vehicles = data['Response'];

        double minDistance = double.infinity;
        nearestVehicleID = null;
        nearestVehicleCarNo = null;

        for (var vehicle in vehicles!) {
          double latitude = double.parse(vehicle['Lat']);
          double longitude = double.parse(vehicle['Long']);
          String vehicleID = vehicle['ID'];
          String carNo = vehicle['REGNO'];

          LatLng carLocation = LatLng(latitude, longitude);

          Marker marker = Marker(
            markerId: MarkerId(vehicleID),
            position: carLocation,
            infoWindow: InfoWindow(title: 'Car No.: $carNo'),
            icon: carIcon ?? BitmapDescriptor.defaultMarker,
          );

          setState(() {
            // Add the vehicle marker to the map
            // GoogleMap doesn't have a method to add a marker directly.
            // Instead, maintain a list of markers and update the state.
          });

          // Calculate distance to find the nearest vehicle
          if (userLocation != null) {
            double distance = _calculateDistance(
              userLocation!.latitude,
              userLocation!.longitude,
              latitude,
              longitude,
            );

            if (distance < minDistance) {
              minDistance = distance;
              nearestVehicleID = vehicleID;
              nearestVehicleCarNo = carNo;
            }
          }
        }

        if (nearestVehicleID != null) {
          print('Nearest Vehicle ID: $nearestVehicleID');
        } else {
          print('No nearest vehicle found.');
        }
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (error) {
      print('Error fetching vehicles: $error');
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                _refreshMap(); // Refresh map when created
              },
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: userLocation!,
                zoom: 15,
              ),
              markers: {
                if (currentLocationMarker != null) currentLocationMarker!,
                // Add vehicle markers here if you maintain a list
              },
            ),
    );
  }
}
