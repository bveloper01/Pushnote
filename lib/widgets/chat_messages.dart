import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 2.5,
            ),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/empty.png"),
                  width: 180.0,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Text(
                    "There are no recent messages",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/wrong.png"),
                  width: 210.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
            reverse: true,
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 13, right: 13),
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessages = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserID = chatMessages['userId'];
              final nextMessageUserID =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserID == currentMessageUserID;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == currentMessageUserID);
              } else {
                return MessageBubble.first(
                    userImage: chatMessages['userImage'],
                    username: chatMessages['userName'],
                    message: chatMessages['text'],
                    isMe: authenticatedUser.uid == currentMessageUserID);
              }
            });
      },
    );
  }
}
