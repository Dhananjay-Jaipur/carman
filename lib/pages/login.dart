import 'dart:convert';
import 'package:carman/pages/forgetPass.dart';
import 'package:carman/pages/signup.dart';
import 'package:carman/pages/user/UserHome.dart';
import 'package:carman/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../utils/GlobalApi.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final myStorage = Hive.box('myStorage');

  var _obscureText = true;

  final input = TextEditingController();
  final pass = TextEditingController();

  void ChangeText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void FetchData() async {
    String apiUrl =
        '${GlobalApi.BASE_URL}validateuser.aspx?a=${input.text}&b=${pass.text}';

    try {
      // Send the GET request
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        // Handle the response from the server
        var myResponse = jsonDecode(response.body);
        print("Response: ${response.body}");

        if (response.body == "[]") {
          myToast(title: 'user do not exist');
        }

        if (myResponse['Response'].isNotEmpty &&
            myResponse['Response'][0]['id'] != null) {
          myToast(title: 'Login successfully');
          myStorage.put("id", myResponse['Response'][0]['id']);
          myStorage.put("UserType", myResponse['Response'][0]['UserType']);

          if (myResponse['Response'][0]['UserType'] == 2) {
            Get.offAll(() =>
                const UserHome()); // Replace UserHome() with your actual widget
          }
        }
      } else {
        throw Exception(
            'Failed to log in. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors (network, parsing, etc.)
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Form(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20), // Adjust the radius as needed
                child: Image.asset(
                  "assets/logo.png",
                  height: Get.width * 0.3,
                  width: Get.width * 0.3,
                  fit: BoxFit
                      .cover, // Ensures the image fits nicely within the rounded rectangle
                ),
              ),
              SizedBox(
                height: Get.height * 0.05,
              ),
              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: Get.height * 0.04,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Get.height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    TextFormField(
                      controller: input,
                      // validator: (value) => Validator().isEmail(value!),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: const TextStyle(fontSize: 20),
                      cursorColor: Colors.grey,

                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          color: Colors.black,
                          size: 25,
                        ),
                        hintText: "Email / Mobile No / UserId",
                        hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                        errorStyle: TextStyle(color: Colors.redAccent),                        
                      ),

                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextFormField(
                      controller: pass,
                      // validator: (value) => Validator().isPass(value!),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: const TextStyle(fontSize: 20),
                      cursorColor: Colors.grey,

                      obscureText: _obscureText,

                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.black,
                          size: 25,
                        ),
                        hintText: "Password",
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
                      height: Get.height * 0.02,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => const ForgetPass());
                          },
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              color: const Color(0xFF2D547E),
                              fontWeight: FontWeight.bold,
                              fontSize: Get.height * 0.017,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: Get.height * 0.03,
                    ),

                    //BUTTON:::::
                    SizedBox(
                      width: Get.width * 0.5,
                      height: Get.height * 0.065,
                      child: ElevatedButton(
                        onPressed: () {
                          if (input.text == '') {
                            myToast(
                              title: "*please enter ID",
                            );
                          }

                          if (pass.text == '') {
                            myToast(
                              title: "*please enter password",
                            );
                          } else {
                            FetchData();
                          }
                        },
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          )),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 61, 109, 63)),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Get.height * 0.027,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: Get.height * 0.03,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "don't have an account ? ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Get.height * 0.017,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => const SignUp());
                          },
                          child: Text(
                            "sign-up",
                            style: TextStyle(
                              color: const Color(0xFF2D547E),
                              fontWeight: FontWeight.bold,
                              fontSize: Get.height * 0.019,
                            ),
                          ),
                        ),
                      ],
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
