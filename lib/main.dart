import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_drive/splash_screen.dart';
import 'package:push_drive/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:push_drive/navbar_sidedrawer_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
          useMaterial3: true, scaffoldBackgroundColor: Colors.black12),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (authSnapshot.hasData) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!
                      .uid) // Assuming the user's UID is used as the document ID in Firestore
                  .snapshots(),
              builder: (ctx, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen(); // You can replace this with a loading screen/widget
                }
                if (roleSnapshot.hasData) {
                  // Fetch the user's role from the Firestore snapshot
                  final userData = roleSnapshot.data!.data();
                  final userRole = userData?['role'];
                  if (userRole == 'Employer') {
                    return const tabScreens(); // Replace with your Employer screen widget
                  } else if (userRole == 'Employee') {
                    return const tabScreens(); // Replace with your Employee screen widget
                  } else {
                    // Handle the case where the userRole variable is null
                    return const SplashScreen();
                  }
                } else {
                  return const SplashScreen();
                }
              },
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:push_drive/SplashScreen.dart';
// import 'package:push_drive/authScreen.dart';
// import 'package:push_drive/navBar_sideDrawerScreen.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const App());
// }

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FlutterChat',
//       theme: ThemeData().copyWith(
//           useMaterial3: true, scaffoldBackgroundColor: Colors.black12),
//       home: StreamBuilder(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (ctx, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const SplashScreen();
//             }

//             if (snapshot.hasData) {
//               return const tabScreens();
//             }

//             return const AuthScreen();
//           }),
//     );
//   }
// }
