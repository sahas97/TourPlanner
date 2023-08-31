import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:island_tour_planner/components/admin_nav_bar.dart';
import '../components/information_card.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _descriptionController = TextEditingController();
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
          await FirebaseFirestore.instance.collection('posts').get();

      setState(() {
        _cardDataList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'image_url': doc['image_url'],
                  'description': doc['description'],
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

  Future<void> saveDataToFirestore(String imageUrl, String description) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('posts').add({
      'image_url': imageUrl,
      'description': description,
    });

    String docId = docRef.id;
    setState(() {
      _cardDataList.add({
        'id': docId,
        'image_url': imageUrl,
        'description': description,
      });
    });
  }

  void submitData() async {
    if (_imageFile == null || _descriptionController.text.isEmpty) {
      return;
    }

    try {
      String? imageUrl = await uploadImageToStorage(_imageFile!);
      if (imageUrl != null) {
        await saveDataToFirestore(imageUrl, _descriptionController.text);
        setState(() {
          _imageFile = null;
          _descriptionController.clear();
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

    showDialog(
      context: context,
      builder: (context) {
        File? updatedImageFile;
        TextEditingController descriptionController =
            TextEditingController(text: description);

        return AlertDialog(
          title: const Text('Edit Image and Description'),
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
                        .collection('posts')
                        .doc(documentId)
                        .update({'image_url': imageUrl});
                  }

                  setState(() {
                    _cardDataList[index]['image_url'] = imageUrl;
                    _cardDataList[index]['description'] =
                        descriptionController.text;
                  });
                }

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(documentId)
                    .update({'description': descriptionController.text});

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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text('Add Image and Description'),
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
                          descriptionController.text.isEmpty) {
                        return;
                      }

                      try {
                        String? imageUrl =
                            await uploadImageToStorage(imageFile!);

                        if (imageUrl != null) {
                          await saveDataToFirestore(
                            imageUrl,
                            descriptionController.text,
                          );
                        }

                        setState(() {
                          _cardDataList.add({
                            'image_url': imageUrl,
                            'description': descriptionController.text,
                          });
                        });

                        imageFile = null;
                        descriptionController.clear();

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
          .collection('posts')
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
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Add Post',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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
                final documentId = data[index].id;

                return InformationCard(
                  description: description,
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
