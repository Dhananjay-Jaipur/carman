import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../utils/GlobalApi.dart';
import '../../../utils/toast.dart';
import 'package:http/http.dart' as http;

class Ride extends StatefulWidget {
  const Ride({super.key});

  @override
  State<Ride> createState() => _RideState();
}

class _RideState extends State<Ride> {
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
    var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}getrides.aspx?a=${myStorage.get('id')}'));

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


  Container ShowBox(int i) {
    var data = userData['Response'][i];

    // Ensure data is a Map
    if (data is! Map<String, dynamic>) {
      return Container(); // Return an empty container if data is not valid
    }

    var PickupTime = data['PickupTime'] ?? 'N/A';
    var PickAddress = data['PickAddress'] ?? 'N/A';
    var DropAddress = data['DropAddress']?.toString() ?? 'N/A'; // Convert to string if necessary
    var REGNO = data['REGNO']?.toString() ?? 'N/A'; // Convert to string if necessary

    // Determine screen width to apply different styles for mobile and tablet
    bool isTablet = false;

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
    });

    double textSize = isTablet ? Get.width * 0.025 : 15; // Larger text for tablets, smaller for mobile

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
                  "  Completed",
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

            loading
                ? Center(child: Image.asset('assets/loading.gif'))
                : const SizedBox(height: 0),

            for (int i = 0; i < length; i++)
              ShowBox(i),

            (length==0 && loading == false)
                ?Center(child: Text("No Rides", style: TextStyle(color: Colors.grey, fontSize: Get.width * 0.07),),)
                :const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
