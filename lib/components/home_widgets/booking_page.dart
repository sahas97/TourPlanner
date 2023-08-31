import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/hotel_data.dart';

class BookingPage extends StatefulWidget {
  final HotelData hotelData;

  const BookingPage({
    Key? key,
    required this.hotelData,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool withoutMeal = false;
  bool withMeal = false;
  late bool booking;
  int numberOfNights = 1;
  double totalPrice = 0.0;

  final user = FirebaseAuth.instance.currentUser;

  void calculateTotalPrice() {
    double basePrice = double.parse(widget.hotelData.oneNightPrize!);
    double mealPrice = withoutMeal
        ? double.parse(widget.hotelData.withoutMealPrice!)
        : withMeal
            ? double.parse(widget.hotelData.withMealPrice!)
            : 0.0;
    totalPrice = basePrice * numberOfNights * (1 + mealPrice);
  }

  Future<void> _updateBookingStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('explore')
          .doc(widget.hotelData.id)
          .update({
        'book_status': true,
      });
    } catch (e) {
      print("Error updating book status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelData.hotelName!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.hotelData.image!,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                'Hotel Name: ${widget.hotelData.hotelName}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Phone Number: ${widget.hotelData.phoneNumber}'),
              Text(
                  'Hotel Email Address: ${widget.hotelData.hotelEmailAddress}'),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('explore')
                    .doc(widget.hotelData.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('Loading...');
                  }
                  final data = snapshot.data?.data();
                  final bookStatus = data?['book_status'] ?? false;

                  booking = bookStatus;

                  return Text(
                      'Book Status: ${bookStatus ? 'Booked' : 'Unbooked'}');
                },
              ),
              const SizedBox(height: 16),
              Text('Hotel Address: ${widget.hotelData.hotelAddress}'),
              Text('One Night Price: ${widget.hotelData.oneNightPrize}'),
              Text('Without Meal Price: ${widget.hotelData.withoutMealPrice}'),
              Text('With Meal Price: ${widget.hotelData.withMealPrice}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Number of Nights:'),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      onChanged: (value) {
                        setState(() {
                          numberOfNights = int.parse(value);
                          calculateTotalPrice();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: withoutMeal,
                    onChanged: (value) {
                      setState(() {
                        withoutMeal = value ?? false;
                        if (withoutMeal && withMeal) withMeal = false;
                        calculateTotalPrice();
                      });
                    },
                  ),
                  const Text('Without Meal'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: withMeal,
                    onChanged: (value) {
                      setState(() {
                        withMeal = value ?? false;
                        if (withMeal && withoutMeal) withoutMeal = false;
                        calculateTotalPrice();
                      });
                    },
                  ),
                  const Text('With Meal'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Do something with the calculated total price, e.g., show it in a dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Total Price'),
                        content: Text(
                            'Total Price: LKR ${totalPrice.toStringAsFixed(2)}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Calculate Price'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Do something with the empty button, e.g., show a dialog
                  if (booking == false) {
                    await _updateBookingStatus();
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Check Out'),
                          content: const Text(
                              'The Email is sent to the hotel, they will contact you later.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "Alredy Booked",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                  // ignore: use_build_context_synchronously
                },
                child: const Text('Check Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
