import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:splashscreen/splashscreen.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Initialize a new Firebase App instance
  //await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dr.Skin',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
            seconds: 5,
            navigateAfterSeconds: LoginScreen(),
            image: new Image.asset(
              'assets/drskin.png',
              filterQuality: FilterQuality.high,
            ),
            photoSize: 250,
            backgroundColor: Colors.white,
            styleTextUnderTheLoader: new TextStyle(),
            loaderColor: Colors.brown[400]));
  }
}
