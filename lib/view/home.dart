import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:findify_new_demo/post_model.dart';
import 'package:findify_new_demo/widget/post_tile.dart';
import 'package:findify_new_demo/view/inbox.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Smooth background matching theme
      appBar: AppBar(
        title: Text(
          'Findify',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: const Color(0xFFFF7B00),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline_rounded, color: Color(0xFFFF7B00), size: 28,),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()));
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                style: GoogleFonts.inter(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search for posts...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF7B00)),
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .where('status', isEqualTo: 'ACTIVE')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading posts!",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var allDocs = snapshot.data!.docs.toList();
            allDocs.sort((a, b) {
               final dateA = DateTime.tryParse((a.data() as Map<String, dynamic>)['createdAt']?.toString() ?? '') ?? DateTime.now();
               final dateB = DateTime.tryParse((b.data() as Map<String, dynamic>)['createdAt']?.toString() ?? '') ?? DateTime.now();
               return dateB.compareTo(dateA); // descending
            });

            // Filter posts containing the search query as a substring
            final filteredPosts = allDocs.where((doc) {
              final description = (doc.data() as Map<String, dynamic>)['description']?.toString().toLowerCase() ?? '';
              final location = (doc.data() as Map<String, dynamic>)['location']?.toString().toLowerCase() ?? '';
              return description.contains(_searchQuery) || location.contains(_searchQuery);
            }).toList();

            if (filteredPosts.isNotEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final postData = filteredPosts[index].data() as Map<String, dynamic>;
                  PostModel post = PostModel.fromJson(postData);
                  return PostTile(post: post);
                },
              );
            } else {
              return const Center(
                child: Text(
                  "No posts found!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
          }

          return const Center(
            child: Text(
              "No posts available!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
