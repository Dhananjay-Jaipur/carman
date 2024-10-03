import 'package:carman/pages/login.dart';
import 'package:carman/pages/user/UserHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final myStorage = Hive.box('myStorage');

  bool isTablet = false;

  void page() {
    (myStorage.get('UserType') == null)
        ? Get.offAll(() => const Login())
        : Get.offAll(() => const UserHome());
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
    });

    double textSize = isTablet ? Get.width * 0.025 : 12;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),

              // todo: logo
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        20), // Adjust the radius as needed
                    child: Image.asset(
                      "assets/logo.png",
                      height: Get.width * 0.4,
                      width: Get.width * 0.4,
                      fit: BoxFit
                          .cover, // Ensures the image fits nicely within the rounded rectangle
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.03,
                  ),
                  Text(
                    "Disclosure",
                    style: TextStyle(
                      fontSize: textSize * 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.01,
                  ),
                  Icon(
                    Icons.location_pin,
                    size: textSize * 5,
                  ),
                  Text(
                    "Enable Geolocation",
                    style: TextStyle(
                      fontSize: textSize * 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Wrap(
                      children: [
                        Text(
                          "This app collects location data to enable booking of vehicle, and vehicle's live position to drive even when the app is close or not in use. If you do not allow the Geolocation, none of above feature will be used.",
                          style: TextStyle(
                            fontSize: textSize * 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.03,
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      page();
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
                        "  PROCEED  ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: textSize * 1.8,
                            color: Colors.white),
                      ),
                    ),
                  ),
                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
