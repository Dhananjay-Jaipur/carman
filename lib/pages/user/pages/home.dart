import 'dart:convert';
import 'package:carman/utils/splashScreen.dart';
import 'package:carman/utils/toast.dart';
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
  TextEditingController manualPackageFrom = TextEditingController();
  TextEditingController manualPackageTo = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController otherLoc = TextEditingController();
  TextEditingController purpose = TextEditingController();

  var _selectedBooking = 1;
  var _selectedDistance = 1;

  bool isPooledSelected = true;

  final myStorage = Hive.box('myStorage');

  var vendorList = [];
  var vendorListAbove = [];

  var vehicles = [];
  var packageList = [];
  var pickupList = [];

  List vehiclesAbove = [];
  var packageListAbove = [];
  var pickupListAbove = [];


  String? oncallLoc = "Select";
  String? oncallLocId;

  String? packageName = "Package";
  String? packageId;

  String? pickupLoc;
  String? pickupLocId;

  String? Vichelname = "Select";
  String? VichelId;

  String? dropLoc;
  String? dropLocId;

  String? vihcel;

  bool isTablet = false;
  double textSize = 15;

  @override
  void initState() {
    super.initState();

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;

      textSize = isTablet ? Get.width * 0.025 : 18;
    });


    fetchPickupLocation();
    fetchpackage();
    fetchVehicles();

    // fetchPickupLocationAbove();
    // fetchpackageAbove();
    // fetchVehiclesAbove();
  }

  Future<void> fetchVehicles() async {
    final within = '${GlobalApi.BASE_URL}vehicle.aspx';
    final above = '${GlobalApi.BASE_URL}vehicle.aspx?a=1';

    final url = (_selectedDistance == 1) ? within : above;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON response without type parameters
        final data = jsonDecode(response.body);

        // // Extract the vehicle data directly into a list
        // vehicles = List.from(data['Response']);

        for (var vendor in data["Response"]) {
          vehicles.add({
            "ID": vendor["ID"],
            "ModelName": vendor["ModelName"],
          });
        }

        // vehicleNames = vehicles.map((vehicle) {
        //   return vehicle['ModelName']; // Accessing vehicle name
        // }).toList();

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

  Future<void> fetchpackage() async {
    final url = '${GlobalApi.BASE_URL}getpackage.aspx?a=3';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched list: $data");

      for (var vendor in data["Response"]) {
        packageList.add({
          "PackageID": vendor["PackageID"],
          "PackageName": vendor["PackageName"],
        });
      }

      setState(() {
        // Optionally insert a placeholder for the dropdown
        packageList.insert(0, {"PackageName": "Other"});
      });
    } else {
      print("Failed to fetch list: ${response.body}");
    }
  }

  Future<void> fetchPickupLocation() async {
    final url = '${GlobalApi.BASE_URL}getoncallpicklocationvehicles.aspx?a=0';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched list: $data");

      for (var vendor in data["Response"]) {
        pickupList.add({
          "id": vendor["id"],
          "Location": vendor["Location"],
        });
      }
      setState(() {
        // Optionally insert a placeholder for the dropdown
        pickupList.insert(0, {"Location": "Other"});
      });
    } else {
      print("Failed to fetch list: ${response.body}");
    }
  }

  Future<void> onCallBooking() async {
    String url = '${GlobalApi.BASE_URL}oncallbookingdetails.aspx';

    Map<String, String> params = {
      'userid': myStorage.get('id').toString(),
      'bookingtype': '1',
      'PickUpLocation':
          (oncallLoc != 'Other') ? oncallLoc! : otherLoc.text.toString(),
      'VehicleID': GlobalApi.nearId,
      'PackageID': (packageName != 'Other')
          ? packageName!
          : "${manualPackageFrom.text}-${manualPackageTo.text}",
      'FromTime':
          "${DateFormat('dd-MMM-yyyy').format(selectedDateFROM)} ${selectedTimeFROM.toString().substring(10, 15)}",
      'ToTime':
          "${DateFormat('dd-MMM-yyyy').format(selectedDateFROM)} ${selectedTimeFROM.toString().substring(10, 15)}",
      'remarks': purpose.text,
      'selfother': (_selectedBooking == 1) ? '0' : '1',
      'name': (_selectedBooking == 1) ? '' : name.text,
      'phone': (_selectedBooking == 1) ? '' : mobile.text,
      'email': (_selectedBooking == 1) ? '' : email.text,
    };

    try {
      var response = await http.post(Uri.parse(url), body: params);

      print("Body:::::: ${params}");

      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");
        myToast(title: "Booking successful");

        setState(() {
          Get.off(() => const BookingSubmited());
        });
      } else {
        throw Exception(
            'Failed to cancel approve booking. Status Code: ${response.statusCode}');
      }
      //   myToast(title: "Booking failed");
      // }
    } catch (error) {
      print("Error: $error");
      myToast(title: "An error occurred");
    }
  }

  void poolledbooking() async {
    // Check if selected locations are null
    if (pickupLoc == null) {
      myToast(title: 'Please select a Pickup Location');
      return;
    }

    if (dropLoc == null) {
      myToast(title: "Please select a Drop Location");
      return;
    }

    // Log the selected locations
    print("Location ID 1: $pickupLoc");
    print("Location ID 2: $dropLoc");

    // Replace with your actual endpoint
    String url = "${GlobalApi.BASE_URL}poolledbooking.aspx";

    Map<String, String> requestBody = {
      'PickUpLocation': pickupLocId.toString(),
      'PickTime':
          "${DateFormat('dd-MMM-yyyy').format(DateTime.now())} ${DateFormat('HH:mm').format(DateTime.now())}",
      'VehicleID': GlobalApi.nearId.toString(),
      'userid': myStorage.get('id').toString(),
      'DropLocation': dropLocId.toString(),
    };

    requestBody.forEach((key, value) {
      print('$key: $value');
    });

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // Update to match API requirements
        },
        body: requestBody,
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // final response = await http.post(
      //   Uri.parse(url),
      //   headers: {
      //     'Content-Type': 'application/x-www-form-urlencoded', // For form data
      //   },
      //   body: requestBody,
      // );

      // Handle the response
      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");
        myToast(title: "Booking successful");

        setState(() {
          Get.off(() => const BookingSubmited());
        });
      } else {
        throw Exception(
            'Failed to cancel approve booking. Status Code: ${response.statusCode}');
      }
      //   myToast(title: "Booking failed");
      // }
    } catch (error) {
      print("Error: $error");
      myToast(title: "An error occurred");
    }
  }

  Widget PooledTime() {
    return Container(
      color: const Color(0xffd2e5df),
      padding: const EdgeInsets.only(top: 6),
      width: double.infinity,
      child: Wrap(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.calendar_badge_plus),
          ),
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
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.calendar_badge_plus),
          ),
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
                //mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "   Pickup Location",
                    style: TextStyle(
                        fontSize: textSize / 1.2, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: Get.width * 0.4,
                    height: 45,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "   Drop Location",
                    style: TextStyle(
                        fontSize: textSize / 1.2, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: Get.width * 0.4,
                    height: 45,
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
                          if (pickupLoc == value) {
                            Get.back();
                            myToast(
                                title:
                                    "pickup location and droplocation must not be same");
                          } else {
                            setState(() {
                              dropLoc = value;
                              dropLocId = vendorList
                                  .firstWhere((vendor) =>
                                      vendor["Location"] == value)["id"]
                                  .toString();
                            });
                          }
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
              onPressed: () {
                poolledbooking();
              },
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

  Widget onCallAbove() {
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
                          // Adjust this width to control the gap
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
                      "   $packageName",
                      style: TextStyle(
                        fontSize: textSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    items: packageList.map((vendor) {
                            return DropdownMenuItem<String>(
                              value: vendor["ModelName"],
                              child: Text(vendor["ModelName"]),
                            );
                          }).toList(),
                      
                    onChanged: (value) {
                      setState(() {
                        packageName = value;
                        packageId = packageList
                            .firstWhere((package) =>
                                package["PackageName"] == value)["PackageId"]
                            .toString();
                      });
                    },
                  ),
                ),
              ),
              (packageName != "Other")
                  ? const SizedBox(
                      height: 0,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: Get.width * 0.4, // Same width as DropDown
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 2), // Add border
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                            ),
                            child: TextField(
                              controller: manualPackageFrom,
                              decoration: const InputDecoration(
                                hintText: "From", // Placeholder text
                                border:
                                    InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        10), // Padding inside the TextField
                              ),
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4, // Same width as DropDown
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 2), // Add border
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                            ),
                            child: TextField(
                              controller: manualPackageTo,
                              decoration: const InputDecoration(
                                hintText: "To", // Placeholder text
                                border:
                                    InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        10), // Padding inside the TextField
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              SizedBox(
                width: double.infinity, // or a specific width like 300.0
                child: Row(
                  children: <Widget>[
                    Text(
                      "  Booking for",
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
                          // Adjust this width to control the gap
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
                          // Adjust this width to control the gap
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
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: name,
                            decoration: const InputDecoration(
                              hintText: "Name", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: mobile,
                            decoration: const InputDecoration(
                              hintText: "MobileNo", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: email,
                            decoration: const InputDecoration(
                              hintText: "Email", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
              Container(
                color: const Color.fromARGB(255, 236, 244, 242),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pick up",
                          style: TextStyle(
                              fontSize: textSize / 1.2,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: Get.width * 0.05,
                        ),
                        Container(
                          width: Get.width * 0.4,
                          height: 45,
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
                                "    $oncallLoc",
                                style: TextStyle(
                                  fontSize: textSize,
                                ),
                              ),
                              items: pickupList.map((vendor) {
                                return DropdownMenuItem<String>(
                                  value: vendor["Location"],
                                  child: Text(vendor["Location"]),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  oncallLoc = value;
                                  oncallLocId = pickupList
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
                    (oncallLoc != "Other")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: double.infinity, // Same width as DropDown
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey, width: 2), // Add border
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                              ),
                              child: TextField(
                                controller: otherLoc,
                                decoration: const InputDecoration(
                                  hintText:
                                      "Enter Location", // Placeholder text
                                  border:
                                      InputBorder.none, // Remove default border
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Padding inside the TextField
                                ),
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
                          fontSize: textSize / 1.2,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Container(
                      width: Get.width * 0.4,
                      height: 45,
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
                            "    $Vichelname",
                            style: TextStyle(
                              fontSize: textSize,
                            ),
                          ),
                          items: vehicles.map((vendor) {
                                  return DropdownMenuItem<String>(
                                    value: vendor["ModelName"],
                                    child: Text(vendor["ModelName"]),
                                  );
                                }).toList(),
                              
                          onChanged: (value) {
                            setState(() {
                              Vichelname = value;
                              VichelId = vehicles
                                  .firstWhere((vendor) =>
                                      vendor["ModelName"] == value)["ID"]
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
                width: double.infinity, // Same width as DropDown
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, width: 2), // Add border
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: TextField(
                  controller: purpose,
                  decoration: const InputDecoration(
                    hintText: "Purpose/Remark", // Placeholder text
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10), // Padding inside the TextField
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              SizedBox(
                width: Get.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {
                    onCallBooking();
                  },
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
                          // Adjust this width to control the gap
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
                      "   $packageName",
                      style: TextStyle(
                        fontSize: textSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    items: packageList.map((vendor) {
                            return DropdownMenuItem<String>(
                              value: vendor["ModelName"],
                              child: Text(vendor["ModelName"]),
                            );
                          }).toList(),
                      
                    onChanged: (value) {
                      setState(() {
                        packageName = value;
                        packageId = packageList
                            .firstWhere((package) =>
                                package["PackageName"] == value)["PackageId"]
                            .toString();
                      });
                    },
                  ),
                ),
              ),
              (packageName != "Other")
                  ? const SizedBox(
                      height: 0,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: Get.width * 0.4, // Same width as DropDown
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 2), // Add border
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                            ),
                            child: TextField(
                              controller: manualPackageFrom,
                              decoration: const InputDecoration(
                                hintText: "From", // Placeholder text
                                border:
                                    InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        10), // Padding inside the TextField
                              ),
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4, // Same width as DropDown
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 2), // Add border
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded corners
                            ),
                            child: TextField(
                              controller: manualPackageTo,
                              decoration: const InputDecoration(
                                hintText: "To", // Placeholder text
                                border:
                                    InputBorder.none, // Remove default border
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        10), // Padding inside the TextField
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              SizedBox(
                width: double.infinity, // or a specific width like 300.0
                child: Row(
                  children: <Widget>[
                    Text(
                      "  Booking for",
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
                          // Adjust this width to control the gap
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
                          // Adjust this width to control the gap
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
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: name,
                            decoration: const InputDecoration(
                              hintText: "Name", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: mobile,
                            decoration: const InputDecoration(
                              hintText: "MobileNo", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity, // Same width as DropDown
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 2), // Add border
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                          child: TextField(
                            controller: email,
                            decoration: const InputDecoration(
                              hintText: "Email", // Placeholder text
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      10), // Padding inside the TextField
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
              Container(
                color: const Color.fromARGB(255, 236, 244, 242),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pick up",
                          style: TextStyle(
                              fontSize: textSize / 1.2,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: Get.width * 0.05,
                        ),
                        Container(
                          width: Get.width * 0.4,
                          height: 45,
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
                                "    $oncallLoc",
                                style: TextStyle(
                                  fontSize: textSize,
                                ),
                              ),
                              items: pickupList.map((vendor) {
                                return DropdownMenuItem<String>(
                                  value: vendor["Location"],
                                  child: Text(vendor["Location"]),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  oncallLoc = value;
                                  oncallLocId = pickupList
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
                    (oncallLoc != "Other")
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: double.infinity, // Same width as DropDown
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey, width: 2), // Add border
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                              ),
                              child: TextField(
                                controller: otherLoc,
                                decoration: const InputDecoration(
                                  hintText:
                                      "Enter Location", // Placeholder text
                                  border:
                                      InputBorder.none, // Remove default border
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          10), // Padding inside the TextField
                                ),
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
                          fontSize: textSize / 1.2,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Container(
                      width: Get.width * 0.4,
                      height: 45,
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
                            "    $Vichelname",
                            style: TextStyle(
                              fontSize: textSize,
                            ),
                          ),
                          items: vehicles.map((vendor) {
                                  return DropdownMenuItem<String>(
                                    value: vendor["ModelName"],
                                    child: Text(vendor["ModelName"]),
                                  );
                                }).toList(),
                              
                          onChanged: (value) {
                            setState(() {
                              Vichelname = value;
                              VichelId = vehicles
                                  .firstWhere((vendor) =>
                                      vendor["ModelName"] == value)["ID"]
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
                width: double.infinity, // Same width as DropDown
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, width: 2), // Add border
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: TextField(
                  controller: purpose,
                  decoration: const InputDecoration(
                    hintText: "Purpose/Remark", // Placeholder text
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10), // Padding inside the TextField
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              SizedBox(
                width: Get.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {
                    onCallBooking();
                  },
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
        const MapsFragment(),
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


class onCall extends StatelessWidget {
  const onCall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}