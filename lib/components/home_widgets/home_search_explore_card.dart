import 'package:flutter/material.dart';

import '../../models/hotel_data.dart';

class SearchExploreCard extends StatefulWidget {
  final HotelData hotelData; // Replace the individual fields with HotelData
  final VoidCallback? onTapEdit;

  const SearchExploreCard({
    Key? key,
    required this.hotelData,
    this.onTapEdit,
  }) : super(key: key);

  @override
  State<SearchExploreCard> createState() => _SearchExploreCardState();
}

class _SearchExploreCardState extends State<SearchExploreCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapEdit,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0,
          top: 10.0,
        ),
        child: Card(
          shadowColor: Colors.black,
          color: Colors.orangeAccent,
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.hotelData.image!,
                    height: 240,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      widget.hotelData.hotelName!,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 0,
                    child: Text(
                      'Phone: ${widget.hotelData.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 26,
                    child: Text(
                      'One Night Prize: ${widget.hotelData.oneNightPrize}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 52,
                    child: Text(
                      'Address: ${widget.hotelData.hotelAddress}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 78,
                    child: Text(
                      'Book Status: ${widget.hotelData.bookStatus}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  //top: 10.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: 10.0,
                ),
                child: SizedBox(
                  height: 90,
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.hotelData.description!,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
