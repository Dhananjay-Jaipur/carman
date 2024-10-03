import 'package:get/get.dart';

class Validator{

  String? isEmail(String? em) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    String e = r'^([^<>()[\]\\.,;:\s@adityabirla.com\"])$';

    RegExp regExp = RegExp(p);

    RegExp regExpEmail = RegExp(e);

    if(regExp.hasMatch(em!) != true && regExpEmail.hasMatch(em) != true) {
      return "email must be of @adityabirla.com";
    }

    return null;
  }


  String? isPhoneNumber(String value) {
    if (value.length > 10 || value.length < 10) {
      return 'Mobile Number must 🙄 be of 10 digit';
    } else {
      return null;
    }
  }

  String? isPass(String value) {
// Indian Mobile number are of 10 digit only
    if (value.length < 4) {
      return 'password must be 🙄 of 8 digit';
    } else {
      return null;
    }
  }

  String? isCorrectPass(String pass, String cpass) {
// Indian Mobile number are of 10 digit only
    if (pass == cpass) {
      return null;
    } else {
      return 'password do not matct';
    }
  }

  String? isblank(String value) {
// Indian Mobile number are of 10 digit only
    if (value.isBlank == true) {
      return 'fill 🙄 name';
    } else {
      return null;
    }
  }

}