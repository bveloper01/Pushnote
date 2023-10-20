import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_drive/widgets/chat_messages.dart';
import 'package:push_drive/widgets/new_messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String displayName = '';
  var coloriing = true;
  void setUpPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    fcm.subscribeToTopic('Chat');

    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final userName = currUserData.data()!['username'];
    final role = currUserData.data()!['role'];

    setState(() {
      if (role == 'Employee') {
        coloriing = false;
      } else {
        coloriing = true;
      }
      displayName = userName;
    });
  }

  @override
  void initState() {
    // init state does not return a future
    super.initState();

    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(23),
                bottomRight: Radius.circular(23))),
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            coloriing
                ? const Text(
                    'Hi, Employer',
                    style: TextStyle(color: Colors.black38),
                  )
                : const Text(
                    'Hi, employee',
                    style: TextStyle(color: Colors.black38),
                  ),
            Text(
              displayName,
              style: TextStyle(
                  color: coloriing
                      ? const Color.fromARGB(255, 23, 23, 23)
                      : Colors.black87,
                  fontSize: 26),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.black,
                size: 26,
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 204, 220, 235),
    );
  }
}
