import 'package:amateur_arena/firebase_options.dart';
import 'package:amateur_arena/models/user.dart';
import 'package:amateur_arena/screens/authentication/login.dart';
import 'package:amateur_arena/screens/authentication/register.dart';
import 'package:amateur_arena/screens/events.dart';
import 'package:amateur_arena/screens/home.dart';
import 'package:amateur_arena/screens/marketplace.dart';
import 'package:amateur_arena/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final goRouter = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final user = Provider.of<AmateurArenaUser?>(context);

          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Curling Companion",
                          style: TextStyle(fontSize: 30),
                        ),
                        Spacer(),
                        if (user == null)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => context.go("/login"),
                                child: Text("Login"),
                              ),
                              TextButton(
                                onPressed: () => context.go("/register"),
                                child: Text("Register"),
                              ),
                            ],
                          )
                        else
                          TextButton(
                            onPressed: () async =>
                                await AuthService().signOut(),
                            child: Text("Logout"),
                          ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go("/"),
                          child: Text("Home"),
                        ),
                        ElevatedButton(
                          onPressed: () => context.go("/events"),
                          child: Text("Events"),
                        ),
                        ElevatedButton(
                          onPressed: () => context.go("/marketplace"),
                          child: Text("Marketplace"),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          );
        },
        routes: [
          GoRoute(
            path: "/",
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: HomeScreen());
            },
          ),
          GoRoute(
            path: "/events",
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: EventsScreen());
            },
          ),
          GoRoute(
            path: "/marketplace",
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: MarketplaceScreen());
            },
          ),
          GoRoute(
            path: "/login",
            pageBuilder: (context, state) {
              return NoTransitionPage(child: LoginScreen());
            },
          ),
          GoRoute(
            path: "/register",
            pageBuilder: (context, state) {
              return NoTransitionPage(child: RegisterScreen());
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AmateurArenaUser?>.value(
      initialData: null,
      value: AuthService().user,
      catchError: (context, error) => null,
      child: MaterialApp.router(
        title: "Curling Companion",
        routerConfig: goRouter,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
      ),
    );
  }
}

// import 'package:amateur_arena/firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final db = FirebaseFirestore.instance;
//     return MaterialApp(
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//       ),
//       home: Scaffold(
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: db.collection('events').snapshots(),
//           builder: (context, snapshot) {
//             debugPrint("Snapshot State: ${snapshot.connectionState}");
//             if (snapshot.hasError) {
//               debugPrint("Snapshot Error: ${snapshot.error}");
//               return Center(child: Text("Error: ${snapshot.error}"));
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             final docs = snapshot.data!.docs;
//             return ListView.builder(
//               itemCount: docs.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(docs[index].data().toString()),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
