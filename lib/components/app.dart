import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findify_new_demo/view/home.dart';
import 'package:findify_new_demo/view/my_posts.dart';
import 'package:findify_new_demo/view/create.dart';
import 'package:findify_new_demo/view/profile.dart';

import '../user_model.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User? user = FirebaseAuth.instance.currentUser;

  int selectedIndex = 0;

  UserModel? convertFirebaseUserToUserModel(User? user) {
    if (user != null) {
      return UserModel(
        email: user.email ?? '',
        name: user.displayName ?? '',
        imgUrl: user.photoURL ?? '',
        description: '',
        phone: user.phoneNumber ?? '',
        id: user.uid,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Home(),
      const CreatePage(),
      const MyPostsPage(),
      ProfilePage(profileUser: convertFirebaseUserToUserModel(user)),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: const Color(0xFFFF7B00).withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: const Color(0xFFFF7B00),
                );
              }
              return GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: const Color(0xFF6B7280),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFFF7B00), size: 26);
              }
              return const IconThemeData(color: Color(0xFF6B7280), size: 24);
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.plus_square_fill_on_square_fill),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark),
                label: 'My Posts',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.person_crop_square_fill),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
