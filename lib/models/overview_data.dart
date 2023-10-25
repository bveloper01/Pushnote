import 'package:flutter/material.dart';
import 'package:push_drive/models/overview.dart';

const availbleOverview = [
  Category(title: 'In Progress', color: Color.fromARGB(255, 177, 206, 252)),
  Category(
    title: 'Blocked',
    color: Color(0xffbF6BB54),
  ),
  Category(title: 'Completed', color: Color.fromARGB(210, 145, 230, 108)),
  Category(title: 'Overdue', color: Color.fromARGB(255, 247, 124, 124)),
];
