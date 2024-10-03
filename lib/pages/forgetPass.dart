import 'dart:convert';

import 'package:carman/utils/GlobalApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/toast.dart';
import '../../utils/validator.dart';
import 'package:http/http.dart' as http;

import 'login.dart';


class ForgetPass extends StatefulWidget {
   const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {

  TextEditingController data = TextEditingController();
  TextEditingController otp = TextEditingController();

  bool isEnable = true;
  bool isUser = false;
  var userData;
  var id;


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

   void VarifyUser() async {

     var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}UserVerification.aspx?a=${data.text}'));

     if (response.statusCode == 200)
     {
       userData = jsonDecode(response.body);

       print(userData.toString());

       if(userData['Response'][0]['Status'] == 'Valid')
         {
           myToast(title: "OTP is send");
           setState(() {
             id = userData['Response'][0]['UserID'];
             isEnable = false;
             isUser = true;
           });
         }

       else
         {
           myToast(title: userData['Response'][0]['Status'].toString());
         }

     }

     else
     {
       myToast(title: "user not found");
     }

   }

  void VarifyOTP() async {

    var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}UserOTPVerification.aspx?a=${id.toString()}&b=${otp.text}'));

    if (response.statusCode == 200)
    {
      userData = jsonDecode(response.body);

      print(userData.toString());

      if(userData['Response'][0]['Status'] == 'OTP Verified')
      {
        myToast(title: "Verified");
        setState(() {
          id = userData['Response'][0]['UserID'];
          isEnable = false;
          isUser = true;
        });
      }

      else
      {
        myToast(title: userData['Response'][0]['Status'].toString());
      }

    }

    else
    {
      myToast(title: "user not found");
    }

  }


   Widget OTPpage(){
     var width = Get.width;
     bool isTablet = width >= 600;

    return Column(
      children: [

        Wrap(
          children: [
            Text(
              "To proceed further, We have sent an OTP. please enter the OTP to complete varification\n",
              style: TextStyle(
                fontSize: isTablet ? 21 : 12,
                color: Colors.black, // Set text color to black
              ),
              maxLines: 4,
            ),
          ],
        ),


        TextFormField(
          controller: otp,

          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 20),
          cursorColor: Theme.of(context).colorScheme.onPrimary,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.password,
              color: Colors.black,
              size: 28,
            ),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(33)),

            hintText: "Enter OTP",
            hintStyle: const TextStyle(fontSize: 20, color: Colors.grey),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
          textInputAction: TextInputAction.next,
        ),

        SizedBox(
          height: Get.height * 0.02,
        ),

        //BUTTON:::::
        SizedBox(
          width: Get.width * 0.6,
          child: ElevatedButton(
            onPressed: () {
              VarifyOTP();

              if(isUser)
                {Get.to(() => ResetPass(id: id));}
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
                    "Verify and Proceed",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Get.height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

      ],
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
            title: _buildText("Forget Password", isTablet: isTablet),

            centerTitle: false,
          ),
        ),
      ),

      body: Form(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Column(
              children: [

                Wrap(
                  children: [
                    Text(
                      "Enter the email address and the mobile number associated with the aalay\n",
                      style: TextStyle(
                        fontSize: isTablet ? 21 : 12,
                        color: Colors.black, // Set text color to black
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),


                TextFormField(
                  controller: data,
                  enabled: isEnable,

                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 20),
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      CupertinoIcons.person,
                      color: Colors.black,
                      size: 28,
                    ),

                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(33)),

                    hintText: "Email or Mobile No.",
                    hintStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(
                  height: Get.height * 0.02,
                ),

                //BUTTON:::::
                (isUser == false)
                ?SizedBox(
                  width: Get.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      VarifyUser();
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
                            "Continue",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Get.height * 0.02,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                :OTPpage(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ResetPass extends StatefulWidget {
  final id;

  const ResetPass({super.key, required this.id});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {

  TextEditingController pass = TextEditingController();
  TextEditingController rePass = TextEditingController();

  var userData;
  var id;


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

  void VarifyPass() async {

    var response = await http.get(Uri.parse('${GlobalApi.BASE_URL}UserUpdatePassword.aspx?a=${widget.id.toString()}&b=${rePass.text.toString()}'));

    if (response.statusCode == 200)
    {
      userData = jsonDecode(response.body);

      print(userData.toString());

      print(widget.id);
      print(rePass.text);

      if(userData['Response'][0]['Status'] == 'Password Updated')
      {
        myToast(title: "password changed");

        Future.delayed(const Duration(milliseconds: 2000), () {
          setState(() {
            Get.offAll(() => const Login());
          });
        });
      }

      else
      {
        myToast(title: userData['Response'][0]['Status'].toString());
      }

    }

    else
    {
      myToast(title: "try again");
    }

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
            title: _buildText("Create New Password", isTablet: isTablet),

            centerTitle: false,
          ),
        ),
      ),

      body: Form(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Column(
              children: [

                Wrap(
                  children: [
                    Text(
                      "We will ask for this password whenever you sign-in to aalay\n",
                      style: TextStyle(
                        fontSize: isTablet ? 21 : 12,
                        color: Colors.black, // Set text color to black
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),


                TextFormField(
                  controller: pass,

                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 20),
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.password,
                      color: Colors.black,
                      size: 28,
                    ),

                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(33)),

                    hintText: "new password",
                    hintStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 20,),

                TextFormField(
                  controller: rePass,

                  validator: (value) => Validator().isCorrectPass(pass.text, rePass.text),

                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 20),
                  cursorColor: Theme.of(context).colorScheme.onPrimary,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.password,
                      color: Colors.black,
                      size: 28,
                    ),

                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(33)),

                    hintText: "conform password",
                    hintStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(
                  height: Get.height * 0.03,
                ),

                //BUTTON:::::
                SizedBox(
                  width: Get.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      VarifyPass();
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
                            "Save Changes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Get.height * 0.02,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}