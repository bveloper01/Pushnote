import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_drive/profile_screen.dart';
import 'package:push_drive/widgets/chat_messages.dart';
import 'package:push_drive/widgets/new_messages.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({
    super.key,
  });
  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  List<Map<String, dynamic>> allEmployees = [];
  double height = AppBar().preferredSize.height;
  void setUpPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('Chat');
  }

  void members() {
    Stream<List<Map<String, dynamic>>> getUsersStream() {
      return FirebaseFirestore.instance
          .collection('users')
          .orderBy('username')
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Map<String, dynamic>> sortedEmployees =
            querySnapshot.docs.map((doc) {
          return {
            'username': doc['username'] as String,
            'imageUrl': doc['image_url'] as String,
            'role': doc['role'] as String,
          };
        }).toList();
        sortedEmployees.sort((a, b) {
          // Place employers first by comparing their role
          if (a['role'] == 'Employer' && b['role'] != 'Employer') {
            return -1; // a comes before b
          } else if (a['role'] != 'Employer' && b['role'] == 'Employer') {
            return 1; // b comes before a
          }
          // For non-employers or when both are employers, sort alphabetically by username
          return a['username'].compareTo(b['username']);
        });
        return sortedEmployees;
      });
    }

    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            final List<Map<String, dynamic>> allEmployees = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12),
              itemCount: allEmployees.length,
              itemBuilder: (context, index) {
                final user = allEmployees[index];
                return Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  margin: const EdgeInsets.fromLTRB(3.2, 1, 3.2, 8),
                  elevation: 2,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    splashColor: Colors.transparent,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      backgroundImage: NetworkImage(user['imageUrl']),
                    ),
                    title: Text(
                      user['username'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(user['role'],
                        style: const TextStyle(fontWeight: FontWeight.w400)),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.blue,
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                ' Workspace Nexus',
                style: TextStyle(
                    color: Color.fromARGB(255, 23, 23, 23),
                    fontSize: 21,
                    fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: members,
              icon: const Icon(Icons.groups, size: 28),
            ),
            const SizedBox(
              width: 5,
            ),
            PopupMenuButton<int>(
              constraints: const BoxConstraints.expand(width: 150, height: 60),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              offset: Offset(0, height - 15),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
              child: const Icon(
                Icons.more_vert_rounded,
                size: 23,
              ),
            ),
          ],
        ),
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 239, 236, 226),
    );
  }
}
