import 'dart:async';
import 'package:e_taxi/screens/dashboard.dart';
import 'package:e_taxi/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:e_taxi/screens/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:e_taxi/services/locationservice.dart';
import 'package:e_taxi/screens/searchscreen.dart';
import 'package:e_taxi/services/fetchuserdata.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  UserData.fetchUserData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final user=FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> LocationService(),
      child: MaterialApp(
        title: 'E-Taxi App',
        initialRoute: user==null?LoginPage.id:DashBoard.id,
        routes: {
          Registration.id: (context) => Registration(),
          LoginPage.id: (context) => LoginPage(),
          DashBoard.id: (context) => DashBoard(),
          SearchScreen.id: (context) => SearchScreen()
        },
        theme: ThemeData(
            textTheme: TextTheme(
                bodyText1: TextStyle(
          fontFamily: 'Bolt',
          fontSize: 25,
        ))),
      ),
    );
  }
}
