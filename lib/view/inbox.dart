import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text("Not logged in"));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text("Messages", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFFF7B00))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          
          var activeDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['postStatus'] != 'RESOLVED';
          }).toList();

          if (activeDocs.isEmpty) {
            return Center(child: Text("No active messages yet", style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 16)));
          }

          var allDocs = activeDocs;
          allDocs.sort((a, b) {
            final docA = a.data() as Map<String, dynamic>;
            final docB = b.data() as Map<String, dynamic>;
            final dA = DateTime.tryParse(docA['lastUpdated'] ?? '') ?? DateTime.now();
            final dB = DateTime.tryParse(docB['lastUpdated'] ?? '') ?? DateTime.now();
            return dB.compareTo(dA);
          });

          return ListView.builder(
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              final chat = allDocs[index].data() as Map<String, dynamic>;
              final users = List<String>.from(chat['users'] ?? []);
              final otherUserId = users.firstWhere((id) => id != currentUser.uid, orElse: () => '');

              return ListTile(
                tileColor: Colors.white,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFF7B00).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFFFF7B00)),
                ),
                title: Text(chat['postTitle'] ?? 'Chat', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(chat['lastMessage'] ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    chatId: chat['chatId'],
                    postId: chat['postId'] ?? '',
                    postTitle: chat['postTitle'] ?? 'Chat',
                    otherUserId: otherUserId,
                  )));
                },
              );
            },
          );
        },
      ),
    );
  }
}
