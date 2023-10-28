import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_drive/widgets/chat_messages.dart';
import 'package:push_drive/widgets/new_messages.dart';

class GlobalChatScreen extends StatefulWidget {
  const GlobalChatScreen({
    super.key,
  });

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  void setUpPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
 
    fcm.subscribeToTopic('Chat');
  }

  @override
  void initState() {
    // init state does not return a future
    super.initState();

    setUpPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        toolbarHeight: 68,
        title: const Row(
          children: [
            Expanded(
              child: Text(
                'Workspace Nexus',
                style: TextStyle(
                    color: Color.fromARGB(255, 23, 23, 23),
                    fontSize: 21,
                    fontWeight: FontWeight.w600),
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              foregroundImage: AssetImage(
                'images/workspace.png',
              ),
            )
          ],
        ),
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 239, 236, 226),
    );
  }
}






// Center(
//                     child: Text(
//                       displayName,
//                       style: TextStyle(
//                           color: coloriing
//                               ? const Color.fromARGB(255, 23, 23, 23)
//                               : Colors.black87,
//                           fontSize: 22,
//                           fontWeight: FontWeight.w600),
//                     ),
//                   ),