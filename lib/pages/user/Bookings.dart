import 'dart:convert';

import 'package:carman/pages/user/proceed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../utils/GlobalApi.dart';
import '../../utils/toast.dart';
import 'package:http/http.dart' as http;

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final myStorage = Hive.box('myStorage');
  var userData;
  int length = 0;
  var loading = true;

  @override
  void initState() {
    setState(() {});

    getData();
    super.initState();
  }

  void getData() async {
    var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}userbookingshistory.aspx?a=${myStorage.get('id')}'));

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

  void Cancel(bookingId) async {
    String apiUrl = '${GlobalApi.BASE_URL}cancelbooking.aspx';

    Map<String, dynamic> formData = {
      'BookingId': bookingId.toString(),
    };

    formData.forEach((key, value) {
      print('$key: $value');
    });

    try {
      // Send the POST request
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // For form data
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        // Handle the response from the server
        var myResponce = await jsonDecode(response.body);
        print("200: ${response.body}");

        if (myResponce['Response'][0]['Status'] == "Cancelled") {
          // Update the status of the booking in the list
          myToast(title: 'Booking cancelled successfully');
          getData();
        }

        if (myResponce['Response'][0]['Status'] == "Error") {
          // Update the status of the booking in the list
          myToast(title: 'already cancelled');
          getData();
        }

        getData();
      } else {
        throw Exception(
            'Failed to cancel booking. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors (network, parsing, etc.)
      print(error);
    }
  }

  Container ShowBox(int i, textSize, isTablet) {
    var PickupTime = userData['Response'][i]['PickupTime'] ?? 'N/A';
    var PickAddress = userData['Response'][i]['PickAddress'] ?? 'N/A';
    var DropAddress = userData['Response'][i]['DropAddress']?.toString() ??
        'N/A'; // Convert to string if necessary
    var REGNO = userData['Response'][i]['REGNO']?.toString() ?? 'N/A';
    var Status = userData['Response'][i]['Status'];

    // todo = Approved
    if (Status == 1) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: Get.width * 0.02),
        padding: EdgeInsets.all(Get.width * 0.02),
        width: Get.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF35A34E),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.smiley,
                  color: Colors.white,
                  size: textSize * 1.5,
                ),
                Text(
                  "  Approved",
                  style: TextStyle(
                    fontSize: textSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.white,
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
                  Icon(Icons.local_car_wash,
                      color: Colors.white, size: textSize),
                  SizedBox(width: Get.width * 0.02),
                  Text(
                    REGNO,
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
                      Cancel(userData['Response'][i]['ID']);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
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
                            "CANCEL",
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
                      Get.to(() => const Proceed());
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.done, color: Colors.black, size: textSize),
                          SizedBox(width: Get.width * 0.02),
                          Text(
                            "PROCEED",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: textSize,
                                color: Colors.black),
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

    // todo = Rejected
    if (Status == -1) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: Get.width * 0.02),
        padding: EdgeInsets.all(Get.width * 0.02),
        width: Get.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFFF57F17),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                  size: textSize * 1.5,
                ),
                Text(
                  "  Rejected",
                  style: TextStyle(
                    fontSize: textSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.white,
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
                  Icon(Icons.local_car_wash,
                      color: Colors.white, size: textSize),
                  SizedBox(width: Get.width * 0.02),
                  Text(
                    REGNO,
                    style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.width * 0.02),
          ],
        ),
      );
    }

    // todo = user canceled
    if (Status == 4) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: Get.width * 0.02),
        padding: EdgeInsets.all(Get.width * 0.02),
        width: Get.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFFE44848),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.highlight_remove,
                  color: Colors.white,
                  size: textSize * 1.5,
                ),
                Text(
                  "  Cancelled",
                  style: TextStyle(
                    fontSize: textSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.white,
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
                  Icon(Icons.local_car_wash,
                      color: Colors.white, size: textSize),
                  SizedBox(width: Get.width * 0.02),
                  Text(
                    REGNO,
                    style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.width * 0.02),
          ],
        ),
      );
    }

    // todo = pending
    else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: Get.width * 0.02),
        padding: EdgeInsets.all(Get.width * 0.02),
        width: Get.width * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF3A84B1),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  color: Colors.white,
                  size: textSize * 1.5,
                ),
                Text(
                  "  Request Pending",
                  style: TextStyle(
                    fontSize: textSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.white,
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
                  Icon(Icons.local_car_wash,
                      color: Colors.white, size: textSize),
                  SizedBox(width: Get.width * 0.02),
                  Text(
                    REGNO,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Cancel(userData['Response'][i]['ID']);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33),
                      )),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.redAccent),
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
                          Text(
                            "  Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: textSize,
                              color: Colors.white,
                            ),
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
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = false;

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
    });

    double textSize = isTablet ? Get.width * 0.025 : 15;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            (length == 0)
                ? SizedBox(height: Get.height * 0.3)
                : const SizedBox(height: 0),
            (length == 0 && loading == false)
                ? Center(
                    child: Text(
                      "No Bookings",
                      style: TextStyle(
                          color: Colors.grey, fontSize: Get.width * 0.07),
                    ),
                  )
                : const SizedBox(height: 0),
            (loading)
                ? Center(child: Image.asset('assets/loading.gif'))
                : const SizedBox(
                    height: 0,
                  ),

            for (int i = 0; i < length; i++) ShowBox(i, textSize, isTablet),
          ],
        ),
      ),
    );
  }
}
