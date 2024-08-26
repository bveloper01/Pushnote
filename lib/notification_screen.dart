import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoficationScreen extends StatefulWidget {
  const NoficationScreen({Key? key}) : super(key: key);

  @override
  State<NoficationScreen> createState() => _NoficationScreenState();
}

class _NoficationScreenState extends State<NoficationScreen> {
  // Dummy notification data
  final List<Map<String, String>> notifications = [
    {
      'title': 'Task status updated',
      'subtitle': 'You received a status update',
    },
    {
      'title': 'Task status updated',
      'subtitle': 'You received a status update',
    },
    {
      'title': 'Text Message',
      'subtitle': 'Text message from Workspace Nexus',
    },
    {
      'title': 'Text Message',
      'subtitle': 'Text message from Workspace Nexus',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: 275,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), bottomRight: Radius.circular(0)),
        ),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                  padding: EdgeInsets.only(left: 20, top: 40),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 196, 219, 237),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book_rounded,
                        size: 50,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Pushnote',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      )
                    ],
                  )),
              Column(
                children: [
                  ListTile(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
                    leading: const Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                    ),
                    title: const Text(
                      'Signout',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        toolbarHeight: 68,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color.fromARGB(255, 23, 23, 23),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'No new notification',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}



