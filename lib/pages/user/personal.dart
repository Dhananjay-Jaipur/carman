import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Peraonal extends StatefulWidget {
  const Peraonal({super.key});

  @override
  _PeraonalState createState() => _PeraonalState();
}

class _PeraonalState extends State<Peraonal> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  bool isPooledSelected = true;
  int _selectedBooking = 1;

  String userType = '2'; // Default is 'employee'
  var vendorList = [];
  String? selectedVendor;
  String? selectedVendorId;

  bool isTablet = false;
  double textSize = 15;

  @override
  void initState() {
    super.initState();

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;

      textSize = isTablet ? Get.width * 0.025 : 18;
    });

    _getUserLocation();
    fetchVendorList(); // Fetch vendor list when the widget initializes
  }

  DateTime selectedDateFROM = DateTime.now();
  TimeOfDay selectedTimeFROM = TimeOfDay.now();

  void changeFromDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDateFROM,
    firstDate: DateTime.now(),  // Prevent selection of past dates
    lastDate: DateTime(2040),
  );

  if (picked != null && picked != selectedDateFROM) {
    setState(() {
      selectedDateFROM = picked;
    });
  }
}

  void changeFromTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeFROM,
    );

    if (picked != null) {
      setState(() {
        selectedTimeFROM = picked;
      });
    }
  }

  Future<void> fetchVendorList() async {
    final url = '${GlobalApi.BASE_URL}GetVendorsList.aspx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched list: $data");

      for (var vendor in data["Response"]) {
        vendorList.add({
          "name": vendor["Name"],
        });
      }
      setState(() {
        // Optionally insert a placeholder for the dropdown
        vendorList.insert(0, {"name": "Select Vendor"});
      });
    } else {
      print("Failed to fetch list: ${response.body}");
    }
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

    // Use mounted check before calling setState
    if (mounted) {
      setState(() {
        userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Move camera to user's location if available
    if (userLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(userLocation!),
      );
    }
  }

  Widget onCallTime() {
    return Container(
      color: const Color(0xffd2e5df),
      padding: const EdgeInsets.only(top: 6),
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          const Icon(CupertinoIcons.calendar_badge_plus),
          const SizedBox(
            width: 20,
          ),
          Text("From ",
              style: TextStyle(
                fontSize: textSize / 1.3,
              )),
          InkWell(
            onTap: () {
              changeFromDate(context);
            },
            child: Text(
              "${DateFormat('dd-MMM-yyyy').format(selectedDateFROM)}  ",
              style: TextStyle(
                  fontSize: textSize / 1.3, fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              changeFromTime(context);
            },
            child: Text(
              selectedTimeFROM.toString().substring(10, 15),
              style: TextStyle(
                  fontSize: textSize / 1.3, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget ToggleButtons() {
    return SizedBox(
      width: Get.width * 0.8, // Set the desired width

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround, // Shrink the row to fit buttons
        children: [
          Expanded(
            // Ensure button fills half of the container
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (isPooledSelected)
                    ? Colors.green
                    : Colors.white, // Change color on selection
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      33), // No rounded corners for individual buttons
                ),
              ),
              onPressed: () {
                setState(() {
                  isPooledSelected = true;
                });
              },
              child: Text(
                "POOLED",
                style: TextStyle(
                  fontSize: textSize,
                  color: (isPooledSelected) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            // Ensure button fills half of the container
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (!isPooledSelected)
                    ? Colors.green
                    : Colors.white, // Change color on selection
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      33), // No rounded corners for individual buttons
                ),
              ),
              onPressed: () {
                setState(() {
                  isPooledSelected = false;
                });
              },
              child: Text(
                "ON CALL",
                style: TextStyle(
                  fontSize: textSize,
                  color: (!isPooledSelected) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget DropDown(test) {
    return Container(
      width: Get.width * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 2), // Add border
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedVendor,
          hint: Text(
            "    $test",
            style: TextStyle(
              fontSize: textSize,
            ),
          ),
          items: vendorList.map((vendor) {
            return DropdownMenuItem<String>(
              value: vendor["name"],
              child: Text(vendor["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedVendor = value;
              selectedVendorId = vendorList
                  .firstWhere((vendor) => vendor["name"] == value)["id"]
                  .toString();
            });
          },
        ),
      ),
    );
  }

  Widget CustomTextField(text) {
    return Container(
      width: double.infinity, // Same width as DropDown
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2), // Add border
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "$text", // Placeholder text
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 10), // Padding inside the TextField
        ),
      ),
    );
  }

  Widget CustomRadioButton(a, b) {
    return SizedBox(
      width: double.infinity, // or a specific width like 300.0
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            // Wrap each RadioListTile with Expanded
            child: RadioListTile<int>(
              title: Text(
                '$a',
                style: TextStyle(
                  fontSize: textSize,
                ),
              ),
              value: 1, // Assign a value of 1 to this option
              groupValue:
                  _selectedBooking, // Use _selectedBooking to track the selected option
              onChanged: (value) {
                setState(() {
                  _selectedBooking =
                      value!; // Update _selectedBooking when option 1 is selected
                });
              },
            ),
          ),
          Expanded(
            // Wrap each RadioListTile with Expanded
            child: RadioListTile<int>(
              title: Text(
                '$b',
                style: TextStyle(
                  fontSize: textSize,
                ),
              ), // Display the title for option 2
              value: 2, // Assign a value of 2 to this option
              groupValue:
                  _selectedBooking, // Use _selectedBooking to track the selected option
              onChanged: (value) {
                setState(() {
                  _selectedBooking =
                      value!; // Update _selectedBooking when option 2 is selected
                });
              },
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
        height: Get.height * 0.45,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: Colors.grey, width: 2), // Add border
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedVendor,
                    hint: Text(
                      "Location",
                      style: TextStyle(
                        fontSize: textSize,
                      ),
                    ),
                    items: vendorList.map((vendor) {
                      return DropdownMenuItem<String>(
                        value: vendor["name"],
                        child: Text(vendor["name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVendor = value;
                        selectedVendorId = vendorList
                            .firstWhere(
                                (vendor) => vendor["name"] == value)["id"]
                            .toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity, // or a specific width like 300.0
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Booking for",
                      style: TextStyle(
                          fontSize: textSize / 1.2,
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      // Wrap each RadioListTile with Expanded
                      child: RadioListTile<int>(
                        title: Text(
                          'Self',
                          style: TextStyle(
                            fontSize: textSize / 1.6,
                          ),
                        ),
                        value: 1, // Assign a value of 1 to this option
                        groupValue:
                            _selectedBooking, // Use _selectedBooking to track the selected option
                        onChanged: (value) {
                          setState(() {
                            _selectedBooking =
                                value!; // Update _selectedBooking when option 1 is selected
                          });
                        },
                      ),
                    ),
                    Expanded(
                      // Wrap each RadioListTile with Expanded
                      child: RadioListTile<int>(
                        title: Text(
                          'Other',
                          style: TextStyle(
                            fontSize: textSize / 1.6,
                          ),
                        ), // Display the title for option 2
                        value: 2, // Assign a value of 2 to this option
                        groupValue:
                            _selectedBooking, // Use _selectedBooking to track the selected option
                        onChanged: (value) {
                          setState(() {
                            _selectedBooking =
                                value!; // Update _selectedBooking when option 2 is selected
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              (_selectedBooking == 1)
                  ? const SizedBox()
                  : Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextField("Name"),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextField("Mobile No."),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextField("Email"),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
              Container(
                color: const Color.fromARGB(255, 211, 209, 209),
                padding: const EdgeInsets.all(8),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pick up",
                      style: TextStyle(
                          fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.05,
                    ),
                    DropDown("Select"),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: const Color.fromARGB(255, 211, 209, 209),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Vehicle Type",
                      style: TextStyle(
                          fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    DropDown("Select"),
                  ],
                ),
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              SizedBox(
                width: Get.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33),
                      ),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "PROCEED",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: textSize * 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
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
              target: userLocation!,
              zoom: 15.0,
            ),
            markers: {
              if (userLocation != null)
                Marker(
                  markerId: const MarkerId('user_location'),
                  position: userLocation!,
                ),
            },
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xffd2e5df), // Set your desired background color
            borderRadius: BorderRadius.only(
              topLeft:
                  Radius.circular(33), // Set the radius for the top left corner
              topRight: Radius.circular(
                  33), // Set the radius for the top right corner
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
    // Directly return GoogleMap widget
    return userLocation == null
        ? Center(child: Image.asset('assets/loading.gif'))
        : showMap();
  }
}
