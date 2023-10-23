import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          child: FittedBox(
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
      backgroundColor: Color.fromARGB(255, 204, 220, 235),
    );
  }
}
