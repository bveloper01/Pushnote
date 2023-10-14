import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/auth.dart';

class firstScreen extends StatelessWidget {
  const firstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 204, 220, 235),

      // Add a text widget to the top of the screen.
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 700, 40, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Some cool animations from Ajay',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()));
                },
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )),
          ],
        ),
      ),
    );
  }
}
