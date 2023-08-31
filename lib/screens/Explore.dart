import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:island_tour_planner/components/admin_nav_bar.dart';

import '../components/explore_card.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _hotelAddressController = TextEditingController();
  final TextEditingController _oneNightPrizeController =
      TextEditingController();
  final TextEditingController _withoutMealPriceController =
      TextEditingController();
  final TextEditingController _withMealPriceController =
      TextEditingController();
  final TextEditingController _hotelEmailController = TextEditingController();

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
          await FirebaseFirestore.instance.collection('explore').get();

      setState(() {
        _cardDataList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'image_url': doc['image_url'],
                  'description': doc['description'],
                  'hotel_name': doc['hotel_name'],
                  'phone_number': doc['phone_number'],
                  'hotel_address': doc['hotel_address'],
                  'book_status': doc['book_status'],
                  'one_night_prize': doc['one_night_prize'],
                  'without_meal_price': doc['without_meal_price'],
                  'with_meal_price': doc['with_meal_price'],
                  'hotel_email_address': doc['hotel_email_address'],
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
    String imageUrl,
    String description,
    String hotelName,
    String phoneNumber,
    String hotelAddress,
    bool bookStatus,
    String oneNightPrize,
    String withoutMealPrice,
    String withMealPrice,
    String hotelEmailAddress,
  ) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('explore').add({
      'image_url': imageUrl,
      'description': description,
      'hotel_name': hotelName,
      'phone_number': phoneNumber,
      'hotel_address': hotelAddress,
      'book_status': bookStatus,
      'one_night_prize': oneNightPrize,
      'without_meal_price': withoutMealPrice,
      'with_meal_price': withMealPrice,
      'hotel_email_address': hotelEmailAddress,
    });

    String docId = docRef.id;
    setState(() {
      _cardDataList.add({
        'id': docId,
        'image_url': imageUrl,
        'description': description,
        'hotel_name': hotelName,
        'phone_number': phoneNumber,
        'hotel_address': hotelAddress,
        'book_status': bookStatus,
        'one_night_prize': oneNightPrize,
        'without_meal_price': withoutMealPrice,
        'with_meal_price': withMealPrice,
        'hotel_email_address': hotelEmailAddress,
      });
    });
  }

  void submitData() async {
    if (_imageFile == null ||
        _descriptionController.text.isEmpty ||
        _hotelNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _hotelAddressController.text.isEmpty ||
        _oneNightPrizeController.text.isEmpty ||
        _withoutMealPriceController.text.isEmpty ||
        _withMealPriceController.text.isEmpty ||
        _hotelEmailController.text.isEmpty) {
      return;
    }

    try {
      String? imageUrl = await uploadImageToStorage(_imageFile!);
      if (imageUrl != null) {
        await saveDataToFirestore(
          imageUrl,
          _descriptionController.text,
          _hotelNameController.text,
          _phoneNumberController.text,
          _hotelAddressController.text,
          false, // Default value for book_status is false
          _oneNightPrizeController.text,
          _withoutMealPriceController.text,
          _withMealPriceController.text,
          _hotelEmailController.text,
        );
        setState(() {
          _imageFile = null;
          _descriptionController.clear();
          _hotelNameController.clear();
          _phoneNumberController.clear();
          _hotelAddressController.clear();
          _oneNightPrizeController.clear();
          _withoutMealPriceController.clear();
          _withMealPriceController.clear();
          _hotelEmailController.clear();
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
    String hotelName = _cardDataList[index]['hotel_name'];
    String phoneNumber = _cardDataList[index]['phone_number'];
    String hotelAddress = _cardDataList[index]['hotel_address'];
    bool bookStatus = _cardDataList[index]['book_status'];
    String oneNightPrize = _cardDataList[index]['one_night_prize'];
    String withoutMealPrice = _cardDataList[index]['without_meal_price'];
    String withMealPrice = _cardDataList[index]['with_meal_price'];
    String hotelEmailAddress = _cardDataList[index]['hotel_email_address'];

    showDialog(
      context: context,
      builder: (context) {
        File? updatedImageFile;
        TextEditingController descriptionController =
            TextEditingController(text: description);
        TextEditingController hotelNameController =
            TextEditingController(text: hotelName);
        TextEditingController phoneNumberController =
            TextEditingController(text: phoneNumber);
        TextEditingController hotelAddressController =
            TextEditingController(text: hotelAddress);
        TextEditingController oneNightPrizeController =
            TextEditingController(text: oneNightPrize);
        TextEditingController withoutMealPriceController =
            TextEditingController(text: withoutMealPrice);
        TextEditingController withMealPriceController =
            TextEditingController(text: withMealPrice);
        TextEditingController hotelEmailController =
            TextEditingController(text: hotelEmailAddress);

        return AlertDialog(
          title: const Text('Edit Image, Description, and hotel_name'),
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
                  controller: hotelNameController,
                  decoration: const InputDecoration(
                    labelText: 'hotel_name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hotelAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Address',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: oneNightPrizeController,
                  decoration: const InputDecoration(
                    labelText: 'One Night Prize',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: withoutMealPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Without Meal Price',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: withMealPriceController,
                  decoration: const InputDecoration(
                    labelText: 'With Meal Price',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hotelEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Hotel Email Address',
                  ),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text('Book Status'),
                  value: bookStatus,
                  onChanged: (value) {
                    setState(() {
                      bookStatus = value ?? false;
                    });
                  },
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
                        .collection('explore')
                        .doc(documentId)
                        .update({
                      'image_url': imageUrl,
                    });
                  }

                  setState(() {
                    _cardDataList[index]['image_url'] = imageUrl;
                    _cardDataList[index]['description'] =
                        descriptionController.text;
                    _cardDataList[index]['hotel_name'] =
                        hotelNameController.text;
                    _cardDataList[index]['phone_number'] =
                        phoneNumberController.text;
                    _cardDataList[index]['hotel_address'] =
                        hotelAddressController.text;
                    _cardDataList[index]['one_night_prize'] =
                        oneNightPrizeController.text;
                    _cardDataList[index]['without_meal_price'] =
                        withoutMealPriceController.text;
                    _cardDataList[index]['with_meal_price'] =
                        withMealPriceController.text;
                    _cardDataList[index]['hotel_email_address'] =
                        hotelEmailController.text;
                    _cardDataList[index]['book_status'] = bookStatus;
                  });
                }

                await FirebaseFirestore.instance
                    .collection('explore')
                    .doc(documentId)
                    .update({
                  'description': descriptionController.text,
                  'hotel_name': hotelNameController.text,
                  'phone_number': phoneNumberController.text,
                  'hotel_address': hotelAddressController.text,
                  'one_night_prize': oneNightPrizeController.text,
                  'without_meal_price': withoutMealPriceController.text,
                  'with_meal_price': withMealPriceController.text,
                  'hotel_email_address': hotelEmailController.text,
                  'book_status': bookStatus,
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
    TextEditingController hotelNameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
    TextEditingController hotelAddressController = TextEditingController();
    TextEditingController oneNightPrizeController = TextEditingController();
    TextEditingController withoutMealPriceController = TextEditingController();
    TextEditingController withMealPriceController = TextEditingController();
    TextEditingController hotelEmailController = TextEditingController();
    bool bookStatus = false; // Default value for book_status is false

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: const Text('Add Image, Description, and hotel_name'),
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
                      controller: hotelNameController,
                      decoration: const InputDecoration(
                        labelText: 'hotel_name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hotelAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Hotel Address',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: oneNightPrizeController,
                      decoration: const InputDecoration(
                        labelText: 'One Night Prize',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: withoutMealPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Without Meal Price',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: withMealPriceController,
                      decoration: const InputDecoration(
                        labelText: 'With Meal Price',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hotelEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Hotel Email Address',
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('Book Status'),
                      value: bookStatus,
                      onChanged: (value) {
                        setState(() {
                          bookStatus = value ?? false;
                        });
                      },
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
                          hotelNameController.text.isEmpty ||
                          phoneNumberController.text.isEmpty ||
                          hotelAddressController.text.isEmpty ||
                          oneNightPrizeController.text.isEmpty ||
                          withoutMealPriceController.text.isEmpty ||
                          withMealPriceController.text.isEmpty ||
                          hotelEmailController.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Plese Check All Fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }

                      try {
                        String? imageUrl =
                            await uploadImageToStorage(imageFile!);

                        if (imageUrl != null) {
                          await saveDataToFirestore(
                            imageUrl,
                            descriptionController.text,
                            hotelNameController.text,
                            phoneNumberController.text,
                            hotelAddressController.text,
                            bookStatus,
                            oneNightPrizeController.text,
                            withoutMealPriceController.text,
                            withMealPriceController.text,
                            hotelEmailController.text,
                          );
                        }

                        setState(() {
                          _cardDataList.add({
                            'image_url': imageUrl,
                            'description': descriptionController.text,
                            'hotel_name': hotelNameController.text,
                            'phone_number': phoneNumberController.text,
                            'hotel_address': hotelAddressController.text,
                            'book_status': bookStatus,
                            'one_night_prize': oneNightPrizeController.text,
                            'without_meal_price':
                                withoutMealPriceController.text,
                            'with_meal_price': withMealPriceController.text,
                            'hotel_email_address': hotelEmailController.text,
                          });
                        });

                        imageFile = null;
                        descriptionController.clear();
                        hotelNameController.clear();
                        phoneNumberController.clear();
                        hotelAddressController.clear();
                        oneNightPrizeController.clear();
                        withoutMealPriceController.clear();
                        withMealPriceController.clear();
                        hotelEmailController.clear();

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
          .collection('explore')
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
          stream: FirebaseFirestore.instance.collection('explore').snapshots(),
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
                final hotelName = data[index]['hotel_name'];
                final phoneNumber = data[index]['phone_number'];
                final hotelAddress = data[index]['hotel_address'];
                final oneNightPrize = data[index]['one_night_prize'];
                final withoutMealPrice = data[index]['without_meal_price'];
                final withMealPrice = data[index]['with_meal_price'];
                final hotelEmailAddress = data[index]['hotel_email_address'];
                final documentId = data[index].id;

                return ExploreCard(
                  description: description,
                  hotelName: hotelName,
                  phoneNumber: phoneNumber,
                  hotelAddress: hotelAddress,
                  oneNightPrize: oneNightPrize,
                  withoutMealPrice: withoutMealPrice,
                  withMealPrice: withMealPrice,
                  hotelEmailAddress: hotelEmailAddress,
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
