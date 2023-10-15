import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:push_drive/widgets/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isArther = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      if (_selectedImage == null && !_isLogin) {
        setState(() {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 1),
              content: Center(
                  child: Text(
                'Please select an image',
                style: TextStyle(fontSize: 14),
              )),
            ),
          );
        });
      }
      return; // This return statement should be outside of the setState block
    }

// This return statement should be outside of the setState block

    _formKey.currentState!.save();
    try {
      setState(() {
        _isArther = true;
      });
      if (_isLogin) {
        final userCred = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCred = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child('${userCred.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'username': ' to be done...',
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-alredy-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(
            error.message ?? 'Authentication failed',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
      setState(() {
        _isArther = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 204, 220, 235),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SingleChildScrollView(
              child: // Generated code for this emailAddress Widget...
                  Padding(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin)
                        Column(
                          children: [
                            const Column(children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('Create Account',
                                    style: TextStyle(
                                        fontSize: 21.5,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('Sign-up to get started',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ]),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 43, bottom: 10),
                              child: const Image(
                                image: AssetImage("images/two.png"),
                                width: 390.0,
                              ),
                            ),
                          ],
                        ),
                      if (_isLogin)
                        Column(
                          children: [
                            const Column(children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('Welcome',
                                    style: TextStyle(
                                        fontSize: 23,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('Log-in to continue',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ]),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 42, bottom: 10),
                              child: const Image(
                                image: AssetImage("images/one.png"),
                                width: 390.0,
                              ),
                            ),
                          ],
                        ),
                      if (!_isLogin)
                        UserImagePicker(
                          onPickedImage: ((pickedImage) {
                            _selectedImage = pickedImage;
                          }),
                        ),
                      TextFormField(
                        obscureText: false,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length < 3 ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Enter your email here...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
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
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        obscureText: true,
                        onSaved: (value) {
                          _enteredPassword = value!;
                        },
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be six characters long';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Enter your password here...',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x00000000),
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
                      const SizedBox(
                        height: 20,
                      ),
                      if (_isArther)
                        const Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      if (!_isArther)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent),
                                onPressed: _submit,
                                child: Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      _isLogin ? 'Login' : 'Signup',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                )),
                            FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? 'Don\'t have an account?'
                                        : 'Already have an account?',
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                          _selectedImage =
                                              null; //Reset _selectedImage to null
                                        });
                                      },
                                      child: Text(
                                        _isLogin
                                            ? 'Create an Account '
                                            : 'Log-in',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w700),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
