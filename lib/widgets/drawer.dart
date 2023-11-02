import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/status_update_sreen.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  var designation = false;

  void getdata() async {
    final devtoken = FirebaseAuth.instance.currentUser!;
    final currUsertoken = await FirebaseFirestore.instance
        .collection('users')
        .doc(devtoken.uid)
        .get();
    final role = currUsertoken.data()!['role'];
    setState(() {
      if (role == 'Employee') {
        designation = false;
      } else {
        designation = true;
      }
    });
  }

  @override
  void initState() {
    getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    )
                  ],
                )),
            Column(
              children: [
                if (designation)
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskStatusListPage()));
                    },
                    leading: const Icon(
                      Icons.update,
                      size: 22,
                    ),
                    title: const Text(
                      'Task status updates',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
    );
  }
}
