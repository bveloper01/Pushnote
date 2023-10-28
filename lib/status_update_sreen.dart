import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskStatusListPage extends StatefulWidget {
  @override
  State<TaskStatusListPage> createState() => _TaskStatusListPageState();
}

class _TaskStatusListPageState extends State<TaskStatusListPage> {
  @override
  Widget build(BuildContext context) {
    Color sign = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Task updates',
          style: TextStyle(
              color: Color.fromARGB(255, 23, 23, 23),
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('taskstatus')
            .orderBy('when updated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No data available');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final item = snapshot.data!.docs[index];
                DateTime duedate = (item['Tdue_date'] as Timestamp).toDate();
                String formattedDueDate = DateFormat.yMMMd().format(duedate);

                return Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black12),
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
                        Text('Task Name: ${item['Tname']}'),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Current Status: ${item['current_status']}'),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    subtitle: Text('Due Date: $formattedDueDate'),
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Who Updated: ${item['who updated']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Role:  ${item['role']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Task Status: ${item['Tname status']} ',
                              style: const TextStyle(fontSize: 14),
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
