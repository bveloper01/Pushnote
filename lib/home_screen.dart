import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/profile_screen.dart';
import 'package:push_drive/widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var homedp;
  String homename = '';

  void homeImage() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final String profileImage = currUserData.data()!['image_url'];
    final String profileName = currUserData.data()!['username'];

    setState(() {
      homedp = profileImage;
      homename = profileName;
    });
  }

  @override
  void initState() {
    homeImage();
    super.initState();
  }

  void addTaskOverlay() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Text('d');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        toolbarHeight: 82,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              homename,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 18),
            child: homedp == null
                ? const CircleAvatar(
                    radius: 30,
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
                      radius: 30,
                      backgroundColor: Colors.white,
                      foregroundImage: NetworkImage(homedp),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
        elevation: 4,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: addTaskOverlay,
        child: Icon(Icons.add),
      ),
    );
  }
}
