import 'package:flutter/material.dart';

class AllPostCard extends StatefulWidget {
  final String? description;
  final String? image;

  const AllPostCard({
    Key? key,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  State<AllPostCard> createState() => _AllPostCardState();
}

class _AllPostCardState extends State<AllPostCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
        top: 10.0,
      ),
      child: Card(
        shadowColor: Colors.black,
        color: Colors.grey.shade200,
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
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Text(
                    widget.description!,
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
