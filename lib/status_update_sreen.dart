import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        title: Text('Task Status List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('taskstatus').snapshots(),
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
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task Name: ${item['Tname']}'),
                      Text('Current Status: ${item['current_status']}'),
                    ],
                  ),
                  subtitle: Text('Due Date: ${item['Tdue_date']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
