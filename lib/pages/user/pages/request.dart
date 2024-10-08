import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../utils/GlobalApi.dart';
import '../../../utils/toast.dart';
import 'package:http/http.dart' as http;

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final myStorage = Hive.box('myStorage');
  var userData;
  int length = 0;
  var loading = true;

  @override
  void initState() {

    getData();
    super.initState();
  }

  void getData() async {
    var response = await http.get(Uri.parse(
        '${GlobalApi.BASE_URL}approvalrequestnew.aspx?a=${myStorage.get('id')}'));

    setState(() {
      loading = false;
    });

    if (response.statusCode == 200) {
      userData = await jsonDecode(response.body);
      setState(() {
        length = userData['Response'].length as int;
      });
    } else {
      myToast(title: response.body.toString());
    }
  }

  void ApproveBooking(bookingId) async {
    
    try {
      // Send the GET request
      var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}ApprovalAction.aspx?BookingId=${bookingId.toString()}&Status=1&ApproverID=${myStorage.get('id').toString()}'));

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle the response from the server
        var myResponse = jsonDecode(response.body);
        print("200: ${response.body}");

        if (myResponse['Response'][0]['Status'] == "Approved") {
          myToast(title: 'approved');
          getData();
        }

        if (myResponse['Response'][0]['Status'] == "Error") {
          myToast(title: 'already approved');
          getData();
        }

        getData();
      }
    } catch (error) {
      // Handle any errors (network, parsing, etc.)
      print(error);
    }
  }

  void RejectBooking(bookingId) async {
    
    try {
      // Send the GET request
      var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}ApprovalAction.aspx?BookingId=${bookingId.toString()}&Status=-1&ApproverID=${myStorage.get('id').toString()}'));

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle the response from the server
        var myResponse = jsonDecode(response.body);
        print("200: ${response.body}");

        if (myResponse['Response'][0]['Status'] == "Rejected") {
          myToast(title: 'Rejected');
          getData();
        }

        if (myResponse['Response'][0]['Status'] == "Error") {
          myToast(title: 'already Rejected');
          getData();
        }

        getData();
      }
    } catch (error) {
      // Handle any errors (network, parsing, etc.)
      print(error);
    }
  }

  Container ShowBox(int i) {
    var data = userData['Response'][i];

    // Ensure data is a Map
    if (data is! Map<String, dynamic>) {
      return Container(); // Return an empty container if data is not valid
    }

    var guestName = data['PersonName'] ?? 'N/A';
    var PickupTime = data['PickupTime'] ?? 'N/A';
    var PickAddress = data['PickAddress'] ?? 'N/A';
    var DropAddress = data['DropAddress']?.toString() ?? 'N/A'; // Convert to string if necessary
    var PackageName = data['PackageName']?.toString() ?? 'N/A'; // Convert to string if necessary

    // Determine screen width to apply different styles for mobile and tablet
    bool isTablet = false;

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
    });

    double textSize = isTablet
        ? Get.width * 0.025
        : 15; // Larger text for tablets, smaller for mobile

    return Container(
      margin: EdgeInsets.symmetric(vertical: Get.width * 0.02),
      padding: EdgeInsets.all(Get.width * 0.02),
      width: Get.width * 0.90,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 88, 66, 116),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: textSize),
                SizedBox(width: Get.width * 0.02),
                Text(
                  guestName,
                  style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(CupertinoIcons.clock_fill,
                    color: Colors.white, size: textSize),
                SizedBox(width: Get.width * 0.02),
                Text(
                  "$PickupTime",
                  style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(CupertinoIcons.building_2_fill,
                    color: Colors.white, size: textSize),
                SizedBox(width: Get.width * 0.02),
                Text(
                  PickAddress,
                  style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(CupertinoIcons.location,
                    color: Colors.white, size: textSize),
                SizedBox(width: Get.width * 0.02),
                Text(
                  DropAddress,
                  style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(CupertinoIcons.tram_fill,
                    color: Colors.white, size: textSize),
                SizedBox(width: Get.width * 0.02),
                Text(
                  PackageName,
                  style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: Get.width * 0.02),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    RejectBooking(userData['Response'][i]['BookingID']);
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.highlight_remove,
                          color: Colors.white,
                          size: textSize,
                        ),
                        SizedBox(width: Get.width * 0.02),
                        Text(
                          "REJECTED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: textSize,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ApproveBooking(userData['Response'][i]['BookingID']);
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.done, color: Colors.white, size: textSize),
                        SizedBox(width: Get.width * 0.02),
                        Text(
                          "APPROVE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: textSize,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            (length == 0)
            ? SizedBox(height: Get.height * 0.3)
            : const SizedBox(height: 0),

            (loading)
                ? Center(child: Image.asset('assets/loading.gif'))
                : const SizedBox(height: 0),

            for (int i = 0; i < length; i++) 
            ShowBox(i),
            
            (length == 0 && loading == false)
                ? Center(
                    child: Text(
                      "No Pending Request",
                      style: TextStyle(
                          color: Colors.grey, fontSize: Get.width * 0.07),
                    ),
                  )
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
