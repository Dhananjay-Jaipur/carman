import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class myToast{
  String title;

  myToast({required this.title,})
  {
    Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        backgroundColor: Colors.grey,
        fontSize: 18.0
    );
  }
}
