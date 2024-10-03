import 'package:flutter/material.dart';

class mySnakbar{

  String title;
  final context;

  mySnakbar({required this.title, required this.context}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}