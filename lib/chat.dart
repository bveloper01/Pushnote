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
      body: Center(
        child: Container(
          child: const FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage("images/loading.png"),
                  width: 230.0,
                ),
                Text(
                  "Strength is the only thing that matters in this world",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "- vegeta",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 31,
                ),
                SizedBox(
                  height: 31,
                  width: 31,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    color: Colors.blueAccent,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 204, 220, 235),
    );
  }
}
