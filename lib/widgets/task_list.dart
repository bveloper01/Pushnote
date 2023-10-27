import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:push_drive/task_detail_screen.dart';

class EmployerTaskList extends StatefulWidget {
  const EmployerTaskList({super.key});

  @override
  State<EmployerTaskList> createState() => _EmployerTaskListState();
}

class _EmployerTaskListState extends State<EmployerTaskList> {
  @override
  Widget build(BuildContext context) {
    Color pcolor = Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Colors.white,
      color: const Color.fromARGB(230, 255, 255, 255),
      margin: const EdgeInsets.all(11),
      child: Container(
        height: MediaQuery.of(context).size.height - 437,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('taskdetails')
              .orderBy(
                'due_date',
                descending: false,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Display an image when there's no data
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 40),
                      child: Image(
                        image: AssetImage("images/notask.png"),
                        width: 180.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8,
                        bottom: 60,
                      ),
                      child: Text('Tasks have not been assigned yet',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    )
                  ],
                ), // Replace with your image path
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 2.5,
              ));
            }

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 70),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var task = snapshot.data!.docs[index];
                Map<String, dynamic>? data =
                    task.data() as Map<String, dynamic>?;

                bool hasImage = data != null && data.containsKey('task_img');

                bool haslink = data != null && data.containsKey('task_link');
                bool hasdoc = data != null && data.containsKey('task_doc');
                String taskName = task['Task name'];
                String taskDetails = task['Task details'];
                String priority = task['Priority'];
                DateTime dueDate = (task['due_date'] as Timestamp).toDate();
                String formattedDueDate = DateFormat.yMMMd().format(dueDate);

                if (priority == 'High') {
                  pcolor = const Color.fromARGB(255, 248, 126, 126);
                } else if (priority == 'Medium') {
                  pcolor = const Color.fromARGB(255, 255, 221, 83);
                } else {
                  pcolor = const Color.fromARGB(210, 140, 225, 104);
                }

                return Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: ListTile(
                    onTap: () {
                      // When the ListTile is tapped, navigate to the TaskDetailsPage
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsPage(
                            taskName: taskName,
                            taskDetails: taskDetails,
                            taskdate: dueDate,
                            taskpriority: priority,
                            taskImg: hasImage ? task['task_img'] : '',
                            tasklink: haslink ? task['task_link'] : '',
                            taskdoc: hasdoc ? task['task_doc'] : '',

                            // Pass the task details to the details page
                          ),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.only(
                        top: 3, left: 16, bottom: 3, right: 16),
                    title: Text(
                      taskName,
                      style: const TextStyle(fontSize: 17),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 9,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: pcolor,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(4),
                          child: Text('$priority'),
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 22,
                            ),
                            Expanded(
                                child: Container(
                                    child: Text(' $formattedDueDate'))),
                            if (hasImage) const Icon(Icons.image_outlined),
                            if (haslink)
                              const SizedBox(
                                width: 5,
                              ),
                            if (haslink) const Icon(Icons.link),
                            if (hasdoc)
                              const SizedBox(
                                width: 5,
                              ),
                            if (hasdoc) const Icon(Icons.description_outlined),
                          ],
                        ),

                        // Format due date as needed
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
