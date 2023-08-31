import 'package:flutter/material.dart';

class ExploreCard extends StatefulWidget {
  final String? description;
  final String? hotelName;
  final String? image;
  final String? phoneNumber; // Add phoneNumber field
  final String? hotelAddress;
  final String? oneNightPrize; // Add oneNightPrize field
  final String? withoutMealPrice;
  final String? withMealPrice;
  final String? hotelEmailAddress;
  final VoidCallback? onTapEdit;
  final VoidCallback? onDelete; // Add the onDelete callback

  const ExploreCard({
    Key? key,
    required this.description,
    required this.image,
    required this.onTapEdit,
    required this.onDelete,
    this.hotelName,
    this.phoneNumber,
    this.hotelAddress,
    this.oneNightPrize,
    this.withoutMealPrice,
    this.withMealPrice,
    this.hotelEmailAddress,
  }) : super(key: key);

  @override
  State<ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard> {
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
                    widget.image!,
                    height: 240,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      widget.hotelName!,
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
                      'Phone: ${widget.phoneNumber}',
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
                      'One Night Prize: ${widget.oneNightPrize}',
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
                          widget.description!,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: widget.onTapEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
