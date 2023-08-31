import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String? name;
  final String? image;

  const PostCard({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 20.0,
      ),
      child: Card(
        shadowColor: Colors.black,
        color: Colors.orangeAccent,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 60,
          width: 200, // Set a fixed width for the container
          child: Stack(
            children: [
              Image.network(
                image!,
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  name!,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
