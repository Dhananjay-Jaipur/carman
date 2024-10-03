// GIF link ::::::::::::::::::::::::::::
// https://loading.io/spinner/ellipsis 


import 'dart:async';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  int _currentDot = 0;
  final int _dotsCount = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _currentDot = (_currentDot + 1) % _dotsCount; // Loop through dots
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DotsIndicator(
        dotsCount: _dotsCount,
        position: _currentDot, // Set the active position
        decorator: const DotsDecorator(
          color: Colors.black54, // Inactive color
          activeColor: Colors.blue, // Active color
        ),
      ),
    );
  }
}
