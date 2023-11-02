import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskName;
  final String taskDetails;
  final DateTime taskdate;
  final String taskpriority;
  final String taskImg;
  final String tasklink;
  final String taskdoc;

  TaskDetailsPage(
      {required this.taskName,
      required this.taskDetails,
      required this.taskdate,
      required this.taskpriority,
      required this.taskImg,
      required this.tasklink,
      required this.taskdoc});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  var statusrole = true;
  final statusformKey = GlobalKey<FormState>();

  bool isupdating = false;
  String _enteredstatus = '';

  var newday = 'Not started';
  var mystatus = 'To do';

  void skillBasedMatching() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final role = currUserData.data()!['role'];

    setState(() {
      if (role == 'Employee') {
        statusrole = true;
      } else {
        statusrole = false;
      }
    });
}

  @override
  void initState() {
    skillBasedMatching();
    super.initState();
    loadSelectedStatus(widget.taskName);
    loadmyStatus(
        widget.taskName); // Load the saved status when the page is initialized
  }

  // Load the selected status from shared preferences

  Future<void> loadSelectedStatus(String taskName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      newday = prefs.getString('status_$taskName') ?? 'Not started';
    });
  }

  // Save the selected status to shared preferences
  Future<void> saveSelectedStatus(String taskName, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status_$taskName', status);
  }

  Future<void> loadmyStatus(String taskName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mystatus = prefs.getString('mstatus_$taskName') ?? 'To do';
    });
  }

  Future<void> savemyStatus(String taskName, String mstatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mstatus_$taskName', mstatus);
  }

  // Handle the submit button press
  void handleSubmit() async {
    final isValid = statusformKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    statusformKey.currentState!.save();
    setState(() {
      isupdating = true;
    });
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final role = currUserData.data()!['role'];
    final whoUpdated = currUserData.data()!['username'];

    try {
      print('the status is here $_enteredstatus');

      final theDevicetoken = FirebaseMessaging.instance;
      await theDevicetoken.requestPermission();

      final updatingDevicetoken = await theDevicetoken.getToken();

      await FirebaseFirestore.instance.collection('taskstatus').add({
        'Tname': widget.taskName,
        'Tname status': _enteredstatus,
        'when updated': DateTime.now(),
        'Tdue_date': widget.taskdate,
        'who updated': whoUpdated,
        'role': role,
        'updatingDeviceToken': updatingDevicetoken,
        'TPriority': widget.taskpriority,
        'current_status': newday,
        'my status': mystatus,
      });

      setState(() {
        isupdating = false;
        Navigator.of(context).pop();
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
        isupdating = false;
      });
      // Handle the error as needed.
    }

    saveSelectedStatus(widget.taskName, newday);
    savemyStatus(widget.taskName, mystatus);
    setState(() {
      statusformKey.currentState!.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDueDate = DateFormat.yMMMMEEEEd().format(widget.taskdate);
    Color saiyan = Colors.grey;
    Color saiyans = Colors.grey;

    Uri? docuri = Uri.parse(widget.taskdoc);
    Uri? uri = Uri.parse(widget.tasklink);
    bool _isimgthere = false;

    if (this.widget.taskImg != '') {
      _isimgthere = true;
    }
    bool _islinkthere = false;
    if (this.widget.tasklink != '') {
      _islinkthere = true;
    }

    bool _isdocthere = false;
    if (this.widget.taskdoc != '') {
      _isdocthere = true;
    }

    if (widget.taskpriority == 'High') {
      saiyan = const Color.fromARGB(255, 248, 126, 126);
    } else if (widget.taskpriority == 'Medium') {
      saiyan = const Color.fromARGB(255, 255, 221, 83);
    } else {
      saiyan = const Color.fromARGB(210, 140, 225, 104);
    }

    if (newday == 'Not started') {
      saiyans = Colors.grey;
    } else if (newday == 'In Progress') {
      saiyans = const Color.fromARGB(255, 177, 206, 252);
    } else if (newday == 'Blocked') {
      saiyans = const Color.fromARGB(255, 255, 221, 83);
    } else {
      saiyans = const Color.fromARGB(210, 140, 225, 104);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 233, 238),
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: const Color.fromARGB(255, 226, 233, 238),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Task Details',
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
            Container(
              padding: const EdgeInsets.only(
                  left: 15, top: 18, bottom: 18, right: 15),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.taskName,
                style: const TextStyle(
                    color: Color.fromARGB(255, 23, 23, 23),
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
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
            Container(
              padding: const EdgeInsets.only(
                  left: 15, top: 18, bottom: 18, right: 15),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.taskDetails,
                style: const TextStyle(
                    color: Color.fromARGB(255, 23, 23, 23),
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text(
                  'Due date',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 15, top: 18, bottom: 18, right: 15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      formattedDueDate,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
                    padding: const EdgeInsets.only(
                        left: 15, top: 18, bottom: 18, right: 15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Shivansh Gupta',
                      style: TextStyle(
                          color: Color.fromARGB(255, 23, 23, 23),
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Priority',
                  style: TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 30),
                Container(
                  decoration: BoxDecoration(
                      color: saiyan, borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(7),
                  child: Text(
                    widget.taskpriority,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 23, 23, 23),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (!statusrole) const SizedBox(height: 20),
            if (!statusrole)
              Row(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                        color: Color.fromARGB(255, 23, 23, 23),
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 30),
                  Container(
                    decoration: BoxDecoration(
                        color: saiyans, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(7),
                    child: Text(
                      newday,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 23, 23, 23),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            if (statusrole)
              const SizedBox(
                height: 2,
              ),
            if (statusrole)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Status',
                    style: TextStyle(
                        color: Color.fromARGB(255, 23, 23, 23),
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    child: Row(
                      children: [
                        ChoiceChip(
                          showCheckmark: false,
                          label: const Text('Not started',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          selected: newday == 'Not started',
                          selectedColor: Colors.grey,
                          onSelected: (value) {
                            setState(() {
                              newday = 'Not started';
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          showCheckmark: false,
                          label: const Text('In Progress',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          selected: newday == 'In Progress',
                          selectedColor:
                              const Color.fromARGB(255, 177, 206, 252),
                          onSelected: (value) {
                            setState(() {
                              newday = 'In Progress';
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          showCheckmark: false,
                          label: const Text('Blocked',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          selected: newday == 'Blocked',
                          selectedColor:
                              const Color.fromARGB(255, 255, 221, 83),
                          onSelected: (value) {
                            setState(() {
                              newday = 'Blocked';
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          showCheckmark: false,
                          label: const Text('Completed',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          selected: newday == 'Completed',
                          selectedColor:
                              const Color.fromARGB(210, 140, 225, 104),
                          onSelected: (value) {
                            setState(() {
                              newday = 'Completed';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Your status',
                        style: TextStyle(
                            color: Color.fromARGB(255, 23, 23, 23),
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 30),
                      ChoiceChip(
                        showCheckmark: false,
                        label: const Text('To do',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: mystatus == 'To do',
                        selectedColor: const Color.fromARGB(255, 186, 185, 251),
                        onSelected: (value) {
                          setState(() {
                            mystatus = 'To do';
                          });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ChoiceChip(
                        showCheckmark: false,
                        label: const Text('Doing',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: mystatus == 'Doing',
                        selectedColor: const Color.fromARGB(255, 150, 236, 246),
                        onSelected: (value) {
                          setState(() {
                            mystatus = 'Doing';
                          });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ChoiceChip(
                        showCheckmark: false,
                        label: const Text('Done',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: mystatus == 'Done',
                        selectedColor: const Color.fromARGB(210, 140, 225, 104),
                        onSelected: (value) {
                          setState(() {
                            mystatus = 'Done';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Task update',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  Form(
                    key: statusformKey,
                    child: TextFormField(
                      enabled: true,
                      readOnly: false,
                      obscureText: false,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            value.trim().length < 4) {
                          return 'Enter at least 4 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredstatus = value!;
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Enter status here',
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
                  ),
                ],
              ),
            if (_isimgthere || _islinkthere || _isdocthere)
              const SizedBox(height: 18),
            if (_isimgthere || _islinkthere || _isdocthere)
              Row(
                children: [
                  const Text(
                    'Attachment',
                    style: TextStyle(
                        color: Color.fromARGB(255, 23, 23, 23),
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 30),
                  if (_isimgthere)
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: FloatingActionButton(
                        heroTag: 'nonono',
                        backgroundColor:
                            const Color.fromARGB(255, 182, 215, 239),
                        elevation: 1.9,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Scaffold(
                                  backgroundColor: Colors.white,
                                  appBar: AppBar(
                                    backgroundColor: Colors.white,
                                    toolbarHeight: 48,
                                  ),
                                  body: PhotoView(
                                    backgroundDecoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    imageProvider: CachedNetworkImageProvider(
                                        widget.taskImg),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: const Icon(Icons.image),
                      ),
                    ),
                  if (_isimgthere)
                    const SizedBox(
                      width: 15,
                    ),
                  if (_islinkthere)
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: FloatingActionButton(
                        heroTag: 'walkaway',
                        backgroundColor:
                            const Color.fromARGB(255, 182, 215, 239),
                        elevation: 1.9,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                        onPressed: () async {
                          if (!await launchUrl(uri)) {
                            throw Exception('Could not launch $uri');
                          }
                        },
                        child: const Icon(Icons.link),
                      ),
                    ),
                  if (_islinkthere)
                    const SizedBox(
                      width: 15,
                    ),
                  if (_isdocthere)
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: FloatingActionButton(
                        heroTag: 'wartime',
                        backgroundColor:
                            const Color.fromARGB(255, 182, 215, 239),
                        elevation: 1.9,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                        onPressed: () async {
                          if (!await launchUrl(docuri,
                              mode: LaunchMode.inAppBrowserView)) {
                            throw Exception('Could not launch $docuri');
                          }
                        },
                        child: const Icon(Icons.description_outlined),
                      ),
                    ),
                ],
              ),
            if (!isupdating)
              const SizedBox(
                height: 10,
              ),
            if (isupdating)
              const SizedBox(
                height: 32,
              ),
            if (isupdating)
              const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            if (statusrole)
              const SizedBox(
                height: 15,
              ),
            if (!isupdating && statusrole)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                  onPressed: handleSubmit,
                  child: const SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Update status',
                        style: TextStyle(fontSize: 16.5, color: Colors.white),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
