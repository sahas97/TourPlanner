import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:island_tour_planner/components/home_widgets/all_popular_card.dart';
import 'package:island_tour_planner/components/nav_bar.dart';

class HomePopularDestani extends StatefulWidget {
  const HomePopularDestani({Key? key}) : super(key: key);

  @override
  State<HomePopularDestani> createState() => _HomePopularDestaniState();
}

class _HomePopularDestaniState extends State<HomePopularDestani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topRight,
          child: Text(
            'Destinations',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //  Text widget here
            Text(
              'All Popular Destinations'.toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(
              height: 16,
            ), // Optional: Add some spacing between Text and ListView
            Expanded(
              // Use Expanded to allow the ListView to take all available space
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('popularDsetani')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final popular = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: popular.length,
                    itemBuilder: (context, index) {
                      final imageUrl = popular[index]['image_url'];
                      final description = popular[index]['description'];
                      final destination = popular[index]['destination'];
                      return AllPopularCard(
                        image: imageUrl,
                        description: description,
                        destination: destination,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
