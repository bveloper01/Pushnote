import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/chat.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messageController.clear();

    final userHere = FirebaseAuth.instance.currentUser!;
    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userHere.uid)
        .get();
    FirebaseFirestore.instance.collection('Chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': userHere.uid,
      'userName': currUserData.data()!['username'],
      'userImage': currUserData.data()!['image_url'],
    });
  }

  Widget build(BuildContext context) {
    return Container(
      // color: Colors.amber,
      height: 60,
      padding: const EdgeInsets.only(left: 13, right: 6, bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            textInputAction: TextInputAction.send,
            onSubmitted: (value) {
              submitMessage();
            },
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              hintText: 'Send a message..',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )),
          SizedBox(
            height: 43,
            child: FloatingActionButton(
                shape: const CircleBorder(),
                elevation: 0,
                onPressed: submitMessage,
                child: const Icon(
                  Icons.send,
                  size: 22,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}
