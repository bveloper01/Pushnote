import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/widgets/task_image_picker.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _createformKey = GlobalKey<FormState>();
  var _enteredtaskname = '';
  bool linktextfiels = false;
  var _enteredtaskdetails = '';
  var uuid = Uuid();
  String? _enteredlink;
  var isCreating = false;
  DateTime? chosenDate;
  File? _theselectedImage;
  File? _theselectedFile;
  var selmedium = 'Medium';

  String dropdownValue = 'Select';
  String dropdown = 'Select';
  List<String> allEmployees = [];
  List<String> selectedEmployees = [];
  List<String> addedMembers = [];

  void _submit() async {
    final isValid = _createformKey.currentState!.validate();

    if (!isValid || chosenDate == null || selectedEmployees.isEmpty) {
      if (chosenDate == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 1),
            content: Center(
              child: Text(
                'Please select a date',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }
      if (selectedEmployees.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 1),
            content: Center(
              child: Text(
                'Please select an employee',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }
      if (chosenDate == null && selectedEmployees.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 1),
            content: Center(
              child: Text(
                'Please select a date',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }
      return;
    }

    _createformKey.currentState!.save();
    setState(() {
      isCreating = true;
    });

    String uniqueImageName = uuid.v4();

    try {
      final imgstorageref = FirebaseStorage.instance
          .ref()
          .child('img_attachments')
          .child('$uniqueImageName.jpg');
      String? taskimgURL; // Initialize it to null

      if (_theselectedImage != null) {
        await imgstorageref.putFile(_theselectedImage!);
        taskimgURL = await imgstorageref.getDownloadURL();
      }

      final docstorageref = FirebaseStorage.instance
          .ref()
          .child('doc_attachments')
          .child('$uniqueImageName.pdf');
      String? taskdocURL; // Initialize it to null

      if (_theselectedFile != null) {
        await docstorageref.putFile(_theselectedFile!);
        taskdocURL = await docstorageref.getDownloadURL();
      }
      final devtoken = FirebaseAuth.instance.currentUser!;
      final currUsertoken = await FirebaseFirestore.instance
          .collection('users')
          .doc(devtoken.uid)
          .get();
      final usertoken = currUsertoken.data()!['deviceToken'];
      final FullName = currUsertoken.data()!['username'];
      final Role = currUsertoken.data()!['role'];

      await FirebaseFirestore.instance.collection('taskdetails').add({
        'Task name': _enteredtaskname,
        'Task details': _enteredtaskdetails,
        'due_date': chosenDate,
        if (selectedEmployees.isNotEmpty)
          'selected_employee': selectedEmployees,
        if (addedMembers.isNotEmpty) 'added_employee': addedMembers,
        if (taskimgURL != null) 'task_img': taskimgURL,
        if (linktextfiels) 'task_link': _enteredlink,
        if (taskdocURL != null) 'task_doc': taskdocURL,
        'Priority': selmedium,
        'device_token': usertoken,
        'Full Name': FullName,
        'role': Role,
      });

      setState(() {
        isCreating = false;
        Navigator.of(context).pop();
        dropdown = 'Select';
        dropdownValue = 'Select';
        _createformKey.currentState!.reset();
        chosenDate = null;
        selmedium = 'Medium';
        _theselectedImage = null;
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // to clear any existing snackbars
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blueAccent,
          duration: Duration(seconds: 1),
          content: Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      setState(() {
        isCreating = false;
      });

      // Handle the error as needed.
    }
  }

  void resetDropdownValue() {
    setState(() {
      dropdown = 'Select';
    });
  }

  void presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2055),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black), // Border color when focused
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black), // Border color when enabled
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      //adding custom date to the transactions
      if (pickedDate == null) {
        return;
      }
      setState(() {
        chosenDate = pickedDate;
      });

      // Request focus on the Title TextField
    }); //furture can also be used in http requests where you wait for response from the user
  }

  @override
  void initState() {
    super.initState();

    // Step 1: Retrieve a list of all users with the role 'Employee'
    // You need to replace 'users' with the actual Firestore collection name.
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Employee')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        allEmployees =
            querySnapshot.docs.map((doc) => doc['username'] as String).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: const Color.fromARGB(255, 226, 233, 238),
      ),
      backgroundColor: const Color.fromARGB(255, 226, 233, 238),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _createformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a new task',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Task name',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  enabled: true,
                  readOnly: false,
                  obscureText: false,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.trim().length < 2) {
                      return 'Please enter task name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredtaskname = value!;
                  },
                  autocorrect: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter your task name here ',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Task description',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  enabled: true,
                  readOnly: false,
                  obscureText: false,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        value.trim().length < 2) {
                      return 'Please enter task description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredtaskdetails = value!;
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter your task description here',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: presentDatePicker,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.fromLTRB(15, 15, 10, 15),
                          child: FittedBox(
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 33,
                                  width: 33,
                                  child: FloatingActionButton(
                                    heroTag: 'slickback',
                                    backgroundColor: const Color.fromARGB(
                                        255, 182, 215, 239),
                                    elevation: 1.9,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    foregroundColor: Colors.black,
                                    onPressed: presentDatePicker,
                                    child:
                                        const Icon(Icons.date_range_outlined),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                FittedBox(
                                  child: Text(
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      chosenDate == null
                                          ? 'Select date'
                                          : DateFormat('EEEE, dd/MM/yyyy')
                                              .format(chosenDate!)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Assigned to',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
                        child: FittedBox(
                            child: DropdownButton<String>(
                          value: dropdownValue,
                          items: [
                            'Select',
                            ...allEmployees.where(
                                (employee) => !addedMembers.contains(employee))
                          ].map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue != null && newValue != 'Select') {
                                // Remove the selected value from allEmployees and add it to selectedEmployees
                                selectedEmployees.clear();
                                dropdownValue = newValue;
                                selectedEmployees.add(newValue);
                              }
                            });
                          },
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    ChoiceChip(
                      showCheckmark: false,
                      label: const Text('High',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      selected: selmedium == 'High',
                      selectedColor: const Color.fromARGB(255, 248, 126, 126),
                      onSelected: (value) {
                        setState(() {
                          selmedium = 'High';
                        });
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ChoiceChip(
                      showCheckmark: false,
                      label: const Text('Medium',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      selected: selmedium == 'Medium',
                      selectedColor: const Color.fromARGB(255, 255, 221, 83),
                      onSelected: (value) {
                        setState(() {
                          selmedium = 'Medium';
                        });
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ChoiceChip(
                      showCheckmark: false,
                      label: const Text('Low',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      selected: selmedium == 'Low',
                      selectedColor: const Color.fromARGB(210, 140, 225, 104),
                      onSelected: (value) {
                        setState(() {
                          selmedium = 'Low';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Add members',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
                        child: Column(
                          children: [
                            DropdownButton<String>(
                                value: dropdown,
                                items: [
                                  'Select',
                                  ...allEmployees.where((employee) =>
                                      !selectedEmployees.contains(employee))
                                ].map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? addValue) {
                                  setState(() {
                                    if (addValue != null &&
                                        addValue != 'Select' &&
                                        !selectedEmployees.contains(addValue) &&
                                        !addedMembers.contains(addValue)) {
                                      // Remove the selected value from allEmployees and add it to selectedEmployees
                                      dropdown = addValue;
                                      addedMembers.add(addValue);
                                    }
                                  });
                                }),
                            SingleChildScrollView(
                              reverse: true,
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: addedMembers
                                    .map((value) => Chip(
                                          backgroundColor: const Color.fromARGB(
                                              255, 226, 236, 243),
                                          label: Text(value),
                                          onDeleted: () {
                                            setState(() {
                                              addedMembers.remove(value);
                                              resetDropdownValue();
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'Add an attachment',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    TaskImagePicker(
                      onPickedImage: ((pickedImage) {
                        _theselectedImage = pickedImage;
                      }),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      height: 33,
                      width: 33,
                      child: FloatingActionButton(
                        heroTag: 'nonono',
                        backgroundColor:
                            const Color.fromARGB(255, 182, 215, 239),
                        elevation: 1.9,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                        onPressed: () async {
                          final path =
                              await FlutterDocumentPicker.openDocument();
                          print(path);
                          _theselectedFile = File(path!);
                          //firebase_storage.UploadTask task = await uploadFile(file);
                        },
                        child: const Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      height: 33,
                      width: 33,
                      child: FloatingActionButton(
                        heroTag: 'even',
                        backgroundColor:
                            const Color.fromARGB(255, 182, 215, 239),
                        elevation: 1.9,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                        onPressed: () {
                          setState(() {
                            linktextfiels = !linktextfiels;
                          });
                        },
                        child: const Icon(Icons.link_outlined),
                      ),
                    ),
                  ],
                ),
                if (linktextfiels)
                  const SizedBox(
                    height: 15,
                  ),
                if (linktextfiels)
                  TextFormField(
                    enabled: true,
                    readOnly: false,
                    obscureText: false,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.trim().length < 3) {
                        return 'Please enter a valid link';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredlink = value!;
                    },
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'Enter your link here',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      contentPadding:
                          const EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                    ),
                  ),

                const SizedBox(
                  height: 35,
                ),
                if (isCreating)
                  const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                if (!isCreating)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      onPressed: _submit,
                      child: const SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Create task',
                            style:
                                TextStyle(fontSize: 16.5, color: Colors.white),
                          ),
                        ),
                      )),

                // Step 2.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
