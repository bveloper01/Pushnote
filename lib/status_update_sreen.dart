import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:push_drive/profile_screen.dart';

class TaskStatusListPage extends StatefulWidget {
  @override
  State<TaskStatusListPage> createState() => _TaskStatusListPageState();
}

class _TaskStatusListPageState extends State<TaskStatusListPage> {
  double height = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.blue,
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                ' Task Updates',
                style: TextStyle(
                    color: Color.fromARGB(255, 23, 23, 23),
                    fontSize: 21,
                    fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuButton<int>(
              constraints: const BoxConstraints.expand(width: 150, height: 60),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              offset: Offset(0, height - 15),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
                size: 23,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('taskstatus')
            .orderBy('when updated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              'No data available',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final item = snapshot.data!.docs[index];
                DateTime duedate = (item['Tdue_date'] as Timestamp).toDate();
                String formattedDueDate = DateFormat.yMMMd().format(duedate);

                return Card(
                  surfaceTintColor: Colors.white,
                  color: const Color.fromARGB(255, 230, 239, 247),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Color.fromARGB(31, 111, 111, 111)),
                      borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.only(
                        top: 5, left: 16, bottom: 5, right: 16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Name: ${item['Tname']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Current Status: ${item['current_status']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Status updated by: ${item['who updated']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Due Date: $formattedDueDate',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role: ${item['role']}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Task Status: ${item['Tname status']} ',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
