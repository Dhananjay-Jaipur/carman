import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  double userRating = 0.0; // To store the user's input rating
  bool isTablet = false; // Simulate if it's tablet or not

  @override
  Widget build(BuildContext context) {
    // Determine whether the device is a tablet based on the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    isTablet = screenWidth > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65), // Custom height for the app bar
        child: Padding(
          padding: const EdgeInsets.only(left: 17, top: 10, right: 20),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset("assets/logo.png", height: double.infinity),
            ),
            title: _buildText("CARMAN", isTablet: isTablet),
            centerTitle: false,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : double.infinity, // Limit max width on tablets
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFDFEDED),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Booking ID Text
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      'Booking ID :',
                      style: TextStyle(
                        color: const Color(0xFF1565C0),
                        fontSize: isTablet ? 24 : 20, // Adjust font size for tablet
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
        
                  // User Feedback Text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: isTablet ? 30 : 24), // Adjust icon size
                        const SizedBox(width: 10),
                        Text(
                          'User Feedback',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isTablet ? 22 : 18, // Adjust font size for tablet
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
        
                  // Rating Bar (with input)
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SizedBox(
                      width: isTablet ? 300 : 200, // Adjust width for tablet
                      child: Column(
                        children: [
                          RatingBar.builder(
                            initialRating: userRating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                userRating = rating;
                              });
                            },
                            itemSize: isTablet ? 40 : 30, // Adjust star size for tablet
                          ),
                          Text('Rating: $userRating',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16, // Adjust font size for tablet
                              )),
                        ],
                      ),
                    ),
                  ),
        
                  // Comment EditText
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Comments for User',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 14, // Adjust font size for tablet
                        ),
                      ),
                      maxLines: 5,
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
        
                  // Image, Name, and Phone in a Row
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Image on the left
                        CircleAvatar(
                          radius: isTablet ? 40 : 30, // Adjust avatar size for tablet
                          backgroundImage: const AssetImage('assets/man.png'),
                        ),
                        const SizedBox(width: 20),
        
                        // Name and Phone Number on the right
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name
                            Text(
                              'Name',
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 18, // Adjust font size
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF535B9E),
                              ),
                            ),
                            const SizedBox(height: 10),
        
                            // Phone TextView
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.black),
                                const SizedBox(width: 5),
                                Text(
                                  'Contact No',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 18, // Adjust font size
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF535B9E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        
                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Replace with your function
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 60 : 50,
                            vertical: isTablet ? 20 : 15), // Adjust button padding for tablet
                        backgroundColor: const Color(0xFF00FF00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 22 : 18), // Adjust font size for tablet
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mocked _buildText method for title
  Widget _buildText(String text, {required bool isTablet}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTablet ? 24 : 20, // Adjust text size based on device
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
