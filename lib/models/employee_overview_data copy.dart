import 'package:flutter/material.dart';
import 'package:push_drive/models/overview.dart';

class ForDataOverview extends StatelessWidget {
  const ForDataOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

const employerOverview = [
  Category(
      title: 1, subtitle: 'High', color: Color.fromARGB(255, 247, 124, 124)),
  Category(
    title: 1,
    subtitle: 'Medium',
    color: Color(0xffbF6BB54),
  ),
  Category(
      title: 3, subtitle: 'Low', color: Color.fromARGB(210, 145, 230, 108)),
  Category(
      title: 1,
      subtitle: 'Overdue',
      color: Color.fromARGB(255, 247, 124, 124)),
];
