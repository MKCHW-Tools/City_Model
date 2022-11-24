import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:myapp/firebase/auth.dart';
import 'package:myapp/firebase/options.dart';

import 'login.dart';
import 'signup.dart';
import 'facilities.dart';
import 'review.dart';


void main() async {
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB_UUWyxoEd8nsB2KxzaVIMu9Dd3U_mDSY",
          authDomain: "mobiklinic-city-demo.firebaseapp.com",
          projectId: "mobiklinic-city-demo",
          storageBucket: "mobiklinic-city-demo.appspot.com",
          messagingSenderId: "538665673190",
          appId: "1:538665673190:web:83d9c6b082ec2c4c833627",
          measurementId: "G-L68QP00B22"));
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
       50: Color.fromRGBO(0x1E, 0x1E, 0x1E, .1),
      100: Color.fromRGBO(0x1E, 0x1E, 0x1E, .2),
      200: Color.fromRGBO(0x1E, 0x1E, 0x1E, .3),
      300: Color.fromRGBO(0x1E, 0x1E, 0x1E, .4),
      400: Color.fromRGBO(0x1E, 0x1E, 0x1E, .5),
      500: Color.fromRGBO(0x1E, 0x1E, 0x1E, .6),
      600: Color.fromRGBO(0x1E, 0x1E, 0x1E, .7),
      700: Color.fromRGBO(0x1E, 0x1E, 0x1E, .8),
      800: Color.fromRGBO(0x1E, 0x1E, 0x1E, .9),
      900: Color.fromRGBO(0x1E, 0x1E, 0x1E,  1),
    };

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xFF1E1E1E, color),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FacilityPage(),
        // '/review': (context) => ReviewPage(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        if (uri.path == "/review") {
          final appointmentId = uri.queryParameters['appointmentId'];
          return MaterialPageRoute(builder: (context) {
            return ReviewPage(appointmentId!);
          });
        }
      },
    );
  }
}