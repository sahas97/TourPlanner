import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:island_tour_planner/components/home_widgets/booking_page.dart';
import 'package:island_tour_planner/components/home_widgets/home_search_explore_card.dart';
import '../models/hotel_data.dart';

class ExploreListView extends StatefulWidget {
  const ExploreListView({Key? key}) : super(key: key);

  @override
  _ExploreListViewState createState() => _ExploreListViewState();
}

class _ExploreListViewState extends State<ExploreListView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDataList = [];
  bool _searchMode = false;

  @override
  void initState() {
    super.initState();
    _fetchExploreData(); // Fetch the explore data when the widget initializes
  }

  // Function to fetch the explore data from Firestore
  void _fetchExploreData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('explore').get();

      setState(() {
        _filteredDataList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'image_url': doc['image_url'],
                  'description': doc['description'],
                  'hotel_name': doc['hotel_name'],
                  'phone_number': doc['phone_number'],
                  'hotel_address': doc['hotel_address'],
                  'one_night_prize': doc['one_night_prize'],
                  'without_meal_price': doc['without_meal_price'],
                  'with_meal_price': doc['with_meal_price'],
                  'hotel_email_address': doc['hotel_email_address'],
                  'book_status': doc['book_status'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching explore data: $e");
    }
  }

  // Function to filter the explore data based on address
  void _filterData(String address) {
    if (address.isEmpty) {
      setState(() {
        _filteredDataList = [..._filteredDataList];
        _searchMode = false;
      });
      return;
    }

    final filteredList = _filteredDataList
        .where((item) => item['hotel_address']
            .toString()
            .toLowerCase()
            .contains(address.toLowerCase()))
        .toList();

    setState(() {
      _filteredDataList = filteredList;
      _searchMode = true;
    });
  }

  // Method to navigate to RegisterPage with data
  void _onTapEdit(int index) {
    final data = _filteredDataList[index];
    HotelData hotelData = HotelData(
      id: data['id'],
      description: data['description'],
      hotelName: data['hotel_name'],
      image: data['image_url'],
      phoneNumber: data['phone_number'],
      hotelAddress: data['hotel_address'],
      oneNightPrize: data['one_night_prize'],
      withoutMealPrice: data['without_meal_price'],
      withMealPrice: data['with_meal_price'],
      hotelEmailAddress: data['hotel_email_address'],
      bookStatus: data['book_status'].toString(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          hotelData: hotelData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchMode
            ? TextField(
                controller: _searchController,
                onChanged: _filterData,
                decoration: const InputDecoration(
                  hintText: 'Search by address...',
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'Explore Data',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              if (_searchMode) {
                _searchController.clear();
                _filterData('');
              }
              setState(() {
                _searchMode = !_searchMode;
              });
            },
            icon: Icon(
                _searchMode ? Icons.clear : Icons.search), // Toggle search icon
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _filteredDataList.length,
          itemBuilder: (context, index) {
            return SearchExploreCard(
              hotelData: HotelData(
                description: _filteredDataList[index]['description'],
                hotelName: _filteredDataList[index]['hotel_name'],
                image: _filteredDataList[index]['image_url'],
                phoneNumber: _filteredDataList[index]['phone_number'],
                hotelAddress: _filteredDataList[index]['hotel_address'],
                oneNightPrize: _filteredDataList[index]['one_night_prize'],
                withoutMealPrice: _filteredDataList[index]
                    ['without_meal_price'],
                withMealPrice: _filteredDataList[index]['with_meal_price'],
                hotelEmailAddress: _filteredDataList[index]
                    ['hotel_email_address'],
                bookStatus: _filteredDataList[index]['book_status'].toString(),
              ),
              onTapEdit: () {
                _onTapEdit(index); // Redirect to RegisterPage
              },
            );
          },
        ),
      ),
    );
  }
}
