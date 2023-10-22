import 'package:flutter/material.dart';
import 'package:push_drive/SplashScreen.dart';
import 'package:push_drive/chatScreen.dart';
import 'package:push_drive/taskScreen.dart';
import 'package:push_drive/widgets/drawer.dart';

class tabScreens extends StatefulWidget {
  const tabScreens({super.key});

  @override
  State<tabScreens> createState() => _tabScreensState();
}

class _tabScreensState extends State<tabScreens> {
  int _selectedPageIndex = 0;
  final screens = const [
    AllTasks(),
    SplashScreen(),
    ChatScreen(),
    AllTasks(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      body: screens[_selectedPageIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(indicatorColor: Colors.blue),
        child: NavigationBar(
          animationDuration: const Duration(seconds: 1, milliseconds: 300),
          selectedIndex: _selectedPageIndex,
          onDestinationSelected: (index) => setState(() {
            _selectedPageIndex = index;
          }),
          height: 65,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.add_task), label: 'Tasks'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            NavigationDestination(
                icon: Icon(Icons.notifications_active_rounded),
                label: 'Notification'),
          ],
        ),
      ),
    );
  }
}
