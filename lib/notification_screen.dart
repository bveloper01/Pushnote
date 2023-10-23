import 'package:flutter/material.dart';
import 'package:push_drive/widgets/drawer.dart';

class NoficationScreen extends StatefulWidget {
  const NoficationScreen({super.key});

  @override
  State<NoficationScreen> createState() => _NoficationScreenState();
}

class _NoficationScreenState extends State<NoficationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 196, 219, 237),
          toolbarHeight: 68,
          centerTitle: true,
          title: const Text(
            'Notificatons',
            style: TextStyle(
                color: Color.fromARGB(255, 23, 23, 23),
                fontSize: 22,
                fontWeight: FontWeight.w600),
          )),
      backgroundColor: Colors.white,
      
    );
  }
}
