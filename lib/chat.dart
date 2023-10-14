import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Chat'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ))
        ],
      ),
      body: const Center(
          child: Text(
        'Yeh!! Logged in',
        style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
      )),
      backgroundColor: Color.fromARGB(153, 239, 224, 224),
    );
  }
}
