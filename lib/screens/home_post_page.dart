import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:island_tour_planner/components/home_widgets/all_post_card.dart';
import 'package:island_tour_planner/components/nav_bar.dart';

class HomePostPage extends StatefulWidget {
  const HomePostPage({Key? key}) : super(key: key);

  @override
  State<HomePostPage> createState() => _HomePostPageState();
}

class _HomePostPageState extends State<HomePostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topRight,
          child: Text(
            'Posts',
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
              'All Popular Posts'.toUpperCase(),
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
                stream:
                    FirebaseFirestore.instance.collection('posts').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final data = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final imageUrl = data[index]['image_url'];
                      final description = data[index]['description'];

                      return AllPostCard(
                        description: description,
                        image: imageUrl,
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
