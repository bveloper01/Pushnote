import 'package:flutter/material.dart';
import 'package:push_drive/models/overview.dart';

class ForDataOverview extends StatelessWidget {
  const ForDataOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

const employeeOverview = [
  Category(
      title: 2,
      subtitle: 'In Progress',
      color: Color.fromARGB(255, 177, 206, 252)),
  Category(
    title: 0,
    subtitle: 'Blocked',
    color: Color(0xffbF6BB54),
  ),
  Category(
      title: 5,
      subtitle: 'Completed',
      color: Color.fromARGB(210, 145, 230, 108)),
  Category(
      title: 1, subtitle: 'Overdue', color: Color.fromARGB(255, 247, 124, 124)),
];
