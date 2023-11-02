import 'package:flutter/material.dart';
import 'package:push_drive/widgets/drawer.dart';

class NoficationScreen extends StatefulWidget {
  const NoficationScreen({Key? key}) : super(key: key);

  @override
  State<NoficationScreen> createState() => _NoficationScreenState();
}

class _NoficationScreenState extends State<NoficationScreen> {
  // Dummy notification data
  final List<Map<String, String>> notifications = [
    {
      'title': 'Task status updated',
      'subtitle': 'You received a status update',
    },
    {
      'title': 'Task status updated',
      'subtitle': 'You received a status update',
    },
    {
      'title': 'Text Message',
      'subtitle': 'Text message from Workspace Nexus',
    },
    {
      'title': 'Text Message',
      'subtitle': 'Text message from Workspace Nexus',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        toolbarHeight: 68,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color.fromARGB(255, 23, 23, 23),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'No new notification',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}



//  ListView.builder(
//         itemCount: notifications.length,
//         itemBuilder: (BuildContext context, int index) {
//           final notification = notifications[index];
//           return Card(
//             shape: RoundedRectangleBorder(
//                 side: const BorderSide(color: Colors.black12),
//                 borderRadius: BorderRadius.circular(20)),
//             margin: const EdgeInsets.only(
//               top: 10,
//               left: 10,
//               right: 10,
//             ),
//             child: ListTile(
//               title: Text(
//                 notification['title'] ?? '',
//                 style:
//                     const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//               ),
//               subtitle: Text(
//                 notification['subtitle'] ?? '',
//                 style:
//                     const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
//               ),
//               trailing: const Icon(Icons.notifications_active),
//               onTap: () {
//                 // Handle tap on the notification item
//               },
//             ),
//           );
//         },
//       ),