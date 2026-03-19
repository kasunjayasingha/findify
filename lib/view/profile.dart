import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findify_new_demo/authentication/login.dart';
import 'package:findify_new_demo/controller/profile_controller.dart';
import 'package:findify_new_demo/user_model.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.profileUser});
  final UserModel? profileUser;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.profileUser;
    return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: const Color(0xFFFF7B00),
            ),
          ),
        ),
        body: ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: Consumer<ProfileController>(
              builder: (context, provider, child){
                return Stack(
                  children: [
                    Column(
                      children: [
                        // StreamBuilder to fetch user data from Firestore
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("User")
                              .where("id", isEqualTo: user?.id)
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return const Center(child: Text("An error occurred."));
                            }

                            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                              var userDoc = snapshot.data!.docs.first;

                              return Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.all(16.0),
                                  children: [
                                    // Displaying profile image in a container with border radius
                                    Stack(
                                        alignment: Alignment.bottomCenter,
                                        children:[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 13.0),
                                            child: Container(
                                              width: 140, // Size of the image (matching CircleAvatar's radius * 2)
                                              height: 140,
                                              padding: const EdgeInsets.all(4), // slightly thicker gap
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white, // inner ring
                                                border: Border.all(
                                                  width: 3,
                                                  color: const Color(0xFFFF7B00), // Our vibrant orange
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF7B00).withOpacity(0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                                // Set shape to rectangle
                                                // 50% border radius makes it circular
                                                image: DecorationImage(
                                                  image: provider.image == null
                                                      ? userDoc['imgUrl'] == ""
                                                      ? const AssetImage("images/default_profile.png")
                                                      : NetworkImage(userDoc['imgUrl']) as ImageProvider
                                                      : FileImage(File(provider.image!.path).absolute),

                                                  fit: BoxFit.contain, // Ensures the image is contained within the box
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              provider.pickImage(context);
                                            },
                                            child: Container(

                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              ),
                                              child: const CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Color(0xFFFF7B00),
                                                child: Icon(Icons.add, size: 20, color: Colors.white,),
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Displaying user fields in a list manner
                                          Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Personal Information",
                                          style: GoogleFonts.poppins(
                                            fontSize: 22, // Set the font size
                                            fontWeight: FontWeight.bold, // Set the font weight
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(thickness: 2,),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Name",
                                            style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade500
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            userDoc['name'] ?? 'N/A',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                provider.showUsernameDialog(context);
                                              },
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.grey.shade400,
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 26),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Email",
                                            style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade500
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            userDoc['email'] ?? 'N/A',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey.shade400,
                                            )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 26),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Phone",
                                            style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade500
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            userDoc['phone'] ?? 'N/A',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                provider.showPhoneDialog(context);
                                              },
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.grey.shade400,
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 26),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Description",
                                            style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade500
                                            ),
                                          ),

                                        ),
                                        Expanded(
                                          flex: -1,
                                          child: GestureDetector(
                                            onTap: (){
                                              provider.showDescriptionDialog(context);
                                            },
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),

                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Text(
                                            userDoc['description'] ?? 'N/A',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black
                                            ),
                                          ),

                                        ),
                                      ],
                                    ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444),
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFEF4444).withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Log Out",
                                                style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }

                            return const Center(child: Text("No data available."));
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }
          ),
        )
    );
  }
}
