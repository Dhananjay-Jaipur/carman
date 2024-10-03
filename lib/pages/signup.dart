import 'package:carman/pages/login.dart';
import 'package:carman/utils/GlobalApi.dart';
import 'package:carman/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController licenceController = TextEditingController();

  // Track selected user type
  String userType = '2'; // Default is 'employee'
  List<Map<String, dynamic>> vendorList = [];
  String? selectedVendor;
  String? selectedVendorId;

  @override
  void initState() {
    super.initState();
    fetchVendorList(); // Fetch vendor list when the widget initializes
  }

  Future<void> fetchVendorList() async {
    final url = '${GlobalApi.BASE_URL}GetVendorsList.aspx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Fetched vendor list: $data");

      for (var vendor in data["Response"]) {
        vendorList.add({
          "name": vendor["Name"],
          "id": vendor["USERID"],
        });
      }
      setState(() {
        // Optionally insert a placeholder for the dropdown
        vendorList.insert(0, {"name": "Select Vendor", "id": -1});
      });
    } else {
      print("Failed to fetch vendor list: ${response.body}");
    }
  }

  Future<void> sendSignUpRequest() async {
    final url = '${GlobalApi.BASE_URL}usercreation.aspx'; // Replace with your actual endpoint

    // Prepare the body
    final body = {
      "MobileNo": mobileController.text.isNotEmpty ? mobileController.text : "",
      "Email": emailController.text.isNotEmpty ? emailController.text : "",
      "Address": addressController.text.isNotEmpty ? addressController.text : "",
      "VendorId": selectedVendorId ?? "",
      "Licence": licenceController.text.isNotEmpty ? licenceController.text : "",
      "UserType": userType,
      "Pincode": pincodeController.text.isNotEmpty ? pincodeController.text : "",
      "Name": nameController.text.isNotEmpty ? nameController.text : "",
      "Password": passwordController.text.isNotEmpty ? passwordController.text : "",
      // Use empty string if selectedVendorId is null
    };

    // Print the request body
    print("Request Body: $body");

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      // Handle the response from the server
      var myResponse = jsonDecode(response.body);
      print("Response: ${response.body}");

      if (myResponse["Response"][0]["Status"] == "Saved") {
        myToast(title: "Account created successfully");
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.offAll(() => const Login());
        });
      }

      if (myResponse["Response"][0]["Status"] == "Error") {
        myToast(title: "user already exists");
      }
    } else {
      throw Exception('Failed to create. Status Code: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    licenceController.dispose();
    super.dispose();
  }

  // Helper method to show/hide fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Navigation Bar
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/logo.png', // Replace with your image path
                        width: 70.0,
                        height: 70.0,
                      ),
                    ),
                    // Text
                    const Text(
                      "Carman",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Create Account Section
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 10.0),
                      child: Text(
                        "Create an Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Radio Group
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: '2',
                          groupValue: userType,
                          onChanged: (value) {
                            setState(() {
                              userType = value!;
                              selectedVendor = null; // Reset selected vendor
                            });
                          },
                        ),
                        const Text('Employee', style: TextStyle(fontSize: 12)),
                        Radio(
                          value: '3',
                          groupValue: userType,
                          onChanged: (value) {
                            setState(() {
                              userType = value!;
                              selectedVendor = null; // Reset selected vendor
                            });
                          },
                        ),
                        const Text('Vendor', style: TextStyle(fontSize: 12)),
                        Radio(
                          value: '4',
                          groupValue: userType,
                          onChanged: (value) {
                            setState(() {
                              userType = value!;
                              selectedVendor = null; // Reset selected vendor
                            });
                          },
                        ),
                        const Text('Pooled\nDriver', style: TextStyle(fontSize: 12)),
                        Radio(
                          value: '5',
                          groupValue: userType,
                          onChanged: (value) {
                            setState(() {
                              userType = value!;
                              selectedVendor = null; // Reset selected vendor
                            });
                          },
                        ),
                        const Text('Vendor\nDriver', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown for Vendor Driver only
                          if (userType == '5') ...[
                            Row(
                              children: [
                                const Icon(Icons.car_rental),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedVendor,
                                    hint: const Text("Select Vendor"),
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
                                            .firstWhere((vendor) =>
                                                vendor["name"] == value)["id"]
                                            .toString();
                                      });
                                    },
                                  ),
                                
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Common fields for Employee, Vendor, Pooled Driver, and Vendor Driver
                          if (userType == '2' ||
                              userType == '3' ||
                              userType == '4' ||
                              userType == '5') ...[
                            _buildTextField(
                              controller: nameController,
                              hintText: 'Name',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: mobileController,
                              hintText: 'Mobile',
                              icon: Icons.phone,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: emailController,
                              hintText: 'Email',
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: rePasswordController,
                              hintText: 'Re-Password',
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                          ],

                          // Show address, pincode, licence for Pooled Driver and Vendor Driver
                          if (userType == '4' || userType == '5') ...[
                            _buildTextField(
                              controller: addressController,
                              hintText: 'Address',
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: pincodeController,
                              hintText: 'Pincode',
                              icon: Icons.pin_drop,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: licenceController,
                              hintText: 'Enter Licence',
                              icon: Icons.card_membership,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign-Up Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          sendSignUpRequest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 61, 109, 63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Sign-Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Already have an account? Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 18.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const Login());
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18.2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D547E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
