import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String dName = '';
  var rolecolor = true;
  var designation = '';
  var diss;
  void load() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final userName = currUserData.data()!['username'];
    final role = currUserData.data()!['role'];
    final String profileImage = currUserData.data()!['image_url'];

    setState(() {
      if (role == 'Employee') {
        rolecolor = false;
      } else {
        rolecolor = true;
      }
      dName = userName;
      designation = role;
      diss = profileImage;
    });
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: diss == null
                        ? const CircleAvatar(
                            radius: 68,
                            backgroundColor: Color.fromARGB(255, 223, 249, 250),
                            foregroundImage: AssetImage(
                              'images/avatar.png',
                            ),
                          )
                        : CircleAvatar(
                            radius: 68,
                            backgroundColor: Colors.white,
                            foregroundImage: NetworkImage(diss),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27),
                    child: Text(dName,
                        style: TextStyle(
                            color: rolecolor
                                ? const Color.fromARGB(255, 23, 23, 23)
                                : Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.w500)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(designation,
                        style: TextStyle(
                            color: rolecolor
                                ? const Color.fromARGB(255, 23, 23, 23)
                                : Colors.black54,
                            fontSize: 19,
                            fontWeight: FontWeight.w400)),
                  ),
                  Container(
                    height: 460,
                    padding: const EdgeInsets.only(left: 10, top: 30),
                    child: Column(
                      children: [
                        if (!rolecolor)
                          ListTile(
                            onTap: () {},
                            leading: const Icon(
                              Icons.report_problem,
                              color: Colors.black54,
                              size: 22,
                            ),
                            title: const Text(
                              'Raise a ticket',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                          ),
                        ListTile(
                          onTap: () {},
                          leading: const Icon(
                            Icons.bug_report_rounded,
                            color: Colors.black54,
                            size: 22,
                          ),
                          title: const Text(
                            'Report a bug',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text('vOct.0',
                    style: TextStyle(fontSize: 15, color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
