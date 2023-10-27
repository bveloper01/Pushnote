import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TaskImagePicker extends StatefulWidget {
  const TaskImagePicker({super.key, required this.onPickedImage});
  final void Function(File pickedImage) onPickedImage;

  @override
  State<TaskImagePicker> createState() => _TaskImagePickerState();
}

class _TaskImagePickerState extends State<TaskImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      width: 33,
      child: FloatingActionButton(
        heroTag: 'sslick',
        backgroundColor: const Color.fromARGB(255, 182, 215, 239),
        elevation: 1.9,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: Colors.black,
        onPressed: () {
          _pickImage();
        },
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
