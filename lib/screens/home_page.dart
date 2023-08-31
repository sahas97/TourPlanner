import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:island_tour_planner/components/home_widgets/home_explore_card.dart';
import 'package:island_tour_planner/components/home_widgets/popular_card.dart';
import 'package:island_tour_planner/components/nav_bar.dart';
import 'package:island_tour_planner/screens/home_popular_destani_page.dart';
import 'package:island_tour_planner/screens/home_post_page.dart';
import '../components/home_widgets/post_card.dart';
import 'hotel_explore_page.dart'; // Import the PostCard widget

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topRight,
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Show Posts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const HomePostPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: SizedBox(
                  height: 150,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final posts = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final imageUrl = posts[index]['image_url'];
                          final description = posts[index]['description'];

                          return PostCard(
                            name: description,
                            image: imageUrl,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 3.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Popular Destination",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const HomePopularDestani(),
                        ),
                      ),
                      child: Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 5.0,
                ),
                child: SizedBox(
                  height: 250,
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
                          return PopularCard(
                            image: imageUrl,
                            description: description,
                            destination: destination,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 20.0,
                  bottom: 10.0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('explore')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final explore = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: explore.length,
                        itemBuilder: (context, index) {
                          final imageUrl = explore[index]['image_url'];
                          final hotelName = explore[index]['hotel_name'];

                          return HomeExploreCard(
                            name: hotelName,
                            image: imageUrl,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const ExploreListView(),
            ),
          ),
        },
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
