import 'package:flutter/material.dart';
import 'package:push_drive/models/overview.dart';

class OverViewGridItem extends StatelessWidget {
  const OverViewGridItem({super.key, required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: category.color, borderRadius: BorderRadius.circular(20)),
        child: Text(category.title),
      ),
    );
  }
}
