import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  String rep = '';
  String dropdownValue = 'Select';
  String dropdown = 'Select';
  String? selectedEmployeeImageUrl;
  List<Map<String, dynamic>> allEmployees = [];
  List<String> selectedEmployees = [];
  List<String> addedMembers = [];

  void gemini_test() async {
    await dotenv.load(fileName: '.env');
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null) {
      print('API_KEY environment variable is not set.');
      exit(1);
    }
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [Content.text("How far is Andromeda Galaxy from Milky")];
    final response = await model.generateContent(content);
    setState(() {
      rep = response.text!;
    });
  }

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
      final fullName = currUsertoken.data()!['username'];
      await FirebaseFirestore.instance.collection('taskdetails').add({
        'Task name': _enteredtaskname,
        'Task details': _enteredtaskdetails,
        'due_date': chosenDate,
        if (selectedEmployees.isNotEmpty)
          'selected_employee': selectedEmployees,
        if (selectedEmployees.isNotEmpty)
          'selected_employee_imageUrl': selectedEmployeeImageUrl,
        if (addedMembers.isNotEmpty) 'added_employee': addedMembers,
        if (taskimgURL != null) 'task_img': taskimgURL,
        if (linktextfiels) 'task_link': _enteredlink,
        if (taskdocURL != null) 'task_doc': taskdocURL,
        'Priority': selmedium,
        'device_token': usertoken,
        'Assigned by': fullName,
      });
      setState(() {
        isCreating = false;
        Navigator.of(context).pop();
        selectedEmployees.clear();
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
    }
  }

  void resetDropdown() {
    setState(() {
      dropdown = 'Select';
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Employee')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      // Extract the document data and convert to List<Map<String, dynamic>>
      List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
        return {
          'username': doc['username'] as String,
          'imageUrl': doc['image_url'] as String,
        };
      }).toList();
      // Sort the users list alphabetically based on 'username'
      users.sort((a, b) =>
          (a['username'] as String).compareTo(b['username'] as String));
      return users; // Return the sorted list of users
    });
  }

  void presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
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
    }); //furture can also be used in http requests where you wait for response from the user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 24),
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
                        const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 24),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Container(
                                  height: 33,
                                  width: 33,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 182, 215, 239),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Icon(Icons.date_range_outlined),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Assigned to',
                      style: TextStyle(
                        color: Color.fromARGB(255, 23, 23, 23),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FittedBox(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getUsersStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final List<Map<String, dynamic>> allEmployees =
                              snapshot.data ?? [];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: 'Select',
                                  child: Text('Select',
                                      style: TextStyle(fontSize: 18)),
                                ),
                                for (var employee in allEmployees)
                                  if (!addedMembers
                                      .contains(employee['username']))
                                    DropdownMenuItem<String>(
                                      value: employee['username']
                                          .toString(), // Assuming username is a string
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.white,
                                            foregroundImage: NetworkImage(
                                                employee['imageUrl']),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            employee['username']
                                                .toString(), // Assuming username is a string
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue != null &&
                                      newValue != 'Select' &&
                                      !addedMembers.contains(newValue)) {
                                    var selectedEmployee =
                                        allEmployees.firstWhere(
                                      (employee) =>
                                          employee['username'] == newValue,
                                    );
                                    if (selectedEmployee.isNotEmpty) {
                                      selectedEmployeeImageUrl =
                                          selectedEmployee[
                                              'imageUrl']; // Add imageUrl here
                                      selectedEmployees.clear();
                                      dropdownValue = newValue;
                                      selectedEmployees.add(newValue);
                                    }
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                // Container(
                //   padding: const EdgeInsets.only(top: 5, bottom: 5),
                //   child: InkWell(
                //     onTap: () {},
                //     child: Text("Your answer: $rep"),
                //   ),
                // ),

                const SizedBox(   
                  height: 10,
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
                    StreamBuilder<List<Map<String, dynamic>>>(
                        stream: getUsersStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          final List<Map<String, dynamic>> allEmployees =
                              snapshot.data ?? [];
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DropdownButton<String>(
                                    value: dropdown,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: 'Select',
                                        child: Text('Select',
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      for (var employee in allEmployees)
                                        if (!selectedEmployees
                                            .contains(employee['username']))
                                          DropdownMenuItem<String>(
                                            value: employee['username']
                                                .toString(), // Assuming username is a string
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.white,
                                                  foregroundImage: NetworkImage(
                                                      employee['imageUrl']),
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  employee['username']
                                                      .toString(), // Assuming username is a string
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                    onChanged: (String? addValue) {
                                      setState(() {
                                        if (addValue != null &&
                                            addValue != 'Select' &&
                                            !selectedEmployees
                                                .contains(addValue) &&
                                            !addedMembers.contains(addValue)) {
                                          // Remove the selected value from allEmployees and add it to selectedEmployees
                                          dropdown = addValue;
                                          addedMembers.add(addValue);
                                        }
                                      });
                                    },
                                  ),
                                  SingleChildScrollView(
                                    reverse: true,
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: addedMembers
                                          .map((value) => Chip(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 226, 236, 243),
                                                label: Text(value),
                                                onDeleted: () {
                                                  setState(() {
                                                    addedMembers.remove(value);
                                                    resetDropdown();
                                                  });
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
                const SizedBox(
                  height: 18,
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
                          _theselectedFile = File(path!);
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
                          const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 24),
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
