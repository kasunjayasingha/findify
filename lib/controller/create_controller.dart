import 'dart:io';
import 'package:flutter/material.dart'; // <--- Add this
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:math';

class CreateController with ChangeNotifier {
  final picker = ImagePicker();
  String? description;
  String? location;
  String type = 'LOST'; // Default type
  XFile? _image;
  XFile? get image => _image;
  String imageURL = "";
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Method to download image from URL and set it to _image
  Future<void> setImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (kIsWeb) {
          _image = XFile.fromData(
            response.bodyBytes,
            name: "image.jpg",
            mimeType: "image/jpeg",
          );
        } else {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/image.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          _image = XFile(filePath);
        }

        imageURL = url;
        notifyListeners();
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<void> pickGalleryImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 30, 
      maxWidth: 800, 
      maxHeight: 800,
    );

    if (pickedFile != null) {
      _image = pickedFile;
      notifyListeners();
    }
  }

  Future<void> pickCameraImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 30, 
      maxWidth: 800, 
      maxHeight: 800,
    );

    if (pickedFile != null) {
      _image = pickedFile;
      notifyListeners();
    }
  }

  void pickImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    pickCameraImage(context);
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.camera, color: Colors.black),
                  title: const Text("Camera"),
                ),
                ListTile(
                  onTap: () {
                    pickGalleryImage(context);
                    Navigator.pop(context);
                  },
                  leading: const Icon(Icons.photo_library, color: Colors.black),
                  title: const Text("Gallery"),
                ),
                ListTile(
                  onTap: () {
                    _showURLInputDialog(context);
                  },
                  leading: const Icon(Icons.link, color: Colors.black),
                  title: const Text("Image URL"),
                  subtitle: Text(
                    imageURL.isNotEmpty ? "Link added" : "No URL provided",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showURLInputDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Image URL"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Paste your image URL here",
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                imageURL = urlController.text;
                setImageFromUrl(imageURL);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      imageURL = "data:image/jpeg;base64,$base64Image";
      print("Image converted to Base64 successfully");
    } catch (e) {
      print("Error converting image: $e");
      throw Exception("Image conversion failed");
    }
  }

  Future<void> addPost(String userID) async {
    if (description == null ||
        description!.isEmpty ||
        location == null ||
        location!.isEmpty ||
        imageURL.isEmpty) {
      throw Exception("All fields are required");
    }

    try {
      String postId = FirebaseFirestore.instance.collection("posts").doc().id;

      final rnd = Random();
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      String code = "FND-${String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))))}";

      await FirebaseFirestore.instance.collection("posts").doc(postId).set({
        'postId': postId,
        'userId': userID,
        'type': type,
        'description': description,
        'location': location,
        'imageUrl': imageURL,
        'status': 'ACTIVE',
        'postCode': code,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Reset fields on success
      description = null;
      location = null;
      _image = null;
      imageURL = "";
    } catch (e) {
      print("Error adding post: $e");
      throw Exception("Failed to add post to Firestore");
    }
  }
}
