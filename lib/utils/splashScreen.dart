
import 'package:carman/pages/user/UserHome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class BookingDone extends StatefulWidget {

  var GuestName;
  var BookingDate;
  var location;
  var regNo;

  BookingDone({super.key, required this.GuestName, required this.BookingDate, required this.location, required this.regNo});

  @override
  State<BookingDone> createState() => _BookingDoneState();

}

class _BookingDoneState extends State<BookingDone> {
  @override
  void initState() {


    Future.delayed(const Duration(milliseconds: 3800), () {
      setState(() {
        Get.offAll(() => const UserHome());
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Thankyou!  ",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              width: Get.width * 0.3,
              child: Image.asset("assets/booking.png"),
            ),

            const SizedBox(height: 30,),

            const Text(
              "Request Submited Successfully",
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20,),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black26),
              ),
              child: Column(
                children: [
                  const Text(
                    "Booking Details",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 18,
                      ),

                      const Text(
                        "  Guest name :  ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        "${widget.GuestName}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                        size: 18,
                      ),

                      const Text(
                        "  Booking Date :  ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        "${widget.BookingDate}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.black,
                        size: 18,
                      ),

                      const Text(
                        "  Location :  ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        "${widget.location}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.local_car_wash,
                        color: Colors.black,
                        size: 18,
                      ),
                      
                      const Text(
                        "  Reg No :  ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Text(
                        "${widget.regNo}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
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
    );
  }
}


// ====================================================================================================



class BookingSubmited extends StatefulWidget {


  const BookingSubmited({super.key});

  @override
  State<BookingSubmited> createState() => _BookingSubmitedState();

}

class _BookingSubmitedState extends State<BookingSubmited> {
  @override
  void initState() {


    Future.delayed(const Duration(milliseconds: 3800), () {
      setState(() {
        Get.offAll(() => const UserHome());
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Thankyou!  ",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              width: Get.width * 0.3,
              child: Image.asset("assets/booking.png"),
            ),

            const SizedBox(height: 30,),

            const Text(
              "Your request has been submited",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20,),

            const Text(
              "You will bw notifie soon",
              style: TextStyle(
                fontSize: 20,
              ),
            ),


          
          ],
        ),
      ),
    );
  }
}
