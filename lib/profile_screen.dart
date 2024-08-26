import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _bugformKey = GlobalKey<FormState>();
  bool isreporting = false;
  String enteredbugname = '';
  String enteredbugdetail = '';
  String dName = '';
  var rolecolor = true;
  var designation = '';
  var diss;
  void load() async {
    final forUserName = FirebaseAuth.instance.currentUser!;

    final currUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(forUserName.uid)
        .get();
    final userName = currUserData.data()!['username'];
    final role = currUserData.data()!['role'];
    final String profileImage = currUserData.data()!['image_url'];

    setState(() {
      if (role == 'Employee') {
        rolecolor = false;
      } else {
        rolecolor = true;
      }
      dName = userName;
      designation = role;
      diss = profileImage;
    });
  }

  void _submitbugreport() async {
    final isValid = _bugformKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _bugformKey.currentState!.save();
    setState(() {
      isreporting = true;
    });
    try {
      await FirebaseFirestore.instance.collection('Bug reports').add({
        'Bug title': enteredbugname,
        'Bug description': enteredbugdetail,
        'date': DateTime.now(),
        'username': dName,
        'role': designation,
      });

      setState(() {
        isreporting = false;
        _bugformKey.currentState!.reset();
        Navigator.of(context).pop();
      });
    } catch (error) {
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
        isreporting = false;
      });
    }
  }

  void showoverlay() {
    showModalBottomSheet(
        showDragHandle: true,
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return Container(
            // height: MediaQuery.of(context).size.height - 160,
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 14),
            child: Form(
                key: _bugformKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Report your bug',
                          style: TextStyle(
                              color: Color.fromARGB(255, 23, 23, 23),
                              fontSize: 21,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Title',
                        style: TextStyle(
                            color: Color.fromARGB(255, 23, 23, 23),
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        autofocus: true,
                        enabled: true,
                        readOnly: false,
                        obscureText: false,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length < 2) {
                            return 'Please enter a valid title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredbugname = value!;
                        },
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Enter title here',
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
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              16, 24, 0, 24),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Describe your issue',
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
                              value.trim().length < 5) {
                            return 'Please enter a valid description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredbugdetail = value!;
                        },
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Enter your description here',
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
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              16, 24, 0, 24),
                        ),
                      ),
                      const SizedBox(height: 27),
                      if (isreporting)
                        const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      if (!isreporting)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent),
                            onPressed: _submitbugreport,
                            child: const SizedBox(
                              height: 45,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Submit Report',
                                  style: TextStyle(
                                      fontSize: 16.5, color: Colors.white),
                                ),
                              ),
                            )),
                    ],
                  ),
                )),
          );
        });
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: diss == null
                        ? const CircleAvatar(
                            radius: 68,
                            backgroundColor: Color.fromARGB(255, 223, 249, 250),
                            foregroundImage: AssetImage(
                              'images/avatar.png',
                            ),
                          )
                        : CircleAvatar(
                            radius: 68,
                            backgroundColor: Colors.white,
                            foregroundImage: NetworkImage(diss),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27),
                    child: Center(
                      child: Text(dName,
                          style: TextStyle(
                              color: rolecolor
                                  ? const Color.fromARGB(255, 23, 23, 23)
                                  : Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Center(
                      child: Text(designation,
                          style: TextStyle(
                              color: rolecolor
                                  ? const Color.fromARGB(255, 23, 23, 23)
                                  : Colors.black54,
                              fontSize: 19,
                              fontWeight: FontWeight.w400)),
                    ),
                  ),
                  Container(
                    height: 460,
                    padding: const EdgeInsets.only(left: 10, top: 30),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: showoverlay,
                          leading: const Icon(
                            Icons.bug_report_rounded,
                            color: Colors.black54,
                            size: 22,
                          ),
                          title: const Text(
                            'Report a bug',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.of(context).pop();
                          },
                          leading: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.black54,
                            size: 22,
                          ),
                          title: const Text(
                            'Signout',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text('vJun.2',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
