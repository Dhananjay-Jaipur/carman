import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../utils/GlobalApi.dart';
import '../../utils/toast.dart';
import 'package:http/http.dart' as http;

import '../login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  Box<dynamic> myStorage = Hive.box('myStorage');

  var userData;
  var name;
  var email;
  var mobile;
  var department;
  var pass;

  @override
  void initState() {
    setState(() {});

    getData();
    super.initState();
  }


  void getData() async {

    Hive.box('myStorage');

    var response = await http.get(Uri.parse(
        '${GlobalApi.BASE_URL}usersprofile.aspx?id=${myStorage.get('id')}'));

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(response.body);
        name = userData['Response'][0]['Name'];
        email = userData['Response'][0]['Email'];
        mobile = userData['Response'][0]['MobileNo'];
        department = userData['Response'][0]['User Type'];
        pass = userData['Response'][0]['Password'];
      });
    } else {
      print(response.body.toString());
    }
  }


  void DeleteUser() async {
    String apiUrl = '${GlobalApi.BASE_URL}DeleteUser.aspx';

    Map<String, dynamic> formData = {
      'UserID': myStorage.get('id').toString(),  // Ensure it's a String// Use '1' as a String
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
        body: formData.map((key, value) => MapEntry(key, value.toString())), // Ensure all values are String
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle the response from the server
        var myResponce = await jsonDecode(response.body);
        print("200: ${response.body}");

        if (myResponce['Response'][0]['Status'] == "Deleted") {
          // Update the status of the booking in the list
          myToast(title: 'Account Deleted');
          Future.delayed(const Duration(milliseconds: 3800), () {
            setState(() {
              Get.offAll(() => const Login());
            });
          });
        }
      } else {
        throw Exception(
            'Failed to delete user. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors (network, parsing, etc.)
      print(error);
    }
  }



  @override
  Widget build(BuildContext context) {

    bool isTablet = false;

    setState(() {
      isTablet = (Get.width >= 600) ? true : false;
    });

    double textSize = isTablet ? Get.width * 0.025 : 14;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  children: [
                    (isTablet)?
                        const SizedBox(height: 30,)
                        :const SizedBox(height: 0,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "  $name",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined,
                            size: MediaQuery.of(context).size.width * 0.07),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "  $email",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.phone,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "  $mobile",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "  $department",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "  *******",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => UpdateProfile(
                                userName: name,
                                userMobile: mobile,
                                userEmail: email,
                                userDepartment: department,
                                userID: myStorage.get('id'),
                                userPassword: pass));
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            )),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xFF2D547E), // Button color
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Update ", // Button text
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: textSize, // Responsive text size (4% of screen width)
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.save,
                                  color: Colors.white,
                                  size: textSize,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await myStorage.deleteFromDisk();
                            Get.offAll(() => const Login());
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            )),
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.orange),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sign-out ", // Button text
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: textSize,// Responsive text size (4% of screen width)
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: textSize,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: const Divider(
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    SizedBox(
                      width: Get.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () async {
                          DeleteUser();
                        },
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(33),
                          )),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.red),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Delete ", // Button text
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: textSize, // Responsive text size (4% of screen width)
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: textSize,
                              ),
                            ],
                          ),
                        ),
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
}

// ============================ UPDATE PROFILE ==============================================

class UpdateProfile extends StatefulWidget {
  final userID;
  final userName;
  final userMobile;
  final userEmail;
  final userDepartment;
  final userPassword;

  const UpdateProfile(
      {super.key,
      required this.userName,
      required this.userMobile,
      required this.userEmail,
      required this.userDepartment,
      required this.userID,
      required this.userPassword});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  var _obscureText = true;

  var name = TextEditingController();
  var mobile = TextEditingController();
  var email = TextEditingController();
  var pass = TextEditingController();

  String? myName;
  String? myMobile;
  String? myEmail;
  String? myPass;

  Future<void> sendRequest() async {
    setState(() {
      myName = name.text.isNotEmpty ? name.text : widget.userName;
      myMobile = mobile.text.isNotEmpty ? mobile.text : widget.userMobile;
      myEmail = email.text.isNotEmpty ? email.text : widget.userEmail;
      myPass = pass.text.isNotEmpty ? pass.text : widget.userPassword;
    });

    var response = await http.get(
      Uri.parse(
        '${GlobalApi.BASE_URL}updateuserdetails.aspx'
        '?USERID=${widget.userID}'
        '&Name=$myName'
        '&Email=$myEmail'
        '&MobileNo=$myMobile'
        '&Password=$myPass',
      ),
    );

    // var response = await http.post(
    //     Uri.parse('${GlobalApi.BASE_URL}updateuserdetails.aspx'),
    //     headers: {"Content-Type": "application/x-www-form-urlencoded"},
    //     body: jsonEncode({
    //       "UserID": widget.userID,
    //       "Name": myName,
    //       "Email": myEmail,
    //       "MobileNo": myMobile,
    //       "Password": myPass,
    //     })
    // );

    if (response.statusCode == 200) {
      try {
        var userData = jsonDecode(response.body);
        myToast(title: userData.toString());

        if (userData['Response'][0]['Status'] == 'Saved') {
          myToast(title: "Profile updated successfully");
        }
      } catch (e) {
        print("Error parsing response: ${e.toString()}");
      }
    } else {
      myToast(title: "Request failed with status: ${response.statusCode}");
    }
  }

  final List<String> items = [
    'Smelter',
    'CPP',
    'Common',
    'Finance',
  ];

  var checkedValue = false;

  void ChangeBox() {
    setState(() {
      checkedValue = !checkedValue;
    });
  }

  void ChangeText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _buildText(String text,
      {FontWeight fontWeight = FontWeight.w700, required bool isTablet}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 40 : 30,
        fontWeight: fontWeight,
        color: Colors.black, // Set text color to black
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    bool isTablet = width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 1.8,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                CupertinoIcons.back,
                size: isTablet ? 35 : 25,
              )
            ),
            title: _buildText("Update Profile", isTablet: isTablet),

            centerTitle: false,
          ),
        ),
      ),
      body: Form(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: Icon(
                  CupertinoIcons.person_circle_fill,
                  size: Get.height * 0.15,
                ),
              ),
              SizedBox(
                height: Get.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          myName = value;
                        });
                      },
                      controller: name,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 20),
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.person,
                          color: Colors.black,
                          size: 28,
                        ),
                        hintText: " ${widget.userName}",
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          myEmail = value;
                        });
                      },
                      controller: email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 20),
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.black,
                          size: 28,
                        ),
                        hintText: " ${widget.userEmail}",
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          myMobile = value;
                        });
                      },
                      controller: mobile,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontSize: 20),
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.phone,
                          color: Colors.black,
                          size: 28,
                        ),
                        hintText: " ${widget.userMobile}",
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: Get.width * 0.02,
                        ),
                        const Icon(
                          Icons.home_work_outlined,
                          size: 28,
                        ),
                        Text(
                          "   ${widget.userDepartment}",
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          myPass = value;
                        });
                      },
                      controller: pass,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      obscureText: _obscureText,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.black,
                          size: 28,
                        ),
                        hintText: "  ******",
                        hintStyle:
                            const TextStyle(fontSize: 20, color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            ChangeText();
                          },
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(
                      height: Get.height * 0.04,
                    ),

                    //BUTTON:::::
                    ElevatedButton(
                      onPressed: () {
                        sendRequest();
                      },
                      style: ButtonStyle(
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        )),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF2D547E)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Save Changes  ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Get.height * 0.02,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.save,
                              color: Colors.white,
                              size: Get.height * 0.02,
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
        ),
      ),
    );
  }
}
