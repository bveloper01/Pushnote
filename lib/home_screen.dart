import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:push_drive/ai_chatbot_screen.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:push_drive/create_task_screen.dart';
import 'package:push_drive/profile_screen.dart';
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
  double height = AppBar().preferredSize.height;
  bool _isTextVisible = false;
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

  void _toggleTextVisibility() {
    setState(() {
      _isTextVisible = !_isTextVisible;
    });
  }

  final GlobalKey<ExpandableFabState> fabKey = GlobalKey<ExpandableFabState>();
  Widget buildFloatingActionButton() {
    return Visibility(
      visible: showbtn,
      child: ExpandableFab(
        key: fabKey,
        fanAngle: 40,
        distance: 60.0,
        type: ExpandableFabType.up,
        duration: const Duration(milliseconds: 300),
        childrenOffset: const Offset(9, 8),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(
            Icons.create,
          ),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          angle: 3.14 * 2,
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return IconButton(
              onPressed: onPressed,
              icon: const Icon(
                Icons.cancel,
                size: 50,
              ),
            );
          },
        ),
        overlayStyle: ExpandableFabOverlayStyle(
          // color: Colors.black.withOpacity(0.5),
          blur: 12,
        ),
        children: [
          FloatingActionButton.small(
            shape: const CircleBorder(),
            heroTag: null,
            child: const Icon(Icons.videocam),
            onPressed: () {
              _toggleTextVisibility();
              fabKey.currentState?.toggle();
            },
          ),
          FloatingActionButton.small(
            shape: const CircleBorder(),
            heroTag: null,
            child: const Icon(Icons.add_task_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateTaskScreen()),
              );
              fabKey.currentState?.toggle();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: buildFloatingActionButton(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Row(
                  children: [
                    homedp == null
                        ? const CircleAvatar(
                            radius: 27,
                            backgroundColor: Color.fromARGB(255, 223, 249, 250),
                            foregroundImage: AssetImage(
                              'assets/avatar.png',
                            ),
                          )
                        : CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.white,
                            foregroundImage: NetworkImage(homedp),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            homename,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AIChatbotScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.star,
                          size: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 12, top: 15, left: 5),
                      child: PopupMenuButton<int>(
                        constraints:
                            const BoxConstraints.expand(width: 150, height: 60),
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        offset: Offset(-8, height - 20),
                        onSelected: (value) {},
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                          PopupMenuItem<int>(
                            value: 1,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()),
                              );
                            },
                            child: const Text(
                              'Settings',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 60,
                margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: const Color.fromARGB(255, 177, 206, 252),
                ),
                child: Center(
                  child: Text(
                      style: const TextStyle(
                          fontSize: 21,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                      DateFormat('EEEE, dd/MM/yyyy').format(DateTime.now())),
                ),
              ),
              Visibility(
                visible: _isTextVisible,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 400,
                      child: Card(
                        color: const Color.fromARGB(255, 249, 243, 126),
                        surfaceTintColor: Colors.white,
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color.fromARGB(31, 0, 0, 0)),
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.only(
                          top: 8,
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 10, top: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                    color: Colors.black, //
                                    width: 1.0,
                                  ),
                                ),
                                child: const Text(
                                  'Google Meet Link',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(
                                      'https://meet.google.com/hds-mbcp-vzv'));
                                },
                                child: const Text(
                                  'https://meet.google.com/hds-mbcp-vzv',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                          onPressed: _toggleTextVisibility,
                          icon: const Icon(
                            Icons.cancel,
                            size: 26,
                          )),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showbtn,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 18, top: 15, bottom: 6),
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
                      // color: const Color.fromARGB(255, 224, 210, 170),
                      height: 185,
                      child: GridView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6 / 2.8,
                                crossAxisSpacing: 9,
                                mainAxisSpacing: 10),
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 8, left: 15, right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color.fromARGB(255, 177, 206, 252),
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
                              color: const Color.fromARGB(255, 255, 221, 83),
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
                              color: const Color.fromARGB(210, 145, 230, 108),
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
                              color: const Color.fromARGB(255, 241, 111, 111),
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
              Visibility(
                visible: !showbtn,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 18, top: 15, bottom: 7),
                        child: Text(
                          'Task Overview',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.amberAccent,
                      height: 185,
                      child: GridView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6 / 2.8,
                                crossAxisSpacing: 9,
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
                              color: const Color.fromARGB(255, 255, 221, 83),
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
                              color: const Color.fromARGB(255, 241, 111, 111),
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
              const EmployerTaskList(),
            ],
          ),
        ),
      ),
    );
  }
}
