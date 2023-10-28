import 'package:flutter/material.dart';

class Category {
  const Category({required this.title, required this.subtitle, this.color = Colors.green });
  final int title;
  final String subtitle;

  final Color color;
}
