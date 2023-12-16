import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:push_drive/create_task_screen.dart';
import 'package:push_drive/profile_screen.dart';
import 'package:push_drive/widgets/drawer.dart';
import 'package:push_drive/widgets/task_list.dart';

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
  int highPriorityCount = 0;
  int mediumPriorityCount = 0;
  int lowPriorityCount = 0;
  int overduePriorityCount = 0;
  int inProgresCount = 0;
  int blockedCount = 0;
  int completedCount = 0;
  int overdueerCount = 0;

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

  void fetchPriorityCounts() async {
    // Fetch documents from 'taskdetails' collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('taskdetails').get();

    // Reset priority counts
    highPriorityCount = 0;
    mediumPriorityCount = 0;
    lowPriorityCount = 0;
    overduePriorityCount = 0;

    // Iterate through documents and count priorities
    querySnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Check the priority field and update the corresponding count
      String priority = data['Priority'];
      switch (priority) {
        case 'High':
          highPriorityCount++;
          break;
        case 'Medium':
          mediumPriorityCount++;
          break;
        case 'Low':
          lowPriorityCount++;
          break;
        case 'Overdue':
          overduePriorityCount++;
          break;
        default:
          break;
      }
    });

    // Update the state to trigger a rebuild with the updated counts
    setState(() {});

    QuerySnapshot querytwoSnapshot =
        await FirebaseFirestore.instance.collection('taskstatus').get();

    // Reset priority counts
    inProgresCount = 0;
    blockedCount = 0;
    completedCount = 0;
    overdueerCount = 0;

    // Iterate through documents and count priorities
    querytwoSnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Check the priority field and update the corresponding count
      String current_status = data['current_status'];
      switch (current_status) {
        case 'In Progress':
          inProgresCount++;
          break;
        case 'Blocked':
          blockedCount++;
          break;
        case 'Completed':
          completedCount++;
          break;
        case 'Overdue':
          overdueerCount++;
          break;
        default:
          break;
      }
    });

    // Update the state to trigger a rebuild with the updated counts
    setState(() {});
  }

  @override
  void initState() {
    homeView();
    fetchPriorityCounts();
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
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color:const Color.fromARGB(255, 177, 206, 252),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inProgresCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'In Progress',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color.fromARGB(250, 245, 188, 91),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blockedCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Blocked',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Color.fromARGB(210, 145, 230, 108),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  completedCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Completed',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Color.fromARGB(255, 241, 111, 111),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  overdueerCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Overdue',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !showbtn,
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
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color.fromARGB(255, 247, 124, 124),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  highPriorityCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'High',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color.fromARGB(250, 245, 188, 91),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediumPriorityCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Medium',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Color.fromARGB(210, 145, 230, 108),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lowPriorityCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Low',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Color.fromARGB(255, 241, 111, 111),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  overduePriorityCount.toString(),
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Overdue',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 23, 23, 23),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const EmployerTaskList(),
          ],
        ),
      ),
    );
  }
}
