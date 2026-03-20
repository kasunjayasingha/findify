import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../post_model.dart';
import '../user_model.dart';
import '../view/profile.dart';
import 'dart:convert';

class PostTile extends StatefulWidget {
  const PostTile({super.key, required this.post, this.deleteOption = false});
  final PostModel post;
  final bool deleteOption;

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  void initState() {
    super.initState();
  }

  Future<UserModel?> fetchUserData() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("User")
          .where("userId", isEqualTo: widget.post.userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userDoc = userSnapshot.docs.first.data() as Map<String, dynamic>;
        return UserModel.fromJson(userDoc);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> deletePost() async {
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.post.postId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete the post!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox.shrink());
        }

        UserModel? user = snapshot.data;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(profileUser: user),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF7B00), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: user?.imgUrl != null && user!.imgUrl.toString().isNotEmpty
                                  ? (user.imgUrl!.toString().startsWith('data:image') 
                                      ? MemoryImage(base64Decode(user.imgUrl!.split(',').last)) 
                                      : NetworkImage(user.imgUrl!)) as ImageProvider
                                  : const AssetImage("images/default_profile.png")
                                        as ImageProvider,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(profileUser: user),
                                ),
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? "Unknown User",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${widget.post.location} • ${timeago.format(widget.post.createdAt.toLocal())}",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.deleteOption)
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: Text("Delete Post", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              content: Text("Are you sure you want to delete this post?", style: GoogleFonts.inter()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey.shade600)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await deletePost();
                                  },
                                  child: Text("Delete", style: GoogleFonts.inter(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.post.type == 'LOST' ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.post.type,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.post.type == 'LOST' ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.post.imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(widget.post.imageUrl.split(',').last),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.post.imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
