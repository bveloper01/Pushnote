import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 204, 220, 235),
        leading: IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 75),
          child: const FittedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
