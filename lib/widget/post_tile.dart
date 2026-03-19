import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../components/post.dart';
import '../user_model.dart';
import '../view/profile.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PostTile extends StatefulWidget {
  const PostTile({super.key, required this.post, this.deleteOption = false});
  final Post post;
  final bool deleteOption;

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  String? userName;
  String? userImgUrl;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    likeCount = widget.post.likeCnt;
  }

  Future<UserModel?> fetchUserData() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("User")
          .where("id", isEqualTo: widget.post.userId)
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

  Future<void> toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });

    try {
      await FirebaseFirestore.instance
          .collection("Post")
          .doc(widget.post.id)
          .update({"like_cnt": likeCount});
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });
    }
  }

  Future<void> deletePost() async {
    try {
      await FirebaseFirestore.instance
          .collection("Post")
          .doc(widget.post.id)
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
          return const Center(child: Text(""));
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading user data"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("User data not found"));
        }

        UserModel user = snapshot.data!;

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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(profileUser: user),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF7B00), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: user.imgUrl != null
                                  ? NetworkImage(user.imgUrl!)
                                  : const AssetImage("images/default_profile.png")
                                        as ImageProvider,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(profileUser: user),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? "Loading...",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${widget.post.location} • ${timeago.format(widget.post.createdAt.toDate().toLocal())}",
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
                Text(
                  widget.post.caption,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.post.imgUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.post.imgUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: toggleLike,
                      child: Row(
                        children: [
                          FaIcon(
                            isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                            color: isLiked ? const Color(0xFFFF4B4B) : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$likeCount",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: isLiked ? const Color(0xFFFF4B4B) : const Color(0xFF6B7280),
                              fontWeight: isLiked ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.commentDots,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${widget.post.commentCnt}",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final imgUrl = widget.post.imgUrl;
                          final url = Uri.parse(imgUrl);
                          final response = await http.get(url);
                          if (response.statusCode == 200) {
                            final bytes = response.bodyBytes;
                            final temp = await getTemporaryDirectory();
                            final path = '${temp.path}/image.jpg';
                            final file = File(path);
                            await file.writeAsBytes(bytes);
                            await Share.shareXFiles([XFile(path)], text: widget.post.caption);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to download the image")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error occurred: $e")),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.shareNodes,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${widget.post.shareCnt}",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
