import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_drive/profileScreen.dart';
import 'package:push_drive/widgets/chat_messages.dart';
import 'package:push_drive/widgets/drawer.dart';
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
  var dp;

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
    final String profileImage = currUserData.data()!['image_url'];

    setState(() {
      if (role == 'Employee') {
        coloriing = false;
      } else {
        coloriing = true;
      }
      displayName = userName;
      dp = profileImage;
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
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        toolbarHeight: 70,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: coloriing
                          ? const Color.fromARGB(255, 23, 23, 23)
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  //
                  Text(
                    displayName,
                    style: TextStyle(
                        color: coloriing
                            ? const Color.fromARGB(255, 23, 23, 23)
                            : Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            dp == null
                ? const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color.fromARGB(255, 223, 249, 250),
                    foregroundImage: AssetImage(
                      'images/avatar.png',
                    ),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(dp),
                    ),
                  ),
          ],
        ),
      ),
      drawer: const MainDrawer(),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 204, 220, 235),
    );
  }
}
