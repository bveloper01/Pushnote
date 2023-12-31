import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/globalchat_screen.dart';
import 'package:push_drive/profile_screen.dart';
import 'package:push_drive/widgets/drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var dp;
  void userImage() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final String profileImage = currUserData.data()!['image_url'];

    setState(() {
      dp = profileImage;
    });
  }

  @override
  void initState() {
    userImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        toolbarHeight: 68,
        title: Row(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'All chats',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            dp == null
                ? const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color.fromARGB(255, 223, 249, 250),
                    foregroundImage: AssetImage(
                      'Images/avatar.png',
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
                      radius: 23,
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(dp),
                    ),
                  ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                    elevation: 2.5,
                    color: Colors.white.withOpacity(1),
                    child: SizedBox(
                      height: 80,
                      child: Center(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GlobalChatScreen()),
                            );
                          },
                          leading: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            foregroundImage: AssetImage(
                              'Images/workspace.png',
                            ),
                          ),
                          title: const Text(
                            'Workspace Nexus',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
