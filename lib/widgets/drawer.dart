import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Drawer(
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
                    onTap: () {},
                    leading: const Icon(
                      Icons.dark_mode,
                      size: 22,
                    ),
                    title: const Text(
                      'Darkmode',
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
      ),
    );
  }
}
