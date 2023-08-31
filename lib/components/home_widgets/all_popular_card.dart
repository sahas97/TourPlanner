import 'package:flutter/material.dart';

class AllPopularCard extends StatefulWidget {
  final String? description;
  final String? destination;
  final String? image;

  const AllPopularCard({
    Key? key,
    required this.description,
    required this.image,
    this.destination,
  }) : super(key: key);

  @override
  State<AllPopularCard> createState() => _AllPopularCardState();
}

class _AllPopularCardState extends State<AllPopularCard> {
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
        color: Colors.grey.shade100,
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
                  height: 200,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    widget.destination!,
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                height: 100,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Descreption",
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
          ],
        ),
      ),
    );
  }
}
