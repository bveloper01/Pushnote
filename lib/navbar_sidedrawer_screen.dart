import 'package:flutter/material.dart';
import 'package:push_drive/chat_screen.dart';
import 'package:push_drive/home_screen.dart';
import 'package:push_drive/notification_screen.dart';
import 'package:push_drive/widgets/drawer.dart';

class tabScreens extends StatefulWidget {
  const tabScreens({super.key});

  @override
  State<tabScreens> createState() => _tabScreensState();
}

class _tabScreensState extends State<tabScreens> {
  int _selectedPageIndex = 0;
  final screens = const [
    HomeScreen(),
    ChatScreen(),
    NoficationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      body: screens[_selectedPageIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(indicatorColor: Colors.blue),
        child: NavigationBar(
          surfaceTintColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 196, 219, 237),
          animationDuration: const Duration(seconds: 1, milliseconds: 300),
          selectedIndex: _selectedPageIndex,
          onDestinationSelected: (index) => setState(() {
            _selectedPageIndex = index;
          }),
          height: 65,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
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
