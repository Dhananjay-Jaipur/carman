import 'package:flutter/material.dart';

class myDilogue{
  String title;
  final context;

  myDilogue({required this.title, required this.context})
  {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
              title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    );
  }
}
