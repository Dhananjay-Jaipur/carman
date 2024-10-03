import 'dart:convert';
import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class Proceed extends StatefulWidget {
  const Proceed({super.key});

  @override
  _ProceedState createState() => _ProceedState();
}

class _ProceedState extends State<Proceed> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  final Set<Marker> _markers = {};
  bool isTablet = false;
  double textSize = 15;
  LatLng? carLocation;
  String? carNo;
  String? vehicleID;
  String? ModelName;

  @override
  void initState() {
    super.initState();

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
      textSize = isTablet ? Get.width * 0.025 : 15;
    });

    _getUserLocation();
  }

  void _getUserLocation() async {
    Location location = Location();

    // Request location permissions
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return; // Location service not enabled
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Permission not granted
      }
    }

    // Get the current location
    LocationData locationData = await location.getLocation();

    if (mounted) {
      setState(() {
        userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
      _loadCarLocations(
          locationData); // Load car locations after getting user location
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (userLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation!, 15),
      );
    }
  }

  Future<void> _loadCarLocations(LocationData currentLocation) async {
    String apiUrl = "${GlobalApi.BASE_URL}vehicle.aspx";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Clear existing markers
        _markers.clear();

        for (var car in data['Response']) {
          //print(car);

          carLocation = LatLng(car['Lat'], car['Long']);
          carNo = car['REGNO'];
          vehicleID = car['ID'];
          ModelName = car['ModelName'];

          // Add marker for each car
          _markers.add(Marker(
            markerId: MarkerId(vehicleID!),
            position: carLocation!,
            infoWindow: InfoWindow(title: "Car No.: $carNo"),
            icon: BitmapDescriptor.defaultMarker,
          ));
        }

        // Update markers on the map
        setState(() {});
      } else {
        print("Failed to load car locations");
      }
    } catch (e) {
      print("Error loading car locations: $e");
    }
  }

  Widget _buildText(String text,
      {FontWeight fontWeight = FontWeight.w700, bool isTablet = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 35 : 25,
        fontWeight: fontWeight,
        color: Colors.black,
      ),
    );
  }

  Widget displayRatingBar({required double rating, double itemSize = 20.0}) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: itemSize,
      direction: Axis.horizontal,
    );
  }

  Widget onCallTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              CupertinoIcons.back,
              size: isTablet ? 35 : 25,
            ),
          ),
          InkWell(
            onTap: () {},
            child: Image.asset(
              "assets/emergency-button.png",
              width: isTablet ? 45 : 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget onCall() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
      child: SizedBox(
        height: Get.height * 0.35,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xffd2e5df),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Estimated time for car to reach:  ",
                      style: TextStyle(
                        fontSize: isTablet ? 25 : 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "15 min",
                      style: TextStyle(
                        fontSize: isTablet ? 25 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xffd2e5df),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "OTP for this trip",
                      style: TextStyle(
                        fontSize: isTablet ? 25 : 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "6499",
                      style: TextStyle(
                        fontSize: isTablet ? 25 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/driver.png",
                          width: isTablet ? 50 : 40,
                        ),
                        SizedBox(
                          width: Get.width * 0.05,
                        ),
                        Column(
                          children: [
                            Text(
                              "Driver name",
                              style: TextStyle(
                                fontSize: isTablet ? 35 : 25,
                                color: Colors.black,
                              ),
                            ),
                            displayRatingBar(rating: 3),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "$carNo",
                          style: TextStyle(
                            fontSize: isTablet ? 30 : 20,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "$ModelName",
                          style: TextStyle(
                            fontSize: isTablet ? 30 : 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "📞 8209765434",
                      style: TextStyle(
                        fontSize: isTablet ? 35 : 25,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showMap() {
    return Column(
      children: [
        onCallTime(),
        Flexible(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: userLocation ??
                  const LatLng(0, 0), // Default to (0,0) if user location is null
              zoom: 15.0,
            ),
            markers: _markers, // Add car markers on the map
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(33),
              topRight: Radius.circular(33),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: Get.height * 0.03,
              ),
              onCall(),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.only(left: 17, top: 10, right: 20),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset("assets/logo.png", height: double.infinity),
            ),
            title: _buildText("CARMAN", isTablet: isTablet),
            centerTitle: false,
            actions: [
              Text(
                "👤 Official",
                style: TextStyle(
                  fontSize: isTablet ? 24 : 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      body: userLocation == null
          ? Center(child: Image.asset('assets/loading.gif'))
          : showMap(),
    );
  }
}
