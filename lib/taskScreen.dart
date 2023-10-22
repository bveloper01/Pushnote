import 'package:flutter/material.dart';
import 'package:push_drive/widgets/drawer.dart';

class AllTasks extends StatefulWidget {
  const AllTasks({super.key});

  @override
  State<AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ],
        ),
      ),
      body: Center(child: Text('Task')),
      backgroundColor: Colors.white,
    );
  }
}
