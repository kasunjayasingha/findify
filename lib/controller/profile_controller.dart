import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class ProfileController with ChangeNotifier{
  CollectionReference ref = FirebaseFirestore.instance.collection('User');
  User? user = FirebaseAuth.instance.currentUser;

  final picker = ImagePicker();
  XFile? _image;
  XFile? get image => _image;
  String imageURL = "";
  String name = "";
  String address = "";

  Future pickGalleryImage(BuildContext context) async{
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 30,
      maxWidth: 800,
      maxHeight: 800,
    );

    if(pickedFile != null){
      _image = pickedFile;
      await uploadImage(_image!);
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context) async{
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 30,
      maxWidth: 800,
      maxHeight: 800,
    );

    if(pickedFile != null){
      _image = pickedFile;
      await uploadImage(_image!);
      notifyListeners();
    }
  }

  void pickImage(context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: SizedBox(
              height: 200,
              child: Column(
                children: [
                  ListTile(
                    onTap: (){
                      pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.camera, color: Colors.black,),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: (){
                      pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.photo_library, color: Colors.black,),
                    title: const Text("Gallery"),
                  ),
                  ListTile(
                    onTap: (){
                      _showURLInputDialog(context);
                    },
                    leading: const Icon(Icons.link, color: Colors.black,),
                    title: const Text("Image URL"),
                    subtitle: Text(imageURL.isNotEmpty? "Link added":"No URL provided",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Future<void> setImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (kIsWeb) {
          _image = XFile.fromData(response.bodyBytes, name: "image.jpg", mimeType: "image/jpeg");
        } else {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/image.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          _image = XFile(filePath);
        }

        imageURL = url;
        changeData(imageURL, "profileImageUrl");
        notifyListeners();
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
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

  void showUsernameDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Name"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Name",
            ),
            keyboardType: TextInputType.name,
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
                name = urlController.text;
                changeData(name, "name");
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void showAddressDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Address"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Address",
            ),
            keyboardType: TextInputType.streetAddress,
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
                address = urlController.text;
                changeData(address, "address");
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void changeData(String value, String docField) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection("User")
          .where("userId", isEqualTo: user?.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userDoc = snapshot.docs.first;
        await FirebaseFirestore.instance
            .collection("User")
            .doc(userDoc.id)
            .update({docField: value});

        debugPrint("$docField updated successfully!");
      } else {
        debugPrint("No user document found.");
      }
    } catch (e) {
      debugPrint("Error updating $docField: $e");
    }
  }

  Future<void> uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      String downloadUrl = "data:image/jpeg;base64,$base64Image";
      
      changeData(downloadUrl, "profileImageUrl");
    } catch (e) {
      debugPrint("Error converting image: $e");
    }
  }
}

