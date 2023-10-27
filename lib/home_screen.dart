import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:push_drive/create_task_screen.dart';
import 'package:push_drive/models/overview_data.dart';
import 'package:push_drive/profile_screen.dart';
import 'package:push_drive/widgets/drawer.dart';
import 'package:push_drive/widgets/task_list.dart';
import 'package:push_drive/widgets/overview_grid_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var homedp;
  String homename = '';
  var showbtn = false;

  void homeView() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final String profileImage = currUserData.data()!['image_url'];
    final String profileName = currUserData.data()!['username'];
    final String role = currUserData.data()!['role'];

    setState(() {
      if (role == 'Employer') {
        showbtn = true;
      } else {
        showbtn = false;
      }
      homedp = profileImage;
      homename = profileName;
    });
  }

  @override
  void initState() {
    homeView();
    super.initState();
  }

  Widget buildFloatingActionButton() {
    return Visibility(
      visible: showbtn,
      child: SpeedDial(
        shape: RoundedRectangleBorder(
          // Use RoundedRectangleBorder for a rectangular shape
          borderRadius:
              BorderRadius.circular(100.0), // Adjust the radius as needed
        ),
        activeIcon: Icons.close,
        spacing: 6,
        overlayColor: Colors.black38,
        spaceBetweenChildren: 6,
        children: [
          SpeedDialChild(
            elevation: 4,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.note_add_outlined,
              size: 28,
            ),
            label: 'Add a note',
            onTap: () {},
          ),
          SpeedDialChild(
            elevation: 4,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_task_rounded,
              size: 28,
            ),
            label: 'Assign a task',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateTaskScreen()),
              );
            },
          ),
        ],
        child: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
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
                  fontSize: 17,
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
      floatingActionButton: buildFloatingActionButton(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: showbtn,
              child: Card(
                shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12)),
                surfaceTintColor: Colors.white,
                color: const Color.fromARGB(230, 255, 255, 255),
                margin: const EdgeInsets.only(
                    left: 11, right: 11, top: 11, bottom: 3),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 19, top: 8, bottom: 4),
                        child: Text(
                          'Progress Overview',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.amberAccent,
                      height: 190,
                      child: GridView(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6 / 2.86,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 10),
                        children: [
                          for (final category in availbleOverview)
                            OverViewGridItem(category: category)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            EmployerTaskList(),
          ],
        ),
      ),
    );
  }
}
