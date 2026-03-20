import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:findify_new_demo/controller/create_controller.dart';
import 'package:provider/provider.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateController(), // Provide a single instance
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: Text(
            'Create Post',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: const Color(0xFFFF7B00),
            ),
          ),
          actions: [
            Consumer<CreateController>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7B00)),
                  ),
                )
                    : IconButton(
                  onPressed: () async {
                    try {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null || provider.image == null) {
                        provider.setLoading(true); // Set loading to true
                        await provider.uploadImage(provider.image!);
                        await provider.addPost(userId!);
                        provider.setLoading(false); // Set loading to false
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Post added successfully!")),
                        );
                      } else {
                        throw Exception("User not authenticated.");
                      }
                    } catch (e) {
                      provider.setLoading(false); // Set loading to false
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to add post: $e")),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 28, color: Color(0xFFFF7B00)),
                );
              },
            ),
          ],
        ),

        floatingActionButton: Consumer<CreateController>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  provider.pickImage(context);
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7B00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7B00).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Consumer<CreateController>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      children: [
                        // Caption Input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              provider.description = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Add Location",
                              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF6B7280)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onChanged: (value) {
                              provider.location = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: provider.type,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
                              items: const [
                                DropdownMenuItem(value: 'LOST', child: Text('Lost Item')),
                                DropdownMenuItem(value: 'FOUND', child: Text('Found Item')),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  provider.type = newValue;
                                  provider.notifyListeners();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: provider.image == null ? Colors.grey.shade200 : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            image: provider.image != null
                                ? DecorationImage(
                                    image: kIsWeb 
                                        ? NetworkImage(provider.image!.path) 
                                        : FileImage(File(provider.image!.path).absolute) as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: provider.image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_rounded, size: 80, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Tap the camera button to add an image",
                                      style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 16),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        const SizedBox(height: 80), // Padding for the floating action button
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
