import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carman/utils/map.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _selectedBooking = 1;
  var _selectedDistance = 1;

  bool isPooledSelected = true;

  final myStorage = Hive.box('myStorage');

  var vendorList = [];

  String? pickupLoc;
  String? pickupLocId;

  String? dropLoc;
  String? dropLocId;

  String? vihcel;

  bool isTablet = false;
  double textSize = 15;

  List vehicles = [];
  List? vehicleNames;

  @override
  void initState() {
    super.initState();

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;

      textSize = isTablet ? Get.width * 0.025 : 18;
    });

    fetchPickupLists();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    final url = '${GlobalApi.BASE_URL}vehicle.aspx'; // Your actual base URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON response without type parameters
        final data = jsonDecode(response.body);

        // Extract the vehicle data directly into a list
        vehicles = List.from(data['Response']); // Store it in a dynamic list

        vehicleNames = vehicles.map((vehicle) {
          return vehicle['ModelName']; // Accessing vehicle name
        }).toList();

        // Update the state to refresh the map with vehicle markers
        setState(() {});
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (error) {
      print('Error fetching vehicles: $error');
      // Handle the error (e.g., show a message)
    }
  }

  DateTime selectedDateTO = DateTime.now();
  TimeOfDay selectedTimeTO = TimeOfDay.now();

  DateTime selectedDateFROM = DateTime.now();
  TimeOfDay selectedTimeFROM = TimeOfDay.now();

  void changeFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFROM,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(2040),
    );

    if (picked != null && picked != selectedDateFROM) {
      setState(() {
        selectedDateFROM = picked;
      });
    }
  }

  void changeToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTO,
      firstDate: DateTime.now(), // Prevent selection of past dates
      lastDate: DateTime(2040),
    );

    if (picked != null && picked != selectedDateTO) {
      setState(() {
        selectedDateTO = picked;
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

  void changeToTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeTO,
    );

    if (picked != null) {
      // Get current time for comparison
      final now = TimeOfDay.now();

      // If the selected date is today, prevent selecting past time
      if (selectedDateTO == DateTime.now().toLocal()) {
        if (picked.hour > now.hour ||
            (picked.hour == now.hour && picked.minute >= now.minute)) {
          setState(() {
            selectedTimeTO = picked;
          });
        } else {
          // Show an alert or handle the invalid selection
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot select a past time')),
          );
        }
      } else {
        // If the selected date is in the future, allow any time
        setState(() {
          selectedTimeTO = picked;
        });
      }
    }
  }

  Future<void> fetchPickupLists() async {
    final url = '${GlobalApi.BASE_URL}pickuplocation.aspx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched list: $data");

      for (var vendor in data["Response"]) {
        vendorList.add({
          "id": vendor["id"],
          "Location": vendor["Location"],
        });
      }
      setState(() {
        // Optionally insert a placeholder for the dropdown
        vendorList.insert(0, {"Location": "Select"});
      });
    } else {
      print("Failed to fetch list: ${response.body}");
    }
  }

  // void postData() async {
  //   // Check if selected locations are null
  //   if (pickupLoc == null) {
  //     myToast(title: "Please select a Pickup Location");
  //     return;
  //   }

  //   if (dropLoc == null) {
  //     myToast(title: "Please select a Drop Location");
  //     return;
  //   }

  //   // Log the selected locations
  //   print("Location ID 1: $pickupLoc");
  //   print("Location ID 2: $dropLoc");

  //   // Replace with your actual endpoint
  //   String url = "${GlobalApi.BASE_URL}poolledbooking.aspx";

  //   try {
  //     // Assuming you have methods to get vehicleID and carNo from another screen
  //     vehicleID = await getVehicleID(); // Implement this method
  //     carNo = await getCarNo(); // Implement this method

  //     // Prepare request data
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: {
  //         'userid':
  //             myStorage.get('id'), // Replace with your user ID fetching logic
  //         'PickTime': selectedTimeFROM,
  //         'PickUpLocation': pickupLoc,
  //         'DropLocation': dropLoc,
  //         'VehicleID': vehicleID ?? "null",
  //       },
  //     );

  //     // Handle the response
  //     if (response.statusCode == 200) {
  //       print("Server Response: ${response.body}");
  //       myToast(title: "Booking successful");

  //       // Navigate to the next screen
  //       Get.off(() => BookingSubmited());
  //     } else {
  //       myToast(title: "Booking failed");
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //     myToast(title: "An error occurred");
  //   }
  // }

  void myToast(String message, {required String title}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget PooledTime() {
    return Container(
      color: const Color(0xffd2e5df),
      padding: const EdgeInsets.only(top: 6),
      width: double.infinity,
      child: Wrap(
        children: [
          const Icon(CupertinoIcons.calendar_badge_plus),
          const SizedBox(
            width: 20,
          ),
          Text("From ",
              style: TextStyle(
                fontSize: textSize / 1.3,
              )),
          Text(
            "${DateFormat('dd-MMM-yyyy').format(DateTime.now())}  ${DateFormat('HH:mm  a').format(DateTime.now())}",
            style: TextStyle(
                fontSize: textSize / 1.3, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: double.infinity,
          )
        ],
      ),
    );
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
            width: 20,
          ),
          Text("To ",
              style: TextStyle(
                fontSize: textSize / 1.3,
              )),
          InkWell(
            onTap: () {
              changeToDate(context);
            },
            child: Text(
              "${DateFormat('dd-MMM-yyyy').format(selectedDateTO)}  ",
              style: TextStyle(
                  fontSize: textSize / 1.3, fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              changeToTime(context);
            },
            child: Text(
              selectedTimeTO.toString().substring(10, 15),
              style: TextStyle(
                  fontSize: textSize / 1.3, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget ToggleButtons() {
    return SizedBox(
      width: Get.width * 0.8, // Set the desired width

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Shrink the row to fit buttons
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
          SizedBox(
            width: Get.width * 0.05,
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

  Widget Pooled() {
    return Container(
      // height: Get.height * 0.25,
      child: Column(
        children: [
          SizedBox(
            height: Get.height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Pickup Location",
                    style: TextStyle(
                        fontSize: textSize / 1.2, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey, width: 2), // Add border
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: pickupLoc,
                        hint: Text(
                          "    Select",
                          style: TextStyle(
                            fontSize: textSize,
                          ),
                        ),
                        items: vendorList.map((vendor) {
                          return DropdownMenuItem<String>(
                            value: vendor["Location"],
                            child: Text(vendor["Location"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            pickupLoc = value;
                            pickupLocId = vendorList
                                .firstWhere((vendor) =>
                                    vendor["Location"] == value)["id"]
                                .toString();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Drop Location",
                    style: TextStyle(
                        fontSize: textSize / 1.2, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.grey, width: 2), // Add border
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dropLoc,
                        hint: Text(
                          "    Select",
                          style: TextStyle(
                            fontSize: textSize,
                          ),
                        ),
                        items: vendorList.map((vendor) {
                          return DropdownMenuItem<String>(
                            value: vendor["Location"],
                            child: Text(vendor["Location"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            dropLoc = value;
                            dropLocId = vendorList
                                .firstWhere((vendor) =>
                                    vendor["Location"] == value)["id"]
                                .toString();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
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
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget onCall() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
      child: SizedBox(
        height: Get.height * 0.4,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: _selectedDistance,
                            onChanged: (value) {
                              setState(() {
                                _selectedDistance = value!;
                              });
                            },
                          ),
                          const SizedBox(
                              width: 4), // Adjust this width to control the gap
                          Text(
                            'Within 70km',
                            style: TextStyle(
                              fontSize: textSize / 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 2,
                            groupValue: _selectedDistance,
                            onChanged: (value) {
                              setState(() {
                                _selectedDistance = value!;
                              });
                            },
                          ),
                          const SizedBox(
                              width: 4), // Adjust this width to control the gap
                          Text(
                            'Above 70km',
                            style: TextStyle(
                              fontSize: textSize / 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                    value: pickupLoc,
                    hint: Text(
                      "Location",
                      style: TextStyle(
                        fontSize: textSize,
                      ),
                    ),
                    items: vendorList.map((vendor) {
                      return DropdownMenuItem<String>(
                        value: vendor["Location"],
                        child: Text(vendor["Location"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        pickupLoc = value;
                        pickupLocId = vendorList
                            .firstWhere(
                                (vendor) => vendor["Location"] == value)["id"]
                            .toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity, // or a specific width like 300.0
                child: Row(
                  children: <Widget>[
                    Text(
                      "Booking for",
                      style: TextStyle(
                          fontSize: textSize / 1.2,
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: _selectedBooking,
                            onChanged: (value) {
                              setState(() {
                                _selectedBooking = value!;
                              });
                            },
                          ),
                          const SizedBox(
                              width: 4), // Adjust this width to control the gap
                          Text(
                            'Self',
                            style: TextStyle(
                              fontSize: textSize / 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<int>(
                            value: 2,
                            groupValue: _selectedBooking,
                            onChanged: (value) {
                              setState(() {
                                _selectedBooking = value!;
                              });
                            },
                          ),
                          const SizedBox(
                              width: 4), // Adjust this width to control the gap
                          Text(
                            'Other',
                            style: TextStyle(
                              fontSize: textSize / 1.5,
                            ),
                          ),
                        ],
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
                color: const Color.fromARGB(255, 236, 244, 242),
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
                    Container(
                      width: Get.width * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey, width: 2), // Add border
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: pickupLoc,
                          hint: Text(
                            "    Select",
                            style: TextStyle(
                              fontSize: textSize,
                            ),
                          ),
                          items: vendorList.map((vendor) {
                            return DropdownMenuItem<String>(
                              value: vendor["Location"],
                              child: Text(vendor["Location"]),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              pickupLoc = value;
                              pickupLocId = vendorList
                                  .firstWhere((vendor) =>
                                      vendor["Location"] == value)["id"]
                                  .toString();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: const Color.fromARGB(255, 236, 244, 242),
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
                    
                    Container(
                      width: Get.width * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey, width: 2), // Add border
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: pickupLoc,
                          hint: Text(
                            "    Select",
                            style: TextStyle(
                              fontSize: textSize,
                            ),
                          ),
                          items: vehicleNames!
                              .map<DropdownMenuItem<String>>((vehicleName) {
                            // Specify the type
                            return DropdownMenuItem<String>(
                              value:
                                  vehicleName, // Set the value to vehicle name
                              child:
                                  Text(vehicleName), // Display the vehicle name
                            );
                          }).toList(), // Convert to a list
                          onChanged: (value) {
                            setState(() {
                              pickupLoc = value; // Update selected location

                              // Get ID based on selected vehicle name
                              pickupLocId = vehicles
                                      .firstWhere(
                                          (vehicle) =>
                                              vehicle['ModelName'] == value,
                                          orElse: () => {'ID': null})['ID']
                                      ?.toString() ??
                                  ''; // Safely access ID
                            });
                          },
                        ),
                      ),
                    ),



                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTextField("Purpose/Remark"),
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
        (isPooledSelected) ? PooledTime() : onCallTime(),
        Map(),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xffd2e5df),
            // color: Color(0xffd8ebff),
            // color: Color(0xffc3e2f6),
          ),
          child: Column(
            children: [
              SizedBox(
                height: Get.height * 0.03,
              ),
              ToggleButtons(),
              const SizedBox(
                height: 10,
              ),
              (isPooledSelected) ? Pooled() : onCall(),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Directly return GoogleMap widget
    return showMap();
  }
}
