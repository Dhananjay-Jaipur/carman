import 'package:carman/pages/user/pages/Bookings.dart';
import 'package:carman/pages/user/pages/home.dart';
import 'package:carman/pages/user/pages/ride.dart';
import 'package:carman/pages/user/pages/profile.dart';
import 'package:carman/pages/user/pages/request.dart';
import 'package:carman/pages/user/pages/personal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  int selectedIndex = 0;
  int selectedValue = 1;
  String subTitle = "👤 Official";
  bool showOptions = false; // Flag to control the visibility of the options

  List<Widget> pages = [
    const Home(),
    const Bookings(),
    const Ride(),
    const Request(),
    const Profile(),
  ];

  List pageTitle = ["👤 Official", "Bookings", "Rides", "Request", "Profile"];

  Future buildOptions() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Mode'),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Ensures the column takes only the space needed
            children: [
              RadioListTile<int>(
                title: const Text('Official'),
                value: 1,
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                    subTitle = "👤 Official";
                    pages = [
                      const Home(),
                      const Bookings(),
                      const Ride(),
                      const Request(),
                      const Profile(),
                    ];
                    Navigator.of(context).pop(); // Close dialog after selection
                  });
                },
              ),
              RadioListTile<int>(
                title: const Text('Personal'),
                value: 2,
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                    subTitle = "👤 Personal";
                    pages = [
                      const Peraonal(),
                      const Bookings(),
                      const Ride(),
                      const Request(),
                      const Profile(),
                    ];
                    Navigator.of(context).pop(); // Close dialog after selection
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close dialog without making a selection
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget myBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (int index) {
        setState(() {
          selectedIndex = index;
        });
      },
      backgroundColor: Colors.white,
      unselectedLabelStyle: const TextStyle(color: Colors.black),
      unselectedItemColor: Colors.black,
      selectedLabelStyle: const TextStyle(color: Colors.indigo),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: Colors.indigo,
      currentIndex: selectedIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bookings'),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_filled_outlined), label: 'Rides'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined), label: 'Request'),
        BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled), label: 'Profile'),
      ],
    );
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

  Widget _buildIcon({bool isTablet = false}) {
    return Icon(
      CupertinoIcons.back,
      size: isTablet ? 35 : 25,
    );
  }

  Widget _buildSubText(String text,
      {FontWeight fontWeight = FontWeight.w400, required bool isTablet}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 24 : 17,
        fontWeight: fontWeight,
        color: Colors.black,
      ),
    );
  }

  PreferredSize myAppBar() {
    bool isTablet = Get.width >= 600;

    if (selectedIndex == 0) {
      return PreferredSize(
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
              GestureDetector(
                onTap: () {
                  buildOptions();
                  setState(() {
                    showOptions = !showOptions; // Toggle visibility of options
                  });
                },
                child: _buildSubText(subTitle, isTablet: isTablet),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedIndex == 4) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              icon: _buildIcon(isTablet: isTablet),
            ),
            title: _buildText("Profile", isTablet: isTablet),
            centerTitle: false,
          ),
        ),
      );
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(78),
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
            _buildSubText(pageTitle[selectedIndex], isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: myAppBar(),
      bottomNavigationBar: myBottomNavigationBar(),
      body: Column(
        children: [
          // if (showOptions && selectedIndex == 0)
          // buildOptions(), // Show radio options if toggled
          Expanded(child: pages[selectedIndex]), // The main content
        ],
      ),
    );
  }
}
