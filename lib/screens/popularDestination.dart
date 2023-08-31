import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:island_tour_planner/components/admin_nav_bar.dart';
import 'package:island_tour_planner/components/popular_destani_card.dart';

class PopularDestani extends StatefulWidget {
  const PopularDestani({Key? key}) : super(key: key);

  @override
  State<PopularDestani> createState() => _PopularDestaniState();
}

class _PopularDestaniState extends State<PopularDestani> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  File? _imageFile;
  List<Map<String, dynamic>> _cardDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchCardData(); // Fetch the card data when the widget initializes
  }

  // Function to fetch the card data from Firestore
  void _fetchCardData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('popularDsetani').get();

      setState(() {
        _cardDataList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'image_url': doc['image_url'],
                  'description': doc['description'],
                  'destination': doc['destination'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching card data: $e");
    }
  }

  // Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
    firebase_storage.TaskSnapshot storageSnapshot = await uploadTask;
    var imageUrl = await storageSnapshot.ref.getDownloadURL();

    return imageUrl.toString();
  }

  Future<void> saveDataToFirestore(
      String imageUrl, String description, String destination) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('popularDsetani').add({
      'image_url': imageUrl,
      'description': description,
      'destination': destination,
    });

    String docId = docRef.id;
    setState(() {
      _cardDataList.add({
        'id': docId,
        'image_url': imageUrl,
        'description': description,
        'destination': destination,
      });
    });
  }

  void submitData() async {
    if (_imageFile == null ||
        _descriptionController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      return;
    }

    try {
      String? imageUrl = await uploadImageToStorage(_imageFile!);
      if (imageUrl != null) {
        await saveDataToFirestore(
            imageUrl, _descriptionController.text, _destinationController.text);
        setState(() {
          _imageFile = null;
          _descriptionController.clear();
          _destinationController.clear();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showEditDialog(int index, String documentId) async {
    String imageUrl = _cardDataList[index]['image_url'];
    String description = _cardDataList[index]['description'];
    String destination = _cardDataList[index]['destination'];

    showDialog(
      context: context,
      builder: (context) {
        File? updatedImageFile;
        TextEditingController descriptionController =
            TextEditingController(text: description);
        TextEditingController destinationController =
            TextEditingController(text: destination);

        return AlertDialog(
          title: const Text('Edit Image, Description, and Destination'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        updatedImageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (updatedImageFile != null) {
                  String? imageUrl =
                      await uploadImageToStorage(updatedImageFile!);

                  if (imageUrl != null) {
                    await FirebaseFirestore.instance
                        .collection('popularDsetani')
                        .doc(documentId)
                        .update({'image_url': imageUrl});
                  }

                  setState(() {
                    _cardDataList[index]['image_url'] = imageUrl;
                    _cardDataList[index]['description'] =
                        descriptionController.text;
                    _cardDataList[index]['destination'] =
                        destinationController.text;
                  });
                }

                await FirebaseFirestore.instance
                    .collection('popularDsetani')
                    .doc(documentId)
                    .update({
                  'description': descriptionController.text,
                  'destination': destinationController.text,
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() async {
    File? imageFile;
    TextEditingController descriptionController = TextEditingController();
    TextEditingController destinationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text('Add Image, Description, and Destination'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageFile != null)
                      Image.file(
                        imageFile!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            imageFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: const Text('Pick Image'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (imageFile == null ||
                          descriptionController.text.isEmpty ||
                          destinationController.text.isEmpty) {
                        return;
                      }

                      try {
                        String? imageUrl =
                            await uploadImageToStorage(imageFile!);

                        if (imageUrl != null) {
                          await saveDataToFirestore(
                            imageUrl,
                            descriptionController.text,
                            destinationController.text,
                          );
                        }

                        setState(() {
                          _cardDataList.add({
                            'image_url': imageUrl,
                            'description': descriptionController.text,
                            'destination': destinationController.text,
                          });
                        });

                        imageFile = null;
                        descriptionController.clear();
                        destinationController.clear();

                        Navigator.of(context).pop();
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDataFromFirestore(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('popularDsetani')
          .doc(documentId)
          .delete();
      firebase_storage.FirebaseStorage.instance.refFromURL(documentId).delete();
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminNavBar(),
      appBar: AppBar(
        title: const Text(
          'Admin Panel Home',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('popularDsetani')
              .snapshots(),
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
                final destination = data[index]['destination'];
                final documentId = data[index].id;

                return PopularDestaniCard(
                  description: description,
                  destination: destination,
                  image: imageUrl,
                  onTapEdit: () {
                    _showEditDialog(index, documentId);
                  },
                  onDelete: () {
                    _deleteDataFromFirestore(documentId);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
