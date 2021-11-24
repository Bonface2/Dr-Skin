import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:splashscreen/splashscreen.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Dr.Skin',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
            seconds: 5,
            navigateAfterSeconds: Home(),
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
