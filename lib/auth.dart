import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    if (_isLogin) {
    } else {
      try {
        final userCred = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-alredy-in-use') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Authentication failed'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 204, 220, 235),
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Card(
              color: const Color.fromARGB(255, 241, 244, 246),
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: // Generated code for this emailAddress Widget...
                    Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          autofocus: true,
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
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 24, 0, 24),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
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
                            contentPadding:
                                EdgeInsetsDirectional.fromSTEB(16, 24, 0, 24),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent),
                                onPressed: _submit,
                                child: Text(
                                  _isLogin ? 'Login' : 'Signup',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin
                                      ? 'Create an Account '
                                      : 'I already have an account',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                )),
                          ],
                        )
                      ],
                    ),
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
